using System;

namespace FutsalApi.ApiService.Data;

public class Review
{
    public int Id { get; set; }
    public Guid UserId { get; set; }
    public int GroundId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

