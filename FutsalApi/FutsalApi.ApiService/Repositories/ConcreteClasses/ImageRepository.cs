using FutsalApi.Data.DTO;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories
{
    public class ImageRepository : GenericRepository<Image>, IImageRepository
    {
        private readonly FutsalApi.Data.DTO.AppDbContext _context;
        public ImageRepository(FutsalApi.Data.DTO.AppDbContext context) : base(context)
        {
            _context = context;
        }

        public void Add(Image image)
        {
            _context.Images?.Add(image);
        }

        public void Update(Image image)
        {
            _context.Images?.Update(image);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
        public bool Delete(Image image)
        {
            if (image != null)
            {
                _context.Images?.Remove(image);
                return true;
            }
            return false;
        }

        public IQueryable<Image> Where(System.Linq.Expressions.Expression<System.Func<Image, bool>> predicate)
        {
            return _context.Images?.Where(predicate) ?? Enumerable.Empty<Image>().AsQueryable();
        }

        public async Task<List<Image>> GetImagesByUserIdAsync(string userId)
        {
            return await (_context.Images?.Where(i => i.UserId == userId && !i.IsDeleted).ToListAsync() ?? Task.FromResult(new List<Image>()));
        }
    }
}
