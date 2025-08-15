using System;

namespace FutsalApi.Data.Models;

public class NotificationResponse
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public bool IsRead { get; set; } = false;
    public DateTime? ReadAt { get; set; } = null;
    public DateTime CreatedAt { get; set; }
}
