using System;

namespace FutsalApi.ApiService.Models;

public class NotificationListModel
{
    public required List<string> UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;

}
