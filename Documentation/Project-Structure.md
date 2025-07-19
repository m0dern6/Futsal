# Project Structure

This document provides an overview of the project's directory structure.

```
Futsal/
├── .github/                # GitHub Actions workflows
│   └── workflows/
│       └── ci-cd.yaml      # CI/CD pipeline for continuous integration and deployment
├── Documentation/          # Project documentation
│   ├── API-Documentation.md # Detailed information about the API endpoints
│   ├── DbSchema.png        # Database schema diagram
│   ├── Proposal.docx       # Initial project proposal
│   └── Research.docx       # Research materials
└── FutsalApi/              # Main solution folder
    ├── FutsalApi.sln       # Visual Studio solution file
    ├── FutsalApi.ApiService/ # API service project
    │   ├── Repositories/     # Data access layer
    │   ├── Models/           # API request and response models
    │   ├── Routes/           # API endpoint definitions
    │   └── ...
    ├── FutsalApi.AppHost/    # Aspire AppHost project for orchestration
    ├── FutsalApi.Auth/       # Authentication service project
    │   ├── Models/           # User and role models
    │   ├── Routes/           # Authentication-related API endpoints
    │   └── ...
    ├── FutsalApi.Data/       # Data access project
    │   ├── DTO/              # Database entity models
    │   └── Migrations/       # Entity Framework migrations
    ├── FutsalApi.ServiceDefaults/ # Shared service defaults
    └── FutsalApi.Tests/      # Unit and integration tests
```
