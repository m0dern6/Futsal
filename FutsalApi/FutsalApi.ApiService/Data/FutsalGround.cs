using System;

namespace FutsalApi.ApiService.Data;

public class FutsalGround
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public Guid OwnerId { get; set; }
    public decimal PricePerHour { get; set; }
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

