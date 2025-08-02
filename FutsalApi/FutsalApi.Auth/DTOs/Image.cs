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
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    public string FilePath { get; set; } = default!;
    public string FileName { get; set; } = default!;
    public string FileType { get; set; } = default!;
    public long Size { get; set; }
    public string UserId { get; set; } = default!;
    public bool IsDeleted { get; set; }
}
