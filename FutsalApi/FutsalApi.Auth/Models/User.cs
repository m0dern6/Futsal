using System;

using Microsoft.AspNetCore.Identity;

namespace FutsalApi.Auth.Models;

public class User : IdentityUser
{
    public string? ImageUrl { get; set; } = null;

}
