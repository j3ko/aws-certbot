#!/bin/bash
set -e

echo "Building image..."
docker build -t ${APP_NAME} --no-cache . -f ./image/lambda.Dockerfile

# Choose a different port for the host, e.g., 9001
HOST_PORT=9001

# Export environment variables to a file
env > env_export

echo "Running container..."
CONTAINER_ID=$(docker run -d --env-file=env_export -p ${HOST_PORT}:8080 -i ${APP_NAME})

# Start the container logs in the background
docker logs -f $CONTAINER_ID &

echo "Waiting for container to initialize..."
# Adding a delay of 5 seconds before making the request
sleep 5

echo "Making request..."
curl "http://host.docker.internal:${HOST_PORT}/2015-03-31/functions/function/invocations" -d '{"payload":""}' > /dev/null

echo "Stopping container..."
# Stop the background container logs process
kill %1

docker stop $CONTAINER_ID
