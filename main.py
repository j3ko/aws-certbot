import boto3
import certbot.main
import datetime
import os
import raven
import subprocess
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Get clients
s3 = boto3.client('s3')
acm = boto3.client('acm')

def handler(event, context):
  try:
    domains = os.environ['DOMAINS_LIST']
  except Exception as e:
    logger.warning(e)
    raise
