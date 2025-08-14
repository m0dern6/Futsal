using FutsalApi.Data.DTO;
using FutsalApi.Data.Models;

namespace FutsalApi.ApiService.Repositories;

public interface IFavouriteFutsalGroundRepository
{
    Task AddFavouriteAsync(string userId, int groundId);
    Task RemoveFavouriteAsync(string userId, int groundId);
    Task<IEnumerable<FutsalGroundResponse>> GetFavouritesByUserIdAsync(string userId, int page = 1, int pageSize = 10);
    Task<bool> IsFavouriteAsync(string userId, int groundId);
}
