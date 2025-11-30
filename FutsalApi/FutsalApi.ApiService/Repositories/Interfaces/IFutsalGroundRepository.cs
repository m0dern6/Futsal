using System;
using System.Linq.Expressions;
using FutsalApi.Data.DTO;
using FutsalApi.Data.Models;

namespace FutsalApi.ApiService.Repositories;

public interface IFutsalGroundRepository : IGenericRepository<FutsalGround>
{
    new Task<IEnumerable<FutsalGroundResponse>> GetAllAsync(int page = 1, int pageSize = 10, string? userId = null);
    new Task<FutsalGroundResponse?> GetByIdAsync(Expression<Func<FutsalGround, bool>> predicate);
    Task UpdateRatingAsync(int groundId);
    Task<bool> HasActiveBookingsAsync(int groundId);
    Task<IEnumerable<FutsalGroundResponse>> SearchFutsalGroundsAsync(string? name, double? latitude, double? longitude, double? minRating, double? maxRating, int page, int pageSize);
    Task<IEnumerable<FutsalGroundResponse>> GetTrendingFutsalGroundsAsync(int page = 1, int pageSize = 10, string? userId = null);
    Task<IEnumerable<FutsalGroundResponse>> GetTopReviewedFutsalGroundsAsync(int page = 1, int pageSize = 10, string? userId = null);
}
