# urbalurba-runner

## Overview
urbalurba-runner is a containerized GitHub Actions runner designed to monitor and build repositories within a specified GitHub repository. It provides a flexible, self-hosted solution for running GitHub Actions workflows, with a focus on building and deploying containers to a local microk8s registry.

## Features
- Self-hosted GitHub Actions runner in a Docker container
- Monitors a specific GitHub repository
- Configurable to build and push containers to a local microk8s registry
- Customizable through environment variables
- Includes a self-test mechanism for easy verification
- Optimized for ARM64 architecture (e.g., Apple Silicon Macs)

## Prerequisites
- Docker
- GitHub Personal Access Token (PAT) with appropriate permissions
- (Optional) microk8s cluster with registry addon enabled
- ARM64-based system (e.g., Apple Silicon Mac)

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
- `GITHUB_OWNER`: (Required) GitHub username
- `GITHUB_REPO`: (Required) Repository name
- `RUNNER_NAME`: (Optional) Custom name for the runner (default: hostname)
- `RUNNER_LABELS`: (Optional) Custom labels for the runner (default: self-hosted,Linux,ARM64)

### Obtaining GITHUB_PAT
To obtain a GitHub Personal Access Token (PAT):

1. Log in to your GitHub account
2. Go to [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
3. Click "Generate new token (classic)"
4. Give your token a descriptive name
5. Set the expiration as needed
6. Select the following scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
7. Click "Generate token"
8. Copy the token immediately (you won't be able to see it again)

**Important**: Keep your PAT secure and never share it publicly. Choose an expiration date appropriate for your use case.

## Testing API Access
Before running the container, you can test your API access using curl:

```bash
curl -H "Authorization: token YOUR_PAT_HERE" https://api.github.com/repos/OWNER/REPO
```

Replace `YOUR_PAT_HERE` with your Personal Access Token, `OWNER` with your GitHub username, and `REPO` with your repository name.

If successful, this will return detailed information about your repository, confirming that your token has the correct permissions.

**Important Security Note:** Never share your Personal Access Token publicly or commit it to your repository. Always use environment variables or secure secrets management systems to handle sensitive information like tokens.

## Understanding Runner Labels
RUNNER_LABELS categorize the runner and determine which jobs it can execute:

1. Assign labels to the runner (e.g., "self-hosted,Linux,ARM64")
2. In GitHub Actions workflows, use the `runs-on` key to specify required labels
3. GitHub dispatches jobs to runners with matching labels

Example workflow snippet:
```yaml
jobs:
  build:
    runs-on: [self-hosted, Linux, ARM64]
```
This job will only run on self-hosted runners with "self-hosted", "Linux", and "ARM64" labels.

## Self-Test Mechanism
The repository includes a self-test to verify the runner's functionality:

1. `tests/node/hello-world.js`: A simple Node.js program
2. `.github/workflows/test-runner-node.yml`: A workflow that runs the Node.js program

To run the self-test:
1. Ensure your runner is operational
2. Push a commit to the main branch or manually trigger the "Test Runner (Node.js)" workflow from the Actions tab
3. Check the Actions tab for successful execution

A successful run with "Hello, World!" output in the job logs confirms correct setup.

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

## Contributing
Contributions to urbalurba-runner are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License
This project is licensed under the MIT License.

## Support
For questions or support, please open an issue in the GitHub repository.

## Security Note
The `.env` file is included in `.gitignore` to prevent accidental commit of sensitive information. Always keep your `.env` file secure and never commit it to the repository.