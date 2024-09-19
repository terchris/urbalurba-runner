#!/bin/bash
# File: start.sh
#
# Pre-installing the .NET SDK for the runner

# Print debug information
echo "Debug Information:"
echo "GITHUB_OWNER: $GITHUB_OWNER"
echo "GITHUB_REPO: $GITHUB_REPO"
echo "RUNNER_NAME: $RUNNER_NAME"
echo "RUNNER_LABELS: $RUNNER_LABELS"
echo "PAT starts with: ${GITHUB_PAT:0:4}..."

# Check for required environment variables
if [ -z "$GITHUB_PAT" ]; then
    echo "Error: GITHUB_PAT environment variable is not set."
    exit 1
fi

if [ -z "$GITHUB_OWNER" ]; then
    echo "Error: GITHUB_OWNER environment variable is not set."
    exit 1
fi

if [ -z "$GITHUB_REPO" ]; then
    echo "Error: GITHUB_REPO environment variable is not set."
    exit 1
fi

# Set default values for optional variables
RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,Linux,ARM64"}

RUNNER_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}"

echo "Runner URL: $RUNNER_URL"

# Pre-install .NET SDK (version 8.0)
echo "Installing .NET SDK..."
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 8.0 --install-dir /usr/share/dotnet

# Add .NET to PATH
echo "Adding .NET SDK to PATH"
export PATH="/usr/share/dotnet:$PATH"

# Get a new runner token
RUNNER_TOKEN=$(curl -s -X POST -H "Authorization: token ${GITHUB_PAT}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token" \
    | jq -r .token)

if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" == "null" ]; then
    echo "Error: Failed to obtain runner token. Please check your PAT and permissions."
    exit 1
fi

# Configure the runner
./config.sh \
    --url "${RUNNER_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --unattended \
    --replace

# Start the runner
./run.sh
