# Deployment

This document details the CI/CD pipeline and deployment process.

## CI/CD Pipeline

The project uses a GitHub Actions workflow defined in `.github/workflows/ci-cd.yaml` to automate the build, test, and deployment process. The pipeline is triggered on every push to the `master` branch.

### Workflow Steps

1.  **Check out code**: Checks out the latest code from the repository.
2.  **Generate Docker Compose**: Uses Aspire to generate a `docker-compose.yml` file for the application and its dependencies.
3.  **Deploy Application**: Deploys the application to the server using Docker Compose. This step does the following:
    *   Creates the application directory on the server.
    *   Stops and removes any existing containers.
    *   Copies the new `docker-compose.yml` file to the server.
    *   Starts the new containers in detached mode.
    *   Verifies that the deployment was successful.

## Manual Deployment

To deploy the application manually, you can follow these steps:

1.  **Generate the Docker Compose file:**

    ```bash
    cd FutsalApi/FutsalApi.AppHost
    aspirate generate --output-format compose --output-path ../../publish
    ```

2.  **Copy the `docker-compose.yml` file to your server.**

3.  **SSH into your server and run the following command:**

    ```bash
    docker-compose up -d
    ```
