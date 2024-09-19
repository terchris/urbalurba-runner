# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

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
    npm

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

# Install latest debug package to resolve warning
RUN sudo npm install -g debug@latest

# Install Azure Functions Core Tools
RUN sudo npm install -g azure-functions-core-tools@latest --unsafe-perm true && \
    echo "export PATH=$PATH:/home/github-runner/.npm-global/bin" >> ~/.bashrc && \
    . ~/.bashrc

# Verify installations
RUN npm list -g --depth=0 && \
    func --version

# Copy the startup script
COPY --chown=github-runner:github-runner start.sh .
RUN chmod +x start.sh

# Set the entrypoint
ENTRYPOINT ["./start.sh"]