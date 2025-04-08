# Base image for GitHub Actions Runner
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for the runner
RUN useradd -m app && \
    echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /actions-runner

# Download and configure GitHub Actions Runner
RUN curl -o actions-runner-linux-x64-2.323.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.323.0/actions-runner-linux-x64-2.323.0.tar.gz
RUN echo "0dbc9bf5a58620fc52cb6cc0448abcca964a8d74b5f39773b7afcad9ab691e19  actions-runner-linux-x64-2.323.0.tar.gz" | shasum -a 256 -c
RUN tar xzf actions-runner-linux-x64-2.323.0.tar.gz && \
    rm actions-runner-linux-x64-2.323.0.tar.gz

# Fix permissions for the app user
RUN chown -R app:app /actions-runner

# Copy and configure entrypoint script
COPY entrypoint.sh /actions-runner/entrypoint.sh
RUN chmod +x /actions-runner/entrypoint.sh

USER app

# Entrypoint for the container
ENTRYPOINT ["/actions-runner/entrypoint.sh"]


# Instructions for building and running the Docker container:
# Step 1: Build the Docker image
# docker build -t futsal-app .

# Step 2: Run the container
# docker run -d -e RUNNER_URL=https://github.com/0Ankit0/Futsal -e RUNNER_TOKEN=<token> --name github-runner github-runner:latest