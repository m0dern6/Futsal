using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Repositories.Interfaces;

public interface IImageRepository
{
    Task<Image> AddImageAsync(Image image);
    Task<Image?> GetImageByIdAsync(int imageId);
    Task<bool> DeleteImageAsync(int imageId);
    Task<List<Image>> GetAllImagesAsync();
}
