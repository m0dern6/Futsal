# Deployment Guide

This guide outlines the steps to deploy the Futsal API .NET Aspire application to a DigitalOcean server using Docker Compose and GitHub Actions for continuous integration and deployment (CI/CD).

## Overview

.NET Aspire applications use a different deployment model than traditional .NET apps. The `FutsalApi.AppHost` project, used for local development, is used to generate a `docker-compose.yml` file for production deployment.

The deployment process is automated using a GitHub Actions workflow. When code is pushed to the `master` branch, the following happens:

1.  A self-hosted runner on the DigitalOcean server picks up the job.
2.  The runner executes `dotnet publish` on the `FutsalApi.AppHost` project. This generates a `publish` directory containing a `docker-compose.yml` file and all necessary project assets.
3.  The workflow securely copies the contents of the `publish` directory to a designated folder (e.g., `/home/user/app`) on the DigitalOcean server.
4.  The workflow then uses SSH to connect to the server and runs `docker-compose up`, which reads the `docker-compose.yml` file to build, create, and start all the application's services.

## Prerequisites

*   A DigitalOcean account and a Droplet (server) running a Linux distribution (e.g., Ubuntu).
*   Docker and Docker Compose installed on your DigitalOcean Droplet.

## DigitalOcean Server Setup

### 1. Install Docker
SSH into your DigitalOcean Droplet and install Docker.

For Ubuntu, you can use the official convenience script:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
After installation, add your user to the `docker` group to run Docker commands without `sudo`:
```bash
sudo usermod -aG docker $USER
```
You will need to log out and log back in for this to take effect.

### 2. Install Docker Compose
Docker Compose is now a plugin for Docker. You can install it using your distribution's package manager.

For Ubuntu:
```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin
```
Verify the installation:
```bash
docker compose version
```

### 3. Install GitHub Actions Runner
Follow the instructions in the official GitHub documentation to [add a self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) to your DigitalOcean server. It is highly recommended to [configure the runner as a service](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service).

## GitHub Repository Configuration

For the CI/CD pipeline to access your DigitalOcean server, you must add the following secrets to your repository.

Navigate to your GitHub repository's **Settings > Secrets and variables > Actions** and add the following secrets:

*   `DO_HOST`: The public IP address of your DigitalOcean Droplet.
*   `DO_USERNAME`: The username for SSH access to your Droplet (e.g., `root` or another user).
*   `DO_PASSWORD`: The password for the user specified in `DO_USERNAME`.

## How the CI/CD Workflow Works

The workflow is defined in `.github/workflows/ci-cd.yaml`. It is triggered on every push to the `master` branch and performs the steps outlined in the "Overview" section.

The key steps are:
1.  `dotnet publish FutsalApi/FutsalApi.AppHost`: Generates the `docker-compose.yml` and project files.
2.  `scp`: Copies the published files to your server.
3.  `docker-compose up -d --build`: Starts your application stack in detached mode and rebuilds images if the source has changed.