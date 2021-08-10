# AWS-Certbot
Auto renew and update letsencrypt.org SSL certificates provisioned on [ACM](https://aws.amazon.com/certificate-manager/).

## Requirements
- [AWS CLI v2](https://aws.amazon.com/cli/)
- [PowerShell 7.1+](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)
- Registered domain ([namecheap](https://www.namecheap.com/), [godaddy](https://godaddy.com/), etc..)
- DNS service ([cloudflare](https://www.cloudflare.com/), [route53](https://aws.amazon.com/route53/), etc..)

## Setup

### Introduction
Certbot integrates with many popular [DNS services](https://certbot.eff.org/docs/using.html?highlight=dns#dns-plugins) to verify SSL certificate challenges automatically via API. AWS-Certbot currently only handles Cloudflare integration.  Cloudflare provides free DNS services for personal project sites.  For integrations with other services, please open a [Feature Request](https://github.com/j3ko/aws-certbot/issues/new?assignees=j3ko&labels=enhancement&template=feature_request.md&title=).

### Cloudflare Setup
1. [Register](https://dash.cloudflare.com/sign-up) for a Cloudflare account
1. Configure your domain registrar to use Cloudflare as your DNS service provider.  This is specific for each registrar ([namecheap specific guide](https://www.namecheap.com/support/knowledgebase/article.aspx/9607/2210/how-to-set-up-dns-records-for-your-domain-in-cloudflare-account/)).
1. [Create](https://developers.cloudflare.com/api/tokens/create) a Cloudflare API token.  It is recommended to generate a token with the minimum required permissions (ie. read/write access to the DNS zone you want AWS-Certbot to handle).
1. Rename `cloudflare.ini.sample` to `cloudflare.ini` and paste your newly created API token into the file.

## Deployment
Run
```
.\deploy.ps1
```

## Configuration
Several configuration variables are available on the AWS-Certbot lambda function:

`CERTBOT_BUCKET` - bucket name containing AWS-Certbot code

`DOMAIN_EMAIL` - email address to use for letsencrypt.org registration

`DOMAIN_LIST` - comma separated list of domains/subdomains to enlist for automatic renewal (eg. `letsencrypt.org,subdomain.letsencrypt.org`)

`CERTS_RENEW_DAYS_BEFORE_EXPIRATION` - number of days before expiration to attempt renewal

## Credits
AWS-Certbot is based largely on the following amazing projects:
- https://arkadiyt.com/2018/01/26/deploying-effs-certbot-in-aws-lambda/
- https://github.com/kingsoftgames/certbot-lambda
