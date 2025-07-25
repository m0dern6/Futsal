using System.Collections.Generic;

namespace FutsalApi.UI.Shared.Models
{
    public class NotificationListModel
    {
        public List<string> UserIds { get; set; } = new List<string>();
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
    }
}
