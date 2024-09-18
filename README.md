# urbalurba-runner

## Overview
urbalurba-runner is a containerized GitHub Actions runner designed to monitor and build repositories within a specified GitHub repository. It provides a flexible, self-hosted solution for running GitHub Actions workflows, with a focus on building and deploying containers to a local microk8s registry. This runner supports multi-architecture builds, allowing it to create containers that can run on both ARM64 and AMD64 systems.

## Features
- Self-hosted GitHub Actions runner in a Docker container
- Monitors a specific GitHub repository
- Configurable to build and push containers to a local microk8s registry
- Customizable through environment variables
- Includes a self-test mechanism for easy verification
- Supports multi-architecture builds (ARM64 and AMD64)

## Prerequisites
- Docker
- Docker Buildx (for multi-architecture builds)
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
   ./build.sh
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
- `RUNNER_LABELS`: (Optional) Custom labels for the runner (default: self-hosted,Linux)
- `BUILD_ARCHITECTURE`: (Optional) Specify build architecture(s) (default: multi)

### Build Architecture Options
The `BUILD_ARCHITECTURE` variable in the `.env` file allows you to control which architectures to build for:
- `multi`: Builds for both ARM64 and AMD64 (default)
- `arm64`: Builds only for ARM64
- `amd64`: Builds only for AMD64
- `arm64,amd64`: Explicitly specify multiple architectures

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

## Building the Runner
To build the runner, use the provided build script:

```bash
./build.sh
```

This script reads the `BUILD_ARCHITECTURE` from your `.env` file and builds the appropriate image(s). It uses Docker Buildx to create multi-architecture images when specified.

## Testing API Access
Before running the container, you can test your API access using curl:

```bash
curl -H "Authorization: token YOUR_PAT_HERE" https://api.github.com/repos/OWNER/REPO
```

Replace `YOUR_PAT_HERE` with your Personal Access Token, `OWNER` with your GitHub username, and `REPO` with your repository name.

## Understanding Runner Labels
RUNNER_LABELS categorize the runner and determine which jobs it can execute. Use the `runs-on` key in your GitHub Actions workflows to target specific runners.

Example workflow snippet:
```yaml
jobs:
  build:
    runs-on: [self-hosted, Linux]
```

## Self-Test Mechanism
The repository includes a self-test to verify the runner's functionality:

1. `tests/node/hello-world.js`: A simple Node.js program
2. `.github/workflows/test-runner-node.yml`: A workflow that runs the Node.js program

To run the self-test:
1. Ensure your runner is operational
2. Push a commit to the main branch or manually trigger the "Test Runner (Node.js)" workflow from the Actions tab
3. Check the Actions tab for successful execution

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