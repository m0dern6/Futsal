using FutsalApi.Data.DTO;
using FutsalApi.Data.Models;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

public class FavouriteFutsalGroundRepository : IFavouriteFutsalGroundRepository
{
    private readonly AppDbContext _dbContext;
    public FavouriteFutsalGroundRepository(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddFavouriteAsync(string userId, int groundId)
    {
        if (!await _dbContext.FavouriteFutsalGrounds.AnyAsync(f => f.UserId == userId && f.GroundId == groundId))
        {
            var fav = new FavouriteFutsalGround { UserId = userId, GroundId = groundId };
            _dbContext.FavouriteFutsalGrounds.Add(fav);
            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task RemoveFavouriteAsync(string userId, int groundId)
    {
        var fav = await _dbContext.FavouriteFutsalGrounds.FirstOrDefaultAsync(f => f.UserId == userId && f.GroundId == groundId);
        if (fav != null)
        {
            _dbContext.FavouriteFutsalGrounds.Remove(fav);
            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task<IEnumerable<FutsalGroundResponse>> GetFavouritesByUserIdAsync(string userId, int page = 1, int pageSize = 10)
    {
        var query = _dbContext.FavouriteFutsalGrounds
            .Where(f => f.UserId == userId)
            .OrderByDescending(f => f.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Include(f => f.Ground);

        return await query
            .Select(f => new FutsalGroundResponse
            {
                Id = f.Ground.Id,
                Name = f.Ground.Name,
                Location = f.Ground.Location,
                OwnerId = f.Ground.OwnerId,
                PricePerHour = f.Ground.PricePerHour,
                AverageRating = f.Ground.AverageRating,
                RatingCount = f.Ground.RatingCount,
                Latitude = f.Ground.Latitude,
                Longitude = f.Ground.Longitude,
                Description = f.Ground.Description,
                ImageUrl = f.Ground.ImageUrl,
                OpenTime = f.Ground.OpenTime,
                CloseTime = f.Ground.CloseTime,
                CreatedAt = f.Ground.CreatedAt,
                OwnerName = f.Ground.Owner.UserName
            })
            .ToListAsync();
    }

    public async Task<bool> IsFavouriteAsync(string userId, int groundId)
    {
        return await _dbContext.FavouriteFutsalGrounds.AnyAsync(f => f.UserId == userId && f.GroundId == groundId);
    }
}
