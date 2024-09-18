# urbalurba-runner

## Overview
urbalurba-runner is a containerized GitHub Actions runner designed to monitor and build repositories within a specified GitHub organization. It provides a flexible, self-hosted solution for running GitHub Actions workflows, with a focus on building and deploying containers to a local microk8s registry.

## Features
- Self-hosted GitHub Actions runner in a Docker container
- Monitors repositories in the specified GitHub organization
- Configurable to build and push containers to a local microk8s registry
- Customizable through environment variables
- Includes a self-test mechanism for easy verification

## Prerequisites
- Docker
- GitHub Personal Access Token (PAT) with appropriate permissions
- (Optional) microk8s cluster with registry addon enabled

## Quick Start
1. Clone the repository:
   ```
   git clone https://github.com/terchris/urbalurba-runner.git
   cd urbalurba-runner
   ```

2. Set up configuration (see Configuration section below)

3. Build the Docker image:
   ```
   docker build -t urbalurba-runner .
   ```

4. Run the container:
   ```
   docker run --env-file .env urbalurba-runner
   ```

### Note for Apple Silicon (M1/M2) Mac Users
If you're using an Apple Silicon Mac, you may encounter issues related to architecture incompatibility. To resolve this:

1. Install Docker with Rosetta 2 support.
2. Build the image with the `--platform` flag:
   ```
   docker build --platform linux/amd64 -t urbalurba-runner .
   ```
3. Run the container with the `--platform` flag:
   ```
   docker run --platform linux/amd64 --env-file .env urbalurba-runner
   ```

## Configuration
The runner is configured using environment variables stored in a `.env` file.

1. Copy the template file:
   ```
   cp .env.template .env
   ```

2. Edit the `.env` file:
   ```
   nano .env  # or use your preferred text editor
   ```

3. Fill in the values (see "Configuration Variables" below)

### Configuration Variables:
- `GITHUB_PAT`: (Required) GitHub Personal Access Token
- `GITHUB_ORG`: (Required) GitHub organization name
- `GITHUB_REPO`: (Optional) Specific repository to monitor (initially set to urbalurba-runner for testing)
- `RUNNER_NAME`: (Optional) Custom name for the runner (default: hostname)
- `RUNNER_LABELS`: (Optional) Custom labels for the runner (default: self-hosted,Linux,X64)

### Obtaining GITHUB_PAT
To obtain a GitHub Personal Access Token (PAT):

1. Log in to your GitHub account
2. Go to [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
3. Click "Generate new token"
4. Choose the token type:
   - For most users, select "Generate new token (classic)"
   - If you need fine-grained permissions, select "Generate new token (Beta)" - this is recommended for advanced users who want to limit the token's scope to specific repositories

For "Generate new token (classic)":
5. Give your token a descriptive name
6. Select the following scopes:
   - repo (all)
   - workflow
   - admin:org > manage_runners:org
7. Click "Generate token"
8. Copy the token immediately (you won't be able to see it again)

For "Generate new token (Beta)":
5. Give your token a descriptive name
6. Set the expiration as needed
7. Select the specific repository or all repositories in your organization
8. Under "Repository permissions", set:
   - Actions: Read and Write
   - Administration: Read and Write
   - Contents: Read and Write
   - Metadata: Read-only (automatically selected)
9. Under "Organization permissions", set:
   - Self-hosted runners: Read and Write
10. Click "Generate token"
11. Copy the token immediately (you won't be able to see it again)

**Important**: Keep your PAT secure and never share it publicly. Choose an expiration date appropriate for your use case.

### Note on GITHUB_REPO
The `GITHUB_REPO` is initially set to `urbalurba-runner` for testing. After verifying functionality:

1. Stop the runner container
2. Edit your `.env` file
3. Change `GITHUB_REPO`:
   - Set to another repository name for specific monitoring
   - Leave blank to monitor the entire organization
4. Restart the runner container

## Understanding Runner Labels
RUNNER_LABELS categorize the runner and determine which jobs it can execute:

1. Assign labels to the runner (e.g., "self-hosted,Linux,X64")
2. In GitHub Actions workflows, use the `runs-on` key to specify required labels
3. GitHub dispatches jobs to runners with matching labels

Example workflow snippet:
```yaml
jobs:
  build:
    runs-on: [self-hosted, Linux]
```
This job will only run on self-hosted runners with both "self-hosted" and "Linux" labels.

## Self-Test Mechanism
The repository includes a self-test to verify the runner's functionality:

1. `tests/node/hello-world.js`: A simple Node.js program
2. `.github/workflows/test-runner-node.yml`: A workflow that runs the Node.js program

To run the self-test:
1. Ensure your runner is operational
2. Push a commit to the main branch or manually trigger the "Test Runner (Node.js)" workflow from the Actions tab
3. Check the Actions tab for successful execution

A successful run with "Hello, World!" output in the job logs confirms correct setup, specifically for Node.js jobs using the latest LTS version (Node.js 20 as of 2024).

## Usage with microk8s
(Detailed instructions for microk8s setup and usage will be added in future updates)

## Building Repositories
To flag a repository for building:
1. Add a `.github/workflows/build.yml` file to the repository
2. Specify appropriate `runs-on` labels in the workflow file to match your runner
3. The runner will execute workflows with matching labels

## Development and Testing
- The project uses Node.js 20 (LTS as of 2024) for testing
- GitHub Actions workflows are configured to use the latest stable versions of actions
- To contribute or test locally, ensure you have Node.js 20 installed

## Future Plans
- Implement automatic deployment to microk8s cluster
- Add support for monitoring multiple organizations
- Enhance logging and monitoring capabilities
- Expand test suite to cover more scenarios and languages

## Contributing
Contributions to urbalurba-runner are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License
This project is licensed under the [MIT License](LICENSE).

## Support
For questions or support, please open an issue in the GitHub repository.

## Security Note
The `.env` file is included in `.gitignore` to prevent accidental commit of sensitive information. Always keep your `.env` file secure and never commit it to the repository.