#!/bin/bash
set -e

docker build -t ${APP_NAME} --no-cache . -f ./image/lambda.Dockerfile
docker tag ${APP_NAME} ${APP_NAME}:latest

ECR_REPOSITORY_NAME="${APP_NAME}"
# Get AWS Account ID
echo "Fetching AWS ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

echo "Authenticating with docker..."
docker login -u AWS -p $(aws ecr get-login-password --region ${AWS_DEFAULT_REGION}) ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

set +e
echo "Checking for existing repositories..."
REPOSITORY_RESPONSE=$(aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_NAME} --region=${AWS_DEFAULT_REGION} 2>&1)
set -e

if [[ $REPOSITORY_RESPONSE == *"RepositoryNotFoundException"* ]]; then
  echo "Creating repository ${ECR_REPOSITORY_NAME}..."
  REPOSITORY_RESPONSE=$(aws ecr create-repository --repository-name ${ECR_REPOSITORY_NAME} --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE)
  ECR_REPOSITORY_URI=$(echo "${REPOSITORY_RESPONSE}" | jq -r '.repository.repositoryUri')
else
  ECR_REPOSITORY_URI=$(echo "${REPOSITORY_RESPONSE}" | jq -r '.repositories[0].repositoryUri')
fi
echo "Using repository URI: ${ECR_REPOSITORY_URI}"

# Tag local Docker image and push to ECR repository
docker tag ${APP_NAME} ${ECR_REPOSITORY_URI}:latest
docker push ${ECR_REPOSITORY_URI}:latest

TIMESTAMP=$(date +%s)

aws cloudformation deploy --stack-name ${APP_NAME} \
  --template-file cloud.yaml \
  --parameter-overrides \
    EcrRepositoryUri=${ECR_REPOSITORY_URI} \
    DnsCloudflareApiToken=${DNS_CLOUDFLARE_API_TOKEN} \
    DomainList=${DOMAIN_LIST} \
    DomainEmail=${DOMAIN_EMAIL} \
    DaysBeforeExpiration=${DAYS_BEFORE_EXPIRATION} \
    Timestamp=${TIMESTAMP} \
  --capabilities CAPABILITY_IAM

# Get the ARN of the Lambda function from stack outputs
CERTBOT_FUNCTION_ARN=$(aws cloudformation describe-stacks --stack-name ${APP_NAME} --query 'Stacks[0].Outputs[?OutputKey==`AwsCertbotFunctionArn`].OutputValue' --output text)

# Update the Lambda function code using the extracted ARN
aws lambda update-function-code \
  --function-name ${CERTBOT_FUNCTION_ARN} \
  --image-uri ${ECR_REPOSITORY_URI}:latest > /dev/null

echo "Deployment complete"
