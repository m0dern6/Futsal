using System;
using System.Linq.Expressions;

using FutsalApi.Data.DTO;
using FutsalApi.ApiService.Models;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

public class FutsalGroundRepository : GenericRepository<FutsalGround>, IFutsalGroundRepository
{
    private readonly AppDbContext _dbContext;
    public FutsalGroundRepository(AppDbContext dbContext) : base(dbContext)
    {
        _dbContext = dbContext;
    }
    public async new Task<IEnumerable<FutsalGroundResponse>> GetAllAsync(int page = 1, int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbContext.FutsalGrounds
            .OrderByDescending(g => g.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(g => new FutsalGroundResponse
            {
                Id = g.Id,
                Name = g.Name,
                Location = g.Location,
                OwnerId = g.OwnerId,
                PricePerHour = g.PricePerHour,
                OpenTime = g.OpenTime,
                CloseTime = g.CloseTime,
                ImageUrl = g.ImageUrl,
                Description = g.Description,
                Latitude = g.Latitude,
                Longitude = g.Longitude,
                RatingCount = g.RatingCount,
                CreatedAt = g.CreatedAt,
                AverageRating = g.AverageRating,
                OwnerName = g.Owner.UserName!
            })
            .ToListAsync();
    }
    public async Task<bool> HasActiveBookingsAsync(int groundId)
    {
        return await _dbContext.Bookings
            .AnyAsync(b => b.GroundId == groundId && (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed));

    }
    public async new Task<FutsalGroundResponse?> GetByIdAsync(Expression<Func<FutsalGround, bool>> predicate)
    {
        return await _dbContext.FutsalGrounds
            .Where(predicate)
            .Select(g => new FutsalGroundResponse
            {
                Id = g.Id,
                Name = g.Name,
                Location = g.Location,
                OwnerId = g.OwnerId,
                PricePerHour = g.PricePerHour,
                OpenTime = g.OpenTime,
                CloseTime = g.CloseTime,
                ImageUrl = g.ImageUrl,
                Description = g.Description,
                Latitude = g.Latitude,
                Longitude = g.Longitude,
                RatingCount = g.RatingCount,
                CreatedAt = g.CreatedAt,
                AverageRating = g.AverageRating,
                OwnerName = g.Owner.UserName!
            })
            .FirstOrDefaultAsync();
    }
    public async Task UpdateRatingAsync(int groundId)
    {
        var ground = await _dbContext.FutsalGrounds.FindAsync(groundId);
        if (ground == null) return;

        var ratingsQuery = _dbContext.Reviews.Where(r => r.GroundId == groundId);

        ground.RatingCount = await ratingsQuery.CountAsync();
        ground.AverageRating = ground.RatingCount > 0
            ? await ratingsQuery.AverageAsync(r => r.Rating)
            : 0;

        _dbContext.FutsalGrounds.Update(ground);
        await _dbContext.SaveChangesAsync();
    }

}
