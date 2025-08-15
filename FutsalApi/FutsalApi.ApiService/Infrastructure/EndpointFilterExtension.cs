using System;

using Auth;
using FutsalApi.Data.Models;

namespace FutsalApi.ApiService.Infrastructure.Auth;

public static class EndpointFilterExtensions
{
    public static RouteHandlerBuilder RequirePermissionResource(this RouteHandlerBuilder builder, Permissions[] permissions, Resources resource)
    {
        return builder.AddEndpointFilter(new PermissionResourceFilter(permissions, resource));
    }

    public static RouteHandlerBuilder RequirePermissionResource(this RouteHandlerBuilder builder, Permissions permission, Resources resource)
    {
        return builder.RequirePermissionResource(new[] { permission }, resource);
    }
}
