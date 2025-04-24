using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FutsalApi.Data.DTO;
public enum ImageEntityType
{
    Review,
    Ground,
    User
}
public class Image
{

    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public string Url { get; set; } = default!;
    public ImageEntityType EntityType { get; set; }
    public string? EntityId { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
}
