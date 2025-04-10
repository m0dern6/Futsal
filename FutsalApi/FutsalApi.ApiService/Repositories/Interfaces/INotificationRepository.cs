using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Repositories;

/// <summary>
/// Interface for NotificationRepository, providing additional methods specific to Notification.
/// </summary>
public interface INotificationRepository : IGenericrepository<Notification>
{
    Task<IEnumerable<Notification>> GetNotificationsByUserIdAsync(string userId, int page = 1, int pageSize = 10);
    Task<bool> UpdateStatusByUserIdAsync(int notificationId, string userId);
}