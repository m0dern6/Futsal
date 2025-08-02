using FutsalApi.Data.DTO;
using FutsalApi.ApiService.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories.ConcreteClasses;

public class ImageRepository : IImageRepository
{
    private readonly AppDbContext _dbContext;

    public ImageRepository(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<Image> AddImageAsync(Image image)
    {
        _dbContext.Images.Add(image);
        await _dbContext.SaveChangesAsync();
        return image;
    }

    public async Task<Image?> GetImageByIdAsync(int imageId)
    {
        return await _dbContext.Images.FindAsync(imageId);
    }

    public async Task<bool> DeleteImageAsync(int imageId)
    {
        var image = await _dbContext.Images.FindAsync(imageId);
        if (image == null)
        {
            return false;
        }

        _dbContext.Images.Remove(image);
        await _dbContext.SaveChangesAsync();
        return true;
    }

    public async Task<List<Image>> GetAllImagesAsync()
    {
        return await _dbContext.Images.ToListAsync();
    }
}
