using FutsalApi.Core.Models;
using FutsalApi.ApiService.Repositories;

namespace FutsalApi.ApiService.Repositories
{
    public interface IImageRepository : IGenericRepository<Image>
    {
        // Add any image-specific repository methods here if needed
    }
}
