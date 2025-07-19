using FutsalApi.Auth.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.Auth;

public class AuthDbContext : IdentityDbContext<User, Role, string, IdentityUserClaim<string>, UserRole, IdentityUserLogin<string>, IdentityRoleClaim<string>, IdentityUserToken<string>>
{
    public AuthDbContext(DbContextOptions<AuthDbContext> options)
        : base(options)
    {

    }
}
