using System;

namespace FutsalApi.ApiService.Models;

public class ReviewRequest
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int GroundId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public int? ImageId { get; set; }
}

