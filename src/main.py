import boto3
import datetime
import os
import subprocess
import logging
from aws_certbot.domain_list import DomainList

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def chmod_digit(file_path, perms):
    os.chmod(file_path, int(str(perms), base=8))

def get_challenge():
    if (os.environ['DNS_CLOUDFLARE_API_TOKEN'] is not None):
        logger.info('Cloudflare configuration detected')
        with open('/tmp/cloudflare.ini', 'w') as file:
            file.write('dns_cloudflare_api_token = ' + os.environ['DNS_CLOUDFLARE_API_TOKEN'])
            chmod_digit('/tmp/cloudflare.ini', 600)

        return [
            '--dns-cloudflare',
            '--dns-cloudflare-propagation-seconds', '60',
            '--dns-cloudflare-credentials', '/tmp/cloudflare.ini'
        ]
    else:
        return ['--dns-route53']

def read_and_delete_file(path):
    with open(path, 'r') as file:
        contents = file.read()
    os.remove(path)
    return contents

def provision_cert(email, lineage, domains):
    logger.info('Attempting to provision cert for: ({}) {}'.format(lineage, domains))
    params = [
        'certbot',
        'certonly',
        '-n', # non-interactive
        '--agree-tos',
        '--email', email,
        '-d', domains,
        '--config-dir', '/tmp/config-dir/',
        '--work-dir', '/tmp/work-dir/',
        '--logs-dir', '/tmp/logs-dir/',
    ]
    params += get_challenge()
    subprocess.run(params)

    path = '/tmp/config-dir/live/' + lineage + '/'
    return {
        'certificate': read_and_delete_file(path + 'cert.pem'),
        'private_key': read_and_delete_file(path + 'privkey.pem'),
        'certificate_chain': read_and_delete_file(path + 'chain.pem')
    }

def should_provision(domains):
    existing_cert = find_existing_cert(domains)
    if existing_cert:
        now = datetime.datetime.now(datetime.timezone.utc)
        not_after = existing_cert['Certificate']['NotAfter']
        expiry = (not_after - now).days
        cutoff = int(os.environ['DAYS_BEFORE_EXPIRATION'])
        logger.info('Existing cert found with expiry ({expiry}) <= cutoff ({cutoff})'.format(expiry=expiry, cutoff=cutoff))
        return expiry <= cutoff
    else:
        logger.info('No existing cert found')
        return True

def find_existing_cert(domains):
    domains = frozenset(domains.split(','))
    client = boto3.client('acm')
    certs = client.list_certificates(
        Includes={'keyTypes': ['RSA_1024', 'RSA_2048', 'RSA_3072', 'RSA_4096', 'EC_prime256v1', 'EC_secp384r1', 'EC_secp521r1']},
        MaxItems=1000
    )

    for cert in certs['CertificateSummaryList']:
        cert = client.describe_certificate(CertificateArn=cert['CertificateArn'])
        sans = frozenset(cert['Certificate']['SubjectAlternativeNames'])
        if sans.issubset(domains):
            return cert

    return None


def upload_cert_to_acm(cert, domains):
    existing_cert = find_existing_cert(domains)
    client = boto3.client('acm')

    if existing_cert:
        certificate_arn = existing_cert['Certificate']['CertificateArn']
        acm_response = client.import_certificate(
            CertificateArn=certificate_arn,
            Certificate=cert['certificate'],
            PrivateKey=cert['private_key'],
            CertificateChain=cert['certificate_chain']
        )
    else:
        acm_response = client.import_certificate(
            Certificate=cert['certificate'],
            PrivateKey=cert['private_key'],
            CertificateChain=cert['certificate_chain']
        )

    return None

def handler(event, context):
    try:
        dlist = DomainList(os.environ['DOMAIN_LIST'])
        email = os.environ['DOMAIN_EMAIL']
        logger.info('Processing domain list: {}'.format(dlist.original))
        for lineage, domains in dlist.lineage.items():
            logger.info('Processing: ({}) {}'.format(lineage, domains))
            if should_provision(domains):
                cert = provision_cert(email, lineage, domains)
                upload_cert_to_acm(cert, domains)
    except Exception as e:
        logger.error(e)
        raise
