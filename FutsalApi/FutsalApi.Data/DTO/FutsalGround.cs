using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FutsalApi.Data.DTO;

public class FutsalGround
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string OwnerId { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Description { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public double AverageRating { get; set; } = 0.0;
    public int RatingCount { get; set; } = 0;
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; } = null;
    public bool IsActive { get; set; } = true;

    [ForeignKey(nameof(OwnerId))]
    public User Owner { get; set; } = null!;
}

