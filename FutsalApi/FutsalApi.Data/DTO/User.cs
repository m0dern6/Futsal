using System;

using Microsoft.AspNetCore.Identity;

namespace FutsalApi.Data.DTO;

public class User : IdentityUser
{
    public string? ImageUrl { get; set; } = null;

}
