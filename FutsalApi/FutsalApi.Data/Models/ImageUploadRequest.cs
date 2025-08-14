using Microsoft.AspNetCore.Http;
using FutsalApi.Data.DTO;

namespace FutsalApi.Data.Models;

public class ImageUploadRequest
{
    public IFormFile File { get; set; } = default!;
    
}
