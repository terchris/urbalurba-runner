#!/bin/bash
# File: build.sh
#
# Purpose: This script builds the urbalurba-runner Docker image for ARM64 architecture.

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Ensure CONTAINER_NAME is set
if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: CONTAINER_NAME is not set. Please set it in .env file or as an environment variable."
    exit 1
fi

# Set the tag
TAG=${TAG:-latest}

echo "Building for ARM64 architecture"

# Build the Docker image
docker build --platform linux/arm64 -t $CONTAINER_NAME:$TAG .

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Build completed successfully."
    echo "You can now run the container using:"
    echo "docker run --name $CONTAINER_NAME --env-file .env -v /var/run/docker.sock:/var/run/docker.sock $CONTAINER_NAME:$TAG"
    echo ""
    echo "Note: This command will run the container in the foreground. To stop it, use Ctrl+C."
    echo "If you want to run it in the background, add the '-d' flag after 'docker run'."
else
    echo "Build failed."
    exit 1
fi