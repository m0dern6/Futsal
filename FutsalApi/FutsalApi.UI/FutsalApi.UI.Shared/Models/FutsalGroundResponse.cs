﻿namespace FutsalApi.UI.Shared.Models
{
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
        public string ImageUrl { get; set; } = string.Empty;
        public TimeSpan OpenTime { get; set; }
        public TimeSpan CloseTime { get; set; }
        public DateTime CreatedAt { get; set; }
        public string OwnerName { get; set; } = string.Empty;
        public double? DistanceKm { get; set; } // Distance from search coordinates in kilometers
    }
}
