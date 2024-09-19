#!/bin/bash
# File: build.sh
#
# Purpose: This script builds the urbalurba-runner Docker image for specified architectures.
#
# Usage: ./build.sh
#
# Environment variables (set in .env file):
#   BUILD_ARCHITECTURE: Determines which architectures to build for.
#     Possible values:
#       - "multi" or empty: Builds for both ARM64 and AMD64 (default)
#       - "arm64": Builds only for ARM64
#       - "amd64": Builds only for AMD64
#       - "arm64,amd64": Explicitly specify multiple architectures
#   CONTAINER_NAME: The name to use for the Docker container
#
# This script does the following:
# 1. Loads environment variables from .env file
# 2. Sets up Docker buildx for multi-architecture builds
# 3. Determines which platforms to build for based on BUILD_ARCHITECTURE
# 4. Builds the Docker image(s) locally
# 5. Provides instructions for running the built container with the specified name

# Load environment variables
source .env

# Create a new builder instance if it doesn't exist
docker buildx create --name mybuilder --use

# Determine the platforms to build for
if [ "$BUILD_ARCHITECTURE" = "multi" ] || [ -z "$BUILD_ARCHITECTURE" ]; then
    PLATFORMS="linux/arm64,linux/amd64"
elif [ "$BUILD_ARCHITECTURE" = "arm64" ] || [ "$BUILD_ARCHITECTURE" = "amd64" ]; then
    PLATFORMS="linux/$BUILD_ARCHITECTURE"
else
    PLATFORMS=""
    IFS=',' read -ra ARCH <<< "$BUILD_ARCHITECTURE"
    for arch in "${ARCH[@]}"; do
        if [ -n "$PLATFORMS" ]; then
            PLATFORMS="$PLATFORMS,"
        fi
        PLATFORMS="${PLATFORMS}linux/$arch"
    done
fi

echo "Building for platforms: $PLATFORMS"

# Build multi-architecture image locally
docker buildx build --platform $PLATFORMS -t urbalurba-runner:latest \
    --build-arg INSTALL_AZURE_FUNCTIONS=true \
    --load .

echo "Build complete. You can now run the container using:"
echo "docker run --name $CONTAINER_NAME --env-file .env urbalurba-runner:latest"