using System;


using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.Data.DTO;

public class AppDbContext : IdentityDbContext<User, Role, string, IdentityUserClaim<string>, UserRole, IdentityUserLogin<string>, IdentityRoleClaim<string>, IdentityUserToken<string>>
{

    public AppDbContext(DbContextOptions<AppDbContext> options)
         : base(options)
    {
    }

    public DbSet<FutsalGround> FutsalGrounds { get; set; }
    public DbSet<Booking> Bookings { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<GeneralSetting> GeneralSettings { get; set; }
    public DbSet<Image> Images { get; set; }
    public DbSet<GroundClosure> GroundClosures { get; set; }
}
