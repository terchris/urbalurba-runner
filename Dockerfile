# File: Dockerfile
# 
# Purpose: This Dockerfile creates an image for a self-hosted GitHub Actions runner.
# It is based on Ubuntu 22.04 and includes the necessary dependencies and the
# GitHub Actions runner software. This version is designed to work on multiple architectures.
#
# Usage: 
#   1. Build the image: docker build -t github-runner .
#   2. Run the container with required environment variables:
#      docker run -e GITHUB_PAT=<your_pat> -e GITHUB_OWNER=<your_username> -e GITHUB_REPO=<your_repo> github-runner

# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables
ENV RUNNER_VERSION=2.316.0

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    git \
    sudo \
    libicu-dev

# Create a user for the runner
RUN useradd -m github-runner && \
    usermod -aG sudo github-runner && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER github-runner
WORKDIR /home/github-runner

# Download and install the GitHub Actions runner
RUN ARCH=$(dpkg --print-architecture) && \
    case ${ARCH} in \
        arm64) RUNNER_ARCH="arm64" ;; \
        aarch64) RUNNER_ARCH="arm64" ;; \
        x86_64) RUNNER_ARCH="x64" ;; \
        amd64) RUNNER_ARCH="x64" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

# Copy the startup script
COPY --chown=github-runner:github-runner start.sh .
RUN chmod +x start.sh

# Set the entrypoint
ENTRYPOINT ["./start.sh"]