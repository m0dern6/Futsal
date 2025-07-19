# Futsal Suite

**Futsal** is a modular set of .NET microservices and APIs for managing futsal ground booking, payments, notifications, reviews, authentication, and more. This repository contains all source code, infrastructure, and tests for the Futsal platform.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup & Configuration](#setup--configuration)
- [Running Tests](#running-tests)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Overview

This solution is composed of multiple projects under the `FutsalApi` solution and related folders. For a detailed breakdown of the project structure, please see the [Project Structure](./Documentation/Project-Structure.md) documentation.

- **FutsalApi.ApiService** – Core HTTP API for bookings, payments, reviews, notifications, and more.
- **FutsalApi.AppHost** – Host configuration and orchestration layer.
- **FutsalApi.Auth** – Authentication and authorization microservice.
- **FutsalApi.Data** – Data access layer and EF Core migrations.
- **FutsalApi.ServiceDefaults** – Common service defaults and shared extensions.
- **FutsalApi.Tests** – Integration and endpoint tests for APIs.

## Architecture

Each service is organized as a .NET project (`.csproj`) and follows Clean Architecture principles.

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download)
- Docker
- Git

## Setup & Configuration

For detailed setup and installation instructions, please see the [Setup and Installation](./Documentation/Setup-and-Installation.md) guide.

## Running Tests

Execute all integration and endpoint tests:

```powershell
cd FutsalApi.Tests
dotnet test
```

## Documentation

This project includes the following documentation:

- **[API Endpoints](./Documentation/API-Endpoints.md)**: Detailed information about the API endpoints.
- **[Project Structure](./Documentation/Project-Structure.md)**: An overview of the project's directory structure.
- **[Setup and Installation](./Documentation/Setup-and-Installation.md)**: Instructions on how to set up and run the project locally.
- **[Deployment](./Documentation/Deployment.md)**: Information about the CI/CD pipeline and deployment process.
- **[Database Schema](./Documentation/DbSchema.png)**: A diagram of the database schema.

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to your branch: `git push origin feature/YourFeature`
5. Open a Pull Request.

Please follow the existing coding conventions and ensure all tests pass.

## License

This project is licensed under the [MIT License](LICENSE).