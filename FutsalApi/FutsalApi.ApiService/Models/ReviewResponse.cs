using System;

namespace FutsalApi.ApiService.Models;

public class ReviewResponse
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string UserImageUrl { get; set; } = string.Empty;
    public string ReviewImageUrl { get; set; } = string.Empty;
    public int GroundId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; }
}
