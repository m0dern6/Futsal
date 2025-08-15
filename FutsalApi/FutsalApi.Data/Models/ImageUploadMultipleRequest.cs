﻿using Microsoft.AspNetCore.Http;
using FutsalApi.Data.DTO;

namespace FutsalApi.Data.Models;

public class ImageUploadMultipleRequest
{
    public List<IFormFile> Files { get; set; } = new List<IFormFile>();
    
}
