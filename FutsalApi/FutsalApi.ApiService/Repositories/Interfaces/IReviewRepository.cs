using System.Linq.Expressions;
using FutsalApi.Data.DTO;
using FutsalApi.ApiService.Models;

namespace FutsalApi.ApiService.Repositories;

/// <summary>
/// Interface for ReviewRepository, providing additional methods specific to Review.
/// </summary>
public interface IReviewRepository : IGenericRepository<Review>
{
    new Task<ReviewResponse?> GetByIdAsync(Expression<Func<Review, bool>> predicate);
    new Task<IEnumerable<ReviewResponse>> GetAllAsync(int page = 1, int pageSize = 10);
    Task<IEnumerable<ReviewResponse>> GetReviewsByGroundIdAsync(int groundId, int page = 1, int pageSize = 10);
    Task<bool> DeleteReviewByUserAsync(int reviewId, string userId);
}
