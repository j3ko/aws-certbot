# AWS-Certbot ![tests](https://github.com/j3ko/aws-certbot/actions/workflows/test.yml/badge.svg)
Auto renew [letsencrypt.org](https://letsencrypt.org) SSL certificates provisioned on [ACM](https://aws.amazon.com/certificate-manager/).

## Requirements
- [Docker v24+](https://docs.docker.com/engine/)

## Quick Start
1. ```
   git clone git@github.com:j3ko/aws-certbot.git
   ```

1. ```
   cd aws-certbot
   ```

1. Edit `.env.sample` and fill in the [required fields](#environment-variables)

1. Build the docker image

   ```bash
   docker build -t aws-certbot-builder .
   ```
1. Run **aws-certbot** locally

   ```bash
   docker run -it --rm --env-file=./.env.sample -v /var/run/docker.sock:/var/run/docker.sock aws-certbot-builder
   ```

### What does it do?
Running **aws-certbot** locally will:
1.  Check ACM to see if any domains in `DOMAIN_LIST` are expiring soon.
1.  If domains are missing or expiring, certbot runs and generates a new SSL certificate
1.  Any newly generated certificates are uploaded to ACM

## Environment Variables
| Variable | Description | Required? |
|---|---|---|
| APP_NAME | Name used for docker images/AWS resources | ✅ |
| AWS_ACCESS_KEY_ID | AWS access key |  ✅ |
| AWS_SECRET_ACCESS_KEY | AWS secret access key |  ✅ |
| AWS_DEFAULT_REGION | AWS region to use |  ✅ |
| DOMAIN_LIST | A list of domains separated by commas and semicolons. The semicolon separates groups of domains, while commas separate individual domains. For example: `domain.com,*.domain.com;example.io,staging.example.io` |  ✅ |
| DOMAIN_EMAIL | Cloudflare API key with edit.zone permissions |  ✅ |
| DAYS_BEFORE_EXPIRATION | Number of days before expiration to request renewal |  ✅ |
| LAMBDA_TIMEOUT | Lambda timeout in seconds |  ✅ |

## Deploying to AWS

1. Edit `.env.sample` and fill in the [required fields](#environment-variables)

1. Build the docker image

   ```bash
   docker build -t aws-certbot-builder .
   ```
1. Deploy **aws-certbot** to AWS

   ```bash
   docker run -it --rm --env-file=./.env.sample -v /var/run/docker.sock:/var/run/docker.sock aws-certbot-builder ./deploy.sh
   ```

### What does it do?

1. The **aws-certbot** docker image is built and uploaded to [ECR](https://aws.amazon.com/ecr/).
1. The cloud formation defined in `cloud.yaml` is deployed to run the docker image as a lambda function.
1. A timer is defined in `cloud.yaml` to execute the lambda function once a day.

## Known Issues

- Only Cloudflare-managed domains can currently be used.
- Cloudflare API key is visible in lambda environment variables.

## Credits
AWS-Certbot is based largely on the following amazing projects:
- https://arkadiyt.com/2018/01/26/deploying-effs-certbot-in-aws-lambda/
- https://github.com/kingsoftgames/certbot-lambda
