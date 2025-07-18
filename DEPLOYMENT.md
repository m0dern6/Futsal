# Deployment Guide

This guide provides detailed instructions for deploying the Futsal API .NET Aspire application to a DigitalOcean server. The deployment is automated using Docker Compose and a GitHub Actions CI/CD pipeline.

## 1. Deployment Strategy Overview

.NET Aspire simplifies development and deployment orchestration. For production, we leverage this by using the `FutsalApi.AppHost` project, which is our development-time orchestrator, to generate a standard `docker-compose.yml` file. This file defines all the services of our application (e.g., `apiservice`, `auth`) as containers.

The deployment process is fully automated via a GitHub Actions workflow defined in `.github/workflows/ci-cd.yaml`. When code is pushed to the `master` branch, the following automated sequence begins:

1.  **Job Trigger**: A self-hosted GitHub Actions runner, configured on the DigitalOcean server, detects the push and starts the deployment job.
2.  **Code Checkout**: The runner checks out the specific commit that triggered the workflow.
3.  **Publish & Package**: The runner executes `dotnet publish` on the `FutsalApi.AppHost` project. This crucial step uses the `dockercompose` publisher to generate a `publish` directory containing a `docker-compose.yml` file and all necessary application assets.
4.  **Cleanup Old Deployment**: The workflow connects to the server via SSH to stop and remove any containers from the previous deployment and deletes the old application directory to ensure a clean slate.
5.  **Secure File Transfer**: The contents of the newly created `publish` directory are securely copied to the application directory on the DigitalOcean server.
6.  **Launch Application**: The workflow runs `docker-compose up`, which reads the new `docker-compose.yml` to build fresh container images, and then creates and starts all application services in detached mode.

## 2. Prerequisites

*   A DigitalOcean account and a Droplet (server) running a recent Ubuntu version.
*   A non-root user with `sudo` privileges on the Droplet.
*   Docker and Docker Compose installed on the Droplet.
*   A .NET SDK (latest version recommended) installed on the Droplet for the GitHub Actions runner.
*   A GitHub repository for your project.

## 3. DigitalOcean Server Setup

### Step 3.1: Install Docker
SSH into your DigitalOcean Droplet. It's best practice to perform these steps as a non-root user with `sudo` privileges.

```bash
# Download and run the official Docker installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
Add your user to the `docker` group to run Docker commands without `sudo`. This is essential for the GitHub Actions runner.
```bash
sudo usermod -aG docker $USER
```
**You must log out and log back in for this group change to take effect.**

### Step 3.2: Install Docker Compose
Docker Compose is now a plugin for Docker and can be installed with `apt`.
```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin -y
```
Verify the installation:
```bash
docker compose version
```

### Step 3.3: Install .NET SDK
The self-hosted runner needs the .NET SDK to publish the application.
```bash
# Get the Microsoft package signing key and add the package repository
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install the SDK
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0 # Or the version you are using
```

### Step 3.4: Install and Configure GitHub Actions Runner
Follow the official GitHub documentation to [add a self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) to your repository.

During configuration, it is highly recommended to [configure the runner as a service](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service). This ensures the runner starts automatically after a server reboot and runs in the background.

## 4. GitHub Repository Configuration (Secrets)

For the CI/CD pipeline to securely access your DigitalOcean server, you **must** add the following secrets to your repository. Using SSH keys is strongly recommended over passwords.

Navigate to your GitHub repository's **Settings > Secrets and variables > Actions** and add the following secrets:

*   `DO_HOST`: The public IP address of your DigitalOcean Droplet.
*   `DO_USERNAME`: The username for SSH access to your Droplet (e.g., `root` or, preferably, your non-root user).
*   `DO_PASSWORD`: The password for the user specified in `DO_USERNAME`. **(Not Recommended, use SSH Key instead)**.

### Recommended: Using SSH Keys for Better Security
1.  Generate an SSH key pair on your local machine or on the server.
2.  Add the public key to your server's `~/.ssh/authorized_keys` file.
3.  Add the **private key** as a repository secret named `DO_SSH_PRIVATE_KEY`.
4.  Update your workflow file to use the private key instead of a password.

## 5. CI/CD Workflow Explained

The workflow in `.github/workflows/ci-cd.yaml` automates the entire deployment.

*   **`on: push: branches: [ "master" ]`**: Triggers the workflow on any push to the `master` branch.
*   **`runs-on: self-hosted`**: Specifies that the job must run on your configured self-hosted runner.
*   **`actions/checkout@v3`**: Checks out your repository's code onto the runner.
*   **`dotnet publish ... --publisher dockercompose`**: This is the core build step that creates the `publish` directory with the `docker-compose.yml` file.
*   **`appleboy/ssh-action@master` (Deploy to DigitalOcean)**: This step connects to your server via SSH and runs a script to prepare for the new deployment by stopping and removing old containers and clearing the app directory. The `|| true` part ensures the workflow doesn't fail if there's no previous deployment to clean up.
*   **`appleboy/scp-action@master`**: Securely copies the `publish` directory's contents to the `~/app` directory on your server.
*   **`appleboy/ssh-action@master` (Run Docker Compose)**: Connects via SSH again to run `docker-compose -p futsalapi up -d --build`.
    *   `-p futsalapi`: Sets a custom project name to avoid conflicts.
    *   `up -d`: Starts the containers in detached (background) mode.
    *   `--build`: Forces Docker Compose to rebuild the container images if the source code has changed.

## 6. Verifying and Troubleshooting

After a deployment, you can check its status:

*   **Check Running Containers**: SSH into your server and run `docker ps`. You should see containers for each of your services.
*   **View Logs**: To see the logs from all running services:
    ```bash
    cd ~/app
    docker compose -p futsalapi logs -f
    ```
    To view logs for a specific service (e.g., `apiservice`):
    ```bash
    docker compose -p futsalapi logs -f apiservice
    ```

### Common Issues:
*   **`.NET SDK Not Found` on Runner**: Ensure the .NET SDK was installed correctly on the server and that the runner service was restarted after installation to update its `PATH` environment variable.
*   **Permission Denied Errors**:
    *   Ensure your user is in the `docker` group (`sudo usermod -aG docker $USER` and then log out/in).
    *   Check that the user in your GitHub secrets has write permissions for the target directory (`~/app`).
*   **Firewall Issues**: DigitalOcean Droplets often have a firewall (`ufw`). Ensure it's configured to allow traffic on the ports your application uses.
    *   Example: `sudo ufw allow 80/tcp` and `sudo ufw allow 443/tcp`.
*   **Workflow Fails on `docker-compose down`**: The `|| true` at the end of the command should prevent this, but if it still fails, it might be a permissions issue.

## 7. Manual Deployment

If you need to deploy manually, follow these steps:

1.  **Publish Locally:**
    ```bash
    dotnet publish FutsalApi/FutsalApi.AppHost -c Release -o ./publish --publisher dockercompose
    ```
2.  **Copy Files to Server:**
    Use `scp` to copy the contents of the `publish` directory to `~/app` on your server.
    ```bash
    scp -r ./publish/* YOUR_USERNAME@YOUR_HOST:~/app/
    ```
3.  **Run Docker Compose:**
    SSH into your server, navigate to the app directory, and run:
    ```bash
    cd ~/app
    docker compose -p futsalapi up -d
    ```
