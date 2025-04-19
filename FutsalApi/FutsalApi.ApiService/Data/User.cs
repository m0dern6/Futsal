using System;

using Microsoft.AspNetCore.Identity;

namespace FutsalApi.ApiService.Data;

public class User : IdentityUser
{
    public string? ImageUrl { get; set; } = null;

}
