using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;



namespace FutsalApi.Data.DTO;

public class Review
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int GroundId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; } = null;
    public string? ImageUrl { get; set; } = null;
    [ForeignKey(nameof(UserId))]
    public User User { get; set; } = null!;
    [ForeignKey(nameof(GroundId))]
    public FutsalGround Ground { get; set; } = null!;
}

