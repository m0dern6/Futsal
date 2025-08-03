using System;
using System.Data;
using System.Linq.Expressions;

using Dapper;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;

using Microsoft.EntityFrameworkCore;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Repositories;

public class FutsalGroundRepository : GenericRepository<FutsalGround>, IFutsalGroundRepository
{
    private readonly FutsalApi.Data.DTO.AppDbContext _dbContext;
    private readonly IDbConnection _dbConnection;

    public FutsalGroundRepository(FutsalApi.Data.DTO.AppDbContext dbContext, IDbConnection dbConnection) : base(dbContext)
    {
        _dbContext = dbContext;
        _dbConnection = dbConnection;
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
        var parameters = new { p_ground_id = groundId };
        await _dbConnection.ExecuteAsync("update_futsal_ground_rating", parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<FutsalGroundResponse>> SearchFutsalGroundsAsync(string? name, string? location, double? minRating, double? maxRating, int page, int pageSize)
    {
        var parameters = new
        {
            p_name = name,
            p_location = location,
            p_min_rating = minRating,
            p_max_rating = maxRating,
            p_page = page,
            p_page_size = pageSize
        };
        return await _dbConnection.QueryAsync<FutsalGroundResponse>(
            "SELECT * FROM search_futsal_grounds(@p_name, @p_location, @p_min_rating, @p_max_rating, @p_page, @p_page_size)",
            parameters,
            commandType: CommandType.Text);
    }
}
