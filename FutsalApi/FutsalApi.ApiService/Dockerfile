# Use the official .NET 8 runtime as base image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8443

# Use the .NET 8 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy solution file and project files
COPY ["FutsalApi.sln", "./"]
COPY ["FutsalApi.ApiService/FutsalApi.ApiService.csproj", "FutsalApi.ApiService/"]
COPY ["FutsalApi.Auth/FutsalApi.Auth.csproj", "FutsalApi.Auth/"]
COPY ["FutsalApi.Data/FutsalApi.Data.csproj", "FutsalApi.Data/"]
COPY ["FutsalApi.ServiceDefaults/FutsalApi.ServiceDefaults.csproj", "FutsalApi.ServiceDefaults/"]

# Restore NuGet packages
RUN dotnet restore "FutsalApi.ApiService/FutsalApi.ApiService.csproj"

# Copy all source code
COPY . .

# Build the application
WORKDIR "/src/FutsalApi.ApiService"
RUN dotnet build "FutsalApi.ApiService.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "FutsalApi.ApiService.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage - runtime image
FROM base AS final
WORKDIR /app

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

# Copy the published application
COPY --from=publish /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Entry point
ENTRYPOINT ["dotnet", "FutsalApi.ApiService.dll"]
