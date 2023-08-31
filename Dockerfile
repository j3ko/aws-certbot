# Final production image
FROM ubuntu:22.04

# Dependencies (needed for scripts as well)
RUN apt-get update && \
    apt-get install -y unzip jq curl

# Install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh

# Install AWS CLI
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install; \
    elif [ "$ARCH" = "arm64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install; \
    else \
        echo "Unsupported architecture: $ARCH"; \
    fi

# Setup workspace
WORKDIR /app

COPY . /app

# Give executable permissions
RUN chmod +x /app/run.sh
RUN chmod +x /app/deploy.sh

# Entry point to run Docker commands on the host
CMD ["./run.sh"]
