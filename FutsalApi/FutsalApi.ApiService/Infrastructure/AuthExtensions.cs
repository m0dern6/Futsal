﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using FutsalApi.ApiService.Infrastructure.Auth;
using FutsalApi.ApiService.Routes;
using FutsalApi.Data.Models;
using Microsoft.EntityFrameworkCore;
using FutsalApi.ApiService.Services;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Infrastructure;

public static class AuthExtensions
{
    public static IServiceCollection AddAuthConfig(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("futsaldb");

        // Add DbContext with PostgreSQL
        services.AddDbContext<AppDbContext>(options =>
           options.UseNpgsql(connectionString));

        // Add Authentication
        services.AddAuthentication().AddBearerToken(IdentityConstants.BearerScheme,
            options =>
            {
                options.BearerTokenExpiration = TimeSpan.FromDays(15);
                options.RefreshTokenExpiration = TimeSpan.FromDays(30);
            });
        //.AddGoogleAuthentication();

        // Add Authorization
        services.AddAuthorization(options =>
        {
            options.DefaultPolicy = new AuthorizationPolicyBuilder(
                IdentityConstants.BearerScheme,
                IdentityConstants.ApplicationScheme)
                .RequireAuthenticatedUser()
                .Build();
        });

        // Add Identity
        services.AddIdentity<User, Role>(options =>
        {
            options.User.RequireUniqueEmail = true;
            options.Password.RequiredLength = 6;
            options.Password.RequireDigit = false;
            options.Password.RequireLowercase = false;
            options.Password.RequireUppercase = false;
            options.Password.RequireNonAlphanumeric = false;
            options.SignIn.RequireConfirmedAccount = false;
            options.SignIn.RequireConfirmedPhoneNumber = false;
            options.SignIn.RequireConfirmedEmail = false;
        })
            .AddEntityFrameworkStores<AppDbContext>()
            .AddDefaultTokenProviders();

        // Add Permission Handler
        services.AddSingleton<IAuthorizationHandler, PermissionResourceHandler>();
        services.AddTransient<IEmailSender<User>, EmailSender>();

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

