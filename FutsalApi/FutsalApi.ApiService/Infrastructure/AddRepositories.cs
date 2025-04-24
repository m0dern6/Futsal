using System;
using System.Reflection;

using FutsalApi.ApiService.Repositories;

namespace FutsalApi.Auth.Infrastructure;

public static class RepositoryExtension
{
    public static IServiceCollection AddRepositories(this IServiceCollection services, Assembly assembly)
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
        return services;
    }

}
