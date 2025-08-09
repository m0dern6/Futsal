using System;

using Microsoft.AspNetCore.Identity;

namespace FutsalApi.Auth.Models;

public class User : IdentityUser
{
    public int? ProfileImageId { get; set; } = null;

}
