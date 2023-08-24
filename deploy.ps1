function Clean {
  Remove-Item .\build -Recurse -Force -ErrorAction Ignore
  Remove-Item .\dist -Recurse -Force -ErrorAction Ignore
}

function Build($ID) {
  Get-ChildItem .\certbot*.zip -File | Select-Object -First 1 | Expand-Archive -DestinationPath .\build -Force
  New-Item -Path . -Name "dist" -ItemType "directory" -Force
  Compress-Archive -Path .\build\*,.\src\*,.\*.ini -DestinationPath .\dist\certbot-${ID}.zip -Force
}

function CreateBucket($Bucket) {
  $NoSuchBucket = aws s3 ls "s3://${Bucket}" 2>&1 | Select-String "NoSuchBucket"
  if ($NoSuchBucket -ne "" -and $null  -ne $NoSuchBucket) {
    Write-Output "Bucket: ${Bucket} does not exist, attempting to create..."
    aws s3api create-bucket --bucket ${Bucket}
  }
}

function Deploy($ID) {
  $Bucket = "aws-certbot"
  CreateBucket($Bucket)
  Write-Output "Starting deployment"
	aws s3 sync dist s3://${Bucket}/ --delete
	aws cloudformation deploy --stack-name AwsCertbot --template-file cloud.yaml --parameter-overrides BucketName=${Bucket} ObjectVersion=${ID} --capabilities CAPABILITY_IAM
  Write-Output "Deployment complete"
}

function Main {
  $GUID = New-Guid
  Clean
  Build($GUID)
  Deploy($GUID)
}

Main
