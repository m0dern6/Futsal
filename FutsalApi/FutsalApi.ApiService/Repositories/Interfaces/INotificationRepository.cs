
using FutsalApi.Data.DTO;
using FutsalApi.Data.Models;

namespace FutsalApi.ApiService.Repositories;

/// <summary>
/// Interface for NotificationRepository, providing additional methods specific to Notification.
/// </summary>
public interface INotificationRepository : IGenericRepository<Notification>
{
    Task<IEnumerable<NotificationResponse>> GetNotificationsByUserIdAsync(string userId, int page = 1, int pageSize = 10);
    Task<bool> UpdateStatusByUserIdAsync(int notificationId, string userId);
    Task SendNotificationToMultipleUsersAsync(NotificationListModel notificationListModel);
}
