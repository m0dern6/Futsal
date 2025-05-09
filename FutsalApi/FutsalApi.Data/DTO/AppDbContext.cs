using System;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.Data.DTO;

public class AppDbContext : DbContext
{

    public AppDbContext()
    {
    }

    public DbSet<FutsalGround>? FutsalGrounds { get; set; }
    public DbSet<Booking>? Bookings { get; set; }
    public DbSet<Payment>? Payments { get; set; }
    public DbSet<Notification>? Notifications { get; set; }
    public DbSet<Review>? Reviews { get; set; }
    public DbSet<Image>? Images { get; set; }
    public DbSet<GroundClosure>? GroundClosures { get; set; }
}
