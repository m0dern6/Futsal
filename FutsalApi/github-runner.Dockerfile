# Use official .NET 9 SDK image
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS base
EXPOSE 8080
EXPOSE 8081
ENV DEBIAN_FRONTEND=noninteractive

# Install tools required for GitHub Actions runner
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
# Create non-root user if it doesn't already exist
RUN id -u app &>/dev/null || useradd -m app && echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /actions-runner

# Download GitHub Actions runner
RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.323.0/actions-runner-linux-x64-2.323.0.tar.gz && \
    echo "0dbc9bf5a58620fc52cb6cc0448abcca964a8d74b5f39773b7afcad9ab691e19  actions-runner.tar.gz" | shasum -a 256 -c && \
    tar xzf actions-runner.tar.gz && rm actions-runner.tar.gz

# Copy solution and projects to /app
RUN mkdir /app
COPY ./FutsalApi.AppHost /app/FutsalApi.AppHost
COPY ./FutsalApi.ApiService /app/FutsalApi.ApiService
COPY ./FutsalApi.ServiceDefaults /app/FutsalApi.ServiceDefaults
COPY ./FutsalApi.Tests /app/FutsalApi.Tests
COPY ./FutsalApi.sln /app/

# Fix permissions
RUN chown -R app:app /actions-runner /app

# Copy entrypoint script
COPY entrypoint.sh /actions-runner/entrypoint.sh
RUN chmod +x /actions-runner/entrypoint.sh

USER app

ENTRYPOINT ["/actions-runner/entrypoint.sh"]


# Instructions for building and running the Docker container:
# Step 1: Build the Docker image
# docker build -t github-runner-futsal -f github-runner.Dockerfile .

# Step 2: Run the container
# docker run -d -e RUNNER_URL=https://github.com/0Ankit0/Futsal -e RUNNER_TOKEN=<token> --name github-runner-futsal github-runner-futsal:latest
