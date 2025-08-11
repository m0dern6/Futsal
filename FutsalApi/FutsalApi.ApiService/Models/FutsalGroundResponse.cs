using System;
using System.Collections.Generic;

namespace FutsalApi.ApiService.Models;

public class BookedTimeSlot
{
    public DateTime BookingDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
}

public class FutsalGroundResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string OwnerId { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public double AverageRating { get; set; }
    public int RatingCount { get; set; } = 0;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Description { get; set; } = string.Empty;
    public int? ImageId { get; set; }
    public string? ImageUrl { get; set; }
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
    public DateTime CreatedAt { get; set; }
    public int? BookingCount { get; set; } = 0;
    public string OwnerName { get; set; } = string.Empty;
    public double? DistanceKm { get; set; } // Distance from search coordinates in kilometers

    // New property for booked time slots
    public List<BookedTimeSlot> BookedTimeSlots { get; set; } = new();
}
