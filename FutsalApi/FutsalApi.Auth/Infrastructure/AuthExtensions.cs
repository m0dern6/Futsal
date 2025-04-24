using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using global::FutsalApi.ApiService.Infrastructure.Auth;
using global::FutsalApi.Data.DTO;
using FutsalApi.Auth.Routes;

namespace FutsalApi.Auth.Infrastructure;

public static class AuthExtensions
{
    public static IServiceCollection AddAuthConfig(this IServiceCollection services)
    {
        // Add Authentication
        services.AddAuthentication().AddBearerToken(IdentityConstants.BearerScheme,
            options =>
            {
                options.BearerTokenExpiration = TimeSpan.FromDays(1);
                options.RefreshTokenExpiration = TimeSpan.FromDays(30);
            })
            .AddGoogleAuthentication();

        // Add Authorization
        services.AddAuthorization(options =>
        {
            options.DefaultPolicy = new AuthorizationPolicyBuilder(IdentityConstants.BearerScheme)
                .RequireAuthenticatedUser()
                .Build();
        });

        // Add Identity
        services.AddIdentity<User, Role>()
            .AddEntityFrameworkStores<AppDbContext>()
            .AddDefaultTokenProviders();

        // Add Permission Handler
        services.AddSingleton<IAuthorizationHandler, PermissionResourceHandler>();

        return services;
    }

    public static IApplicationBuilder UseAuthConfig(this IApplicationBuilder app, IEndpointRouteBuilder endpoints)
    {
        app.UseAuthentication();
        app.UseAuthorization();

        // Map routes from Auth.cs
        var authApiEndpoints = new AuthApiEndpointRouteBuilderExtensions();
        authApiEndpoints.MapEndpoint(endpoints);

        // Map routes from UserRoles.cs
        var userRolesApiEndpoints = new UserRolesApiEndpoints();
        userRolesApiEndpoints.MapEndpoint(endpoints);

        //Map routes from Roles.cs
        var roles = new RolesApiEndpoints();
        roles.MapEndpoint(endpoints);

        return app;
    }
}

