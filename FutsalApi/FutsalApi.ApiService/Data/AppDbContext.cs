using System;
using FutsalApi.Auth.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http; 
using System.Security.Claims; 
using Microsoft.EntityFrameworkCore.ChangeTracking; 
using System.Threading;
using System.Threading.Tasks;
using System.Linq;

namespace FutsalApi.ApiService.Data;

public class AppDbContext : IdentityDbContext<User, Role, string, IdentityUserClaim<string>, UserRole, IdentityUserLogin<string>, IdentityRoleClaim<string>, IdentityUserToken<string>>
{
    private readonly IHttpContextAccessor _httpContextAccessor; 

    public AppDbContext()
    {
    }

    public AppDbContext(DbContextOptions<AppDbContext> options, IHttpContextAccessor httpContextAccessor)
        : base(options)
    {
        _httpContextAccessor = httpContextAccessor; 
    }

    public DbSet<GeneralSetting> GeneralSettings { get; set; }
    public DbSet<FutsalGround>? FutsalGrounds { get; set; }
    public DbSet<Booking>? Bookings { get; set; }
    public DbSet<Payment>? Payments { get; set; }
    public DbSet<Notification>? Notifications { get; set; }
    public DbSet<Review>? Reviews { get; set; }
    public DbSet<Image>? Images { get; set; }
    public DbSet<GroundClosure>? GroundClosures { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<Image>().HasQueryFilter(i => !i.IsDeleted);

        builder.Entity<FutsalGround>()
            .HasOne(fg => fg.MainImage)
            .WithMany()
            .HasForeignKey(fg => fg.MainImageId)
            .IsRequired(false);

        builder.Entity<Review>()
            .HasOne(r => r.ReviewImage)
            .WithMany()
            .HasForeignKey(r => r.ReviewImageId)
            .IsRequired(false);

        builder.Entity<User>()
            .HasOne(u => u.ProfileImage)
            .WithMany()
            .HasForeignKey(u => u.ProfileImageId)
            .IsRequired(false);
    }

    public override int SaveChanges()
    {
        AddTimestamps();
        return base.SaveChanges();
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        AddTimestamps();
        return await base.SaveChangesAsync(cancellationToken);
    }

    private void AddTimestamps()
    {
        var entries = ChangeTracker
            .Entries()
            .Where(e => e.Entity is GeneralSetting || e.Entity is FutsalGround || e.Entity is Booking || e.Entity is Payment || e.Entity is Notification || e.Entity is Review || e.Entity is Image || e.Entity is GroundClosure && (
                    e.State == EntityState.Added
                    || e.State == EntityState.Modified));

        var currentUserId = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        foreach (var entityEntry in entries)
        {
            if (entityEntry.State == EntityState.Added)
            {
                if (entityEntry.Property("CreatedAt") != null)
                    entityEntry.Property("CreatedAt").CurrentValue = DateTime.UtcNow;
                if (entityEntry.Property("CreatedBy") != null)
                    entityEntry.Property("CreatedBy").CurrentValue = currentUserId;
            }
            else if (entityEntry.State == EntityState.Modified)
            {
                if (entityEntry.Property("UpdatedAt") != null)
                    entityEntry.Property("UpdatedAt").CurrentValue = DateTime.UtcNow;
                if (entityEntry.Property("UpdatedBy") != null)
                    entityEntry.Property("UpdatedBy").CurrentValue = currentUserId;
            }
        }
    }
}