#!/bin/bash
# File: build.sh
#
# Purpose: This script builds the urbalurba-runner Docker image for specified architectures.
#
# Usage: ./build.sh [OPTIONS]
#
# Options:
#   -a, --architecture ARCH   Specify the build architecture(s). 
#                             Values: multi, arm64, amd64, or comma-separated list
#   -t, --tag TAG             Specify the Docker image tag (default: latest)
#   -p, --push                Push the image to the container registry
#   -h, --help                Display this help message
#
# Environment variables (can be set in .env file):
#   BUILD_ARCHITECTURE: Determines which architectures to build for if not specified via command line.
#   CONTAINER_REGISTRY: The container registry to push to (if --push is used)
#   CONTAINER_NAME: The name to use for the Docker image

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Default values
TAG=${TAG:-latest}
PUSH=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--architecture)
        BUILD_ARCHITECTURE="$2"
        shift # past argument
        shift # past value
        ;;
        -t|--tag)
        TAG="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--push)
        PUSH=true
        shift # past argument
        ;;
        -h|--help)
        echo "Usage: ./build.sh [OPTIONS]"
        echo "Options:"
        echo "  -a, --architecture ARCH   Specify the build architecture(s)"
        echo "  -t, --tag TAG             Specify the Docker image tag (default: latest)"
        echo "  -p, --push                Push the image to the container registry"
        echo "  -h, --help                Display this help message"
        exit 0
        ;;
        *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Ensure CONTAINER_NAME is set
if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: CONTAINER_NAME is not set. Please set it in .env file or as an environment variable."
    exit 1
fi

# Create a new builder instance if it doesn't exist
if ! docker buildx inspect mybuilder > /dev/null 2>&1; then
    docker buildx create --name mybuilder --use
else
    docker buildx use mybuilder
fi

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

# Prepare the build command
BUILD_CMD="docker buildx build --platform $PLATFORMS -t $CONTAINER_NAME:$TAG"

# Add push flag if specified
if [ "$PUSH" = true ]; then
    if [ -z "$CONTAINER_REGISTRY" ]; then
        echo "Error: CONTAINER_REGISTRY is not set. Please set it in .env file or as an environment variable."
        exit 1
    fi
    BUILD_CMD+=" --push"
    # Update the image name to include the registry
    BUILD_CMD=${BUILD_CMD/"-t $CONTAINER_NAME:"/"-t $CONTAINER_REGISTRY/$CONTAINER_NAME:"}
else
    BUILD_CMD+=" --load"
fi

# Add the build context
BUILD_CMD+=" ."

# Execute the build command
echo "Executing build command: $BUILD_CMD"
eval $BUILD_CMD

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Build completed successfully."
    if [ "$PUSH" = true ]; then
        echo "Image pushed to $CONTAINER_REGISTRY/$CONTAINER_NAME:$TAG"
    else
        echo "You can now run the container using:"
        echo "docker run --name $CONTAINER_NAME --env-file .env $CONTAINER_NAME:$TAG"
    fi
else
    echo "Build failed."
    exit 1
fi