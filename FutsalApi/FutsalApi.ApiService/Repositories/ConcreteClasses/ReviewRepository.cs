using System.Linq.Expressions;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;


public class ReviewRepository : GenericRepository<Review>, IReviewRepository
{
    private readonly AppDbContext _dbContext;

    public ReviewRepository(AppDbContext dbContext) : base(dbContext)
    {
        _dbContext = dbContext;
    }

    public new async Task<IEnumerable<ReviewResponse>> GetAllAsync(int page = 1, int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbContext.Reviews
            .OrderByDescending(r => r.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new ReviewResponse
            {
                Id = r.Id,
                UserId = r.UserId,
                GroundId = r.GroundId,
                Rating = r.Rating,
                UserName = r.User.UserName ?? string.Empty,
                UserImageUrl = r.User.ImageUrl ?? string.Empty,
                ReviewImageUrl = r.ImageUrl ?? string.Empty,
                Comment = r.Comment,
                CreatedAt = r.CreatedAt
            })
            .ToListAsync();
    }
    public new async Task<ReviewResponse?> GetByIdAsync(Expression<Func<Review, bool>> predicate)
    {
        var review = await _dbContext.Reviews
            .Where(predicate)
            .Select(r => new ReviewResponse
            {
                Id = r.Id,
                UserId = r.UserId,
                GroundId = r.GroundId,
                Rating = r.Rating,
                UserName = r.User.UserName ?? string.Empty,
                UserImageUrl = r.User.ImageUrl ?? string.Empty,
                ReviewImageUrl = r.ImageUrl ?? string.Empty,
                Comment = r.Comment,
                CreatedAt = r.CreatedAt
            })
            .FirstOrDefaultAsync();

        return review;
    }
    public async Task<IEnumerable<ReviewResponse>> GetReviewsByGroundIdAsync(int groundId, int page = 1, int pageSize = 10)
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
            .Select(r => new ReviewResponse
            {
                Id = r.Id,
                UserId = r.UserId,
                GroundId = r.GroundId,
                Rating = r.Rating,
                UserName = r.User.UserName ?? string.Empty,
                UserImageUrl = r.User.ImageUrl ?? string.Empty,
                ReviewImageUrl = r.ImageUrl ?? string.Empty,
                Comment = r.Comment,
                CreatedAt = r.CreatedAt
            })
            .ToListAsync();
    }


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