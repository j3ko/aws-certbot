#!/bin/bash
echo "Building image..."
docker build -t ${APP_NAME} --no-cache --progress=plain . -f ./image/lambda.Dockerfile

# Choose a different port for the host, e.g., 9001
HOST_PORT=9001

echo "Running container..."
CONTAINER_ID=$(docker run -d -p ${HOST_PORT}:8080 --env-file=./.env ${APP_NAME})

# Start the container logs in the background
docker logs -f $CONTAINER_ID &

echo "Making request..."
# Use 'host.docker.internal' for Windows or 'localhost' for Linux/Mac
curl "http://host.docker.internal:${HOST_PORT}/2015-03-31/functions/function/invocations" -d '{"payload":""}'

echo "Stopping container..."
# Stop the background container logs process
kill %1

docker stop $CONTAINER_ID
