using FutsalApi.ApiService.Models;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Services;

public interface IImageService
{
    Task<ImageResponse> UploadImageAsync(ImageUploadRequest request);
    Task<List<ImageResponse>> UploadMultipleImagesAsync(ImageUploadMultipleRequest request);
    Task<bool> DeleteImageAsync(int imageId);
    Task<bool> DeleteMultipleImagesAsync(List<int> imageIds);
    Task<List<ImageResponse>> GetImagesAsync();
}
