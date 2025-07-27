using System;
using System.Data;
using System.Reflection;
using FutsalApi.ApiService.Repositories;
using Npgsql;

namespace FutsalApi.Auth.Infrastructure;

public static class RepositoryExtension
{
    public static IServiceCollection AddRepositories(this IServiceCollection services, Assembly assembly, IConfiguration configuration)
    {
        // Register all repositories in the assembly that inherits from GenericRepository
        var repositoryTypes = assembly.GetTypes()
            .Where(t => t.IsClass && !t.IsAbstract && t.BaseType != null && t.BaseType.IsGenericType && t.BaseType.GetGenericTypeDefinition() == typeof(GenericRepository<>));

        // Register each repository type with its corresponding interface
        foreach (var repositoryType in repositoryTypes)
        {
            var interfaceType = repositoryType.GetInterfaces().FirstOrDefault(i => !i.IsGenericType);
            if (interfaceType != null)
            {
                // Console.WriteLine($"Registering {interfaceType.Name} with {repositoryType.Name}");
                services.AddScoped(interfaceType, repositoryType);
            }
        }

        services.AddScoped<IDbConnection>(sp => new NpgsqlConnection(sp.GetRequiredService<IConfiguration>().GetConnectionString("futsaldb")));

        return services;
    }

}
