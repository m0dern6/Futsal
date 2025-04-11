using System;

namespace FutsalApi.ApiService.Models;

public class NotificationListModel
{
    public required List<string> UserId { get; set; }
    public string Message { get; set; } = string.Empty;

}
