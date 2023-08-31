# Use the Amazon Linux 2 base image
FROM public.ecr.aws/lambda/python:3.11

ARG CERTBOT_VERSION=2.6.0

# Install system dependencies
RUN yum install -y python3 augeas-libs

# Set up a Python virtual environment
RUN python3 -m venv /opt/certbot/ && \
    /opt/certbot/bin/pip install --upgrade pip

# Install Certbot
RUN /opt/certbot/bin/pip install \
    certbot==${CERTBOT_VERSION} \
    certbot-dns-cloudflare==${CERTBOT_VERSION}

# Prepare the Certbot command
RUN ln -s /opt/certbot/bin/certbot /usr/bin/certbot

COPY src ${LAMBDA_TASK_ROOT}

ADD tmp ${LAMBDA_TASK_ROOT}/tmp

# Set the command to execute Certbot (this example just prints help)
CMD ["main.handler"]
