# Futsal Suite

**Futsal** is a modular set of .NET microservices and APIs for managing futsal ground booking, payments, notifications, reviews, authentication, and more. This repository contains all source code, infrastructure, and tests for the Futsal platform.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup & Configuration](#setup--configuration)
- [Running Services](#running-services)
- [Running Tests](#running-tests)
- [Documentation](#documentation)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## Overview

This solution is composed of multiple projects under the `FutsalApi` solution and related folders:

- **FutsalApi.ApiService** – Core HTTP API for bookings, payments, reviews, notifications, and more.
- **FutsalApi.AppHost** – Host configuration and orchestration layer.
- **FutsalApi.Auth** – Authentication and authorization microservice.
- **FutsalApi.Data** – Data access layer and EF Core migrations.
- **FutsalApi.ServiceDefaults** – Common service defaults and shared extensions.
- **FutsalApi.Tests** – Integration and endpoint tests for APIs.

## Architecture

Each service is organized as a .NET project (`.csproj`) and follows Clean Architecture principles:

1. **Models** – Request/response DTOs.
2. **Validators** – FluentValidation rules.
3. **Repositories** – Data persistence interfaces and implementations.
4. **Services** – Business logic.
5. **Routes** – Minimal API or controller endpoints.
6. **Infrastructure** – Shared utilities and setup.

## Prerequisites

- [.NET 7 SDK](https://dotnet.microsoft.com/download)
- SQL Server or compatible database for persistence
- PowerShell (Windows) or Bash (Linux/macOS)

## Setup & Configuration

1. **Clone the repository**

   ```powershell
   git clone https://github.com/0Ankit0/Futsal.git
   cd Futsal
   ```

2. **Configure connection strings**

   Update `appsettings.json` and `appsettings.Development.json` in each project (`ApiService`, `Auth`, etc.) with your database connection strings and any third-party API keys.

3. **Apply database migrations**

   ```powershell
   cd FutsalApi.Data
   dotnet ef database update --project . --startup-project ../FutsalApi.ApiService
   ```

4. **Restore dependencies**

   ```powershell
   dotnet restore FutsalApi.sln
   ```

## Running Services

From the solution root, you can run individual services using the .NET CLI or your IDE of choice.

- **API Service**

  ```powershell
  cd FutsalApi.ApiService
  dotnet run
  ```

- **Authentication Service**

  ```powershell
  cd FutsalApi.Auth
  dotnet run
  ```

- **App Host**
  ```powershell
  cd FutsalApi.AppHost
  dotnet run
  ```

Other services follow the same pattern.

## Running Tests

Execute all integration and endpoint tests:

```powershell
cd FutsalApi.Tests
dotnet test
```

## Documentation

- API reference and OpenAPI definitions are available under `Documentation/API-Documentation.md`.
- Database schema diagram: `Documentation/DbSchema.png`.

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions and environment-specific configurations.

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m "Add your feature"
4. Push to your branch: `git push origin feature/YourFeature`
5. Open a Pull Request.

Please follow the existing coding conventions and ensure all tests pass.

## License

This project is licensed under the [MIT License](LICENSE).
