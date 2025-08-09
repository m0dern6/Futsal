using Microsoft.AspNetCore.Http;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Models;

public class ImageUploadRequest
{
    public IFormFile File { get; set; } = default!;
    
}
