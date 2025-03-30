using System;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Data;

public class AppDbContext : IdentityDbContext<User, Roles, string>
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
}
