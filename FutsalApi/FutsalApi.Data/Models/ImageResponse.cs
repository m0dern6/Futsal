namespace FutsalApi.Data.Models;

public class ImageResponse
{
    public int Id { get; set; }
    public string Url { get; set; } = default!;
    
    public DateTime UploadedAt { get; set; }
}
