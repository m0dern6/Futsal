using System;

namespace FutsalApi.ApiService.Models;

public class FutsalGroundRequest
{
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public required string OwnerId { get; set; }
    public decimal PricePerHour { get; set; }
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }


}
