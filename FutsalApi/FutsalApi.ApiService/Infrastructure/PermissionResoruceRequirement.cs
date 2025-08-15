﻿using System;

using Auth;

using Microsoft.AspNetCore.Authorization;

namespace FutsalApi.ApiService.Infrastructure.Auth;

public class PermissionResourceRequirement : IAuthorizationRequirement
{
    public Permissions Permission { get; }
    public Resources Resource { get; }

    public PermissionResourceRequirement(Permissions permission, Resources resource)
    {
        Permission = permission;
        Resource = resource;
    }
}
