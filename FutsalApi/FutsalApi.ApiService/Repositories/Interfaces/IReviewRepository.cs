using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Repositories;

/// <summary>
/// Interface for ReviewRepository, providing additional methods specific to Review.
/// </summary>
public interface IReviewRepository : IGenericrepository<Review>
{
    Task<IEnumerable<Review>> GetReviewsByGroundIdAsync(int groundId, int page = 1, int pageSize = 10);
    Task<bool> DeleteReviewByUserAsync(int reviewId, string userId);
}