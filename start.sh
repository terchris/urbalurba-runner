#!/bin/bash
# File: start.sh
#
# This script sets up the GitHub Actions runner and installs the .NET SDK

set -e  # Exit immediately if a command exits with a non-zero status

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print debug information
log "Debug Information:"
log "GITHUB_OWNER: $GITHUB_OWNER"
log "GITHUB_REPO: $GITHUB_REPO"
log "RUNNER_NAME: $RUNNER_NAME"
log "RUNNER_LABELS: $RUNNER_LABELS"
log "PAT starts with: ${GITHUB_PAT:0:4}..."

# Check for required environment variables
if [ -z "$GITHUB_PAT" ]; then
    log "Error: GITHUB_PAT environment variable is not set."
    exit 1
fi

if [ -z "$GITHUB_OWNER" ]; then
    log "Error: GITHUB_OWNER environment variable is not set."
    exit 1
fi

if [ -z "$GITHUB_REPO" ]; then
    log "Error: GITHUB_REPO environment variable is not set."
    exit 1
fi

# Set default values for optional variables
RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,Linux,ARM64"}

RUNNER_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}"

log "Runner URL: $RUNNER_URL"

# Install .NET SDK
log "Installing .NET SDK..."
DOTNET_ROOT="$HOME/.dotnet"
mkdir -p "$DOTNET_ROOT"
if ! curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 8.0 --install-dir "$DOTNET_ROOT"; then
    log "Error: Failed to install .NET SDK"
    exit 1
fi

# Add .NET to PATH
log "Adding .NET SDK to PATH"
export PATH="$DOTNET_ROOT:$PATH"

# Ensure .NET is in PATH for future processes in this session
echo "export PATH=$DOTNET_ROOT:$PATH" >> ~/.bashrc

# Verify .NET installation
if ! command_exists dotnet; then
    log "Error: dotnet command not found after installation"
    exit 1
fi

DOTNET_VERSION=$(dotnet --version)
if [ $? -ne 0 ]; then
    log "Error: Failed to get .NET version"
    exit 1
fi
log ".NET SDK version: $DOTNET_VERSION"

# Get a new runner token
log "Obtaining runner token..."
RUNNER_TOKEN=$(curl -s -X POST -H "Authorization: token ${GITHUB_PAT}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token" \
    | jq -r .token)

if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" == "null" ]; then
    log "Error: Failed to obtain runner token. Please check your PAT and permissions."
    exit 1
fi

# Configure the runner
log "Configuring the runner..."
./config.sh \
    --url "${RUNNER_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --unattended \
    --replace

if [ $? -ne 0 ]; then
    log "Error: Failed to configure the runner"
    exit 1
fi

log "Runner configured successfully"

# Start the runner
log "Starting the runner..."
./run.sh