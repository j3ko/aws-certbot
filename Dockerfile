# Use the amazon/aws-lambda-python:3.11 image as the base image
FROM amazon/aws-lambda-python:3.11

# Set an argument for Certbot version
ARG CERTBOT_VERSION=1.21.0

# Install required build tools and dependencies
RUN yum install -y gcc libffi-devel tar gzip which

# Set the working directory
WORKDIR /tmp

# # Download the Certbot source code based on the specified version
# RUN curl -LO https://github.com/certbot/certbot/archive/refs/tags/v${CERTBOT_VERSION}.tar.gz

# RUN ls /tmp

# # Extract and rename the Certbot directory
# RUN tar -xzf v${CERTBOT_VERSION}.tar.gz && \
#     ls . && \
#     mv certbot-${CERTBOT_VERSION} certbot

# Install Certbot using Python
# RUN cd certbot && \
#     /var/lang/bin/python3.11 -m venv venv && \
#     source venv/bin/activate && \
RUN pip3 install \
    certbot==${CERTBOT_VERSION} \
    certbot-dns-cloudflare==${CERTBOT_VERSION}

RUN which certbot

# # Package the Certbot files into a zip file
# RUN zip -r certbot.zip certbot

# # Move the zip file to a location that's accessible to the host
# RUN mv certbot.zip /tmp/certbot.zip

# Set the command to execute when the container starts (optional)
CMD [ "echo", "Certbot build and zip completed." ]
