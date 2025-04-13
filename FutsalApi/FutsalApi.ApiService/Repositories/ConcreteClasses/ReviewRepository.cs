using FutsalApi.ApiService.Data;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

/// <summary>
/// Repository for managing Review entities.
/// Inherits from GenericRepository and provides additional methods specific to Review.
/// </summary>
public class ReviewRepository : GenericRepository<Review>, IReviewRepository
{
    private readonly AppDbContext _dbContext;

    public ReviewRepository(AppDbContext dbContext) : base(dbContext)
    {
        _dbContext = dbContext;
    }

    /// <summary>
    /// Retrieves reviews for a specific ground with pagination.
    /// </summary>
    public async Task<IEnumerable<Review>> GetReviewsByGroundIdAsync(int groundId, int page = 1, int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbContext.Reviews
            .Where(r => r.GroundId == groundId)
            .OrderByDescending(r => r.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    /// <summary>
    /// Deletes a review only if it belongs to the specified user.
    /// </summary>
    public async Task<bool> DeleteReviewByUserAsync(int reviewId, string userId)
    {
        var review = await _dbContext.Reviews.FirstOrDefaultAsync(r => r.Id == reviewId && r.UserId == userId);
        if (review == null)
        {
            return false;
        }

        _dbContext.Reviews.Remove(review);
        await _dbContext.SaveChangesAsync();
        return true;
    }
}