# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

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
    libicu-dev \
    nodejs \
    npm \
    wget \
    gpg \
    apt-transport-https

# Add Microsoft package repository
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb

# Install .NET SDK 8
RUN apt-get update && \
    apt-get install -y dotnet-sdk-8.0

# Install Azure Functions Core Tools using npm
RUN npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Create a user for the runner
RUN useradd -m github-runner && \
    usermod -aG sudo github-runner && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER github-runner
WORKDIR /home/github-runner

# Download and install the latest GitHub Actions runner version
RUN ARCH=$(dpkg --print-architecture) && \
    case ${ARCH} in \
        arm64) RUNNER_ARCH="arm64" ;; \
        aarch64) RUNNER_ARCH="arm64" ;; \
        x86_64) RUNNER_ARCH="x64" ;; \
        amd64) RUNNER_ARCH="x64" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    LATEST_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/v//') && \
    curl -O -L https://github.com/actions/runner/releases/download/v${LATEST_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${LATEST_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-${RUNNER_ARCH}-${LATEST_VERSION}.tar.gz && \
    rm actions-runner-linux-${RUNNER_ARCH}-${LATEST_VERSION}.tar.gz

# Verify installations
RUN dotnet --version && \
    func --version

# Copy the startup script
COPY --chown=github-runner:github-runner start.sh .
RUN chmod +x start.sh

# Set the entrypoint
ENTRYPOINT ["./start.sh"]