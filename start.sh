#!/bin/bash
# File: start.sh
#
# Purpose: This script configures and starts the GitHub Actions runner.
# It uses environment variables to set up the runner for a specific
# GitHub organization or repository.
#
# Required environment variables:
#   GITHUB_PAT: Personal Access Token for GitHub
#   GITHUB_ORG: GitHub organization name
#
# Optional environment variables:
#   GITHUB_REPO: Specific repository name (if not set, runner will be configured for the entire org)
#   RUNNER_NAME: Name for this runner (default: hostname)
#   RUNNER_LABELS: Custom labels for the runner (comma-separated)

# Check for required environment variables
if [ -z "$GITHUB_PAT" ]; then
    echo "Error: GITHUB_PAT environment variable is not set."
    exit 1
fi

if [ -z "$GITHUB_ORG" ]; then
    echo "Error: GITHUB_ORG environment variable is not set."
    exit 1
fi

# Set default values for optional variables
RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,Linux,X64"}

# Determine if we're setting up for an org or a specific repo
if [ -z "$GITHUB_REPO" ]; then
    RUNNER_URL="https://github.com/${GITHUB_ORG}"
else
    RUNNER_URL="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}"
fi

# Get a new runner token
RUNNER_TOKEN=$(curl -s -X POST -H "Authorization: token ${GITHUB_PAT}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/${GITHUB_ORG}/actions/runners/registration-token" \
    | jq -r .token)

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