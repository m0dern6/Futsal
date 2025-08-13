
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Repositories
{
    public interface IImageRepository : IGenericRepository<Image>
    {
        void Add(Image image);
        void Update(Image image);
        Task SaveChangesAsync();
        IQueryable<Image> Where(System.Linq.Expressions.Expression<System.Func<Image, bool>> predicate);
        Task<List<Image>> GetImagesByUserIdAsync(string userId);
    }
}
