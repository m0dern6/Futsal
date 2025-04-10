using FutsalApi.ApiService.Data;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

/// <summary>
/// Repository for managing Notification entities.
/// Inherits from GenericRepository and provides additional methods specific to Notification.
/// </summary>
public class NotificationRepository : GenericRepository<Notification>, INotificationRepository
{
    private readonly AppDbContext _dbContext;

    public NotificationRepository(AppDbContext dbContext) : base(dbContext)
    {
        _dbContext = dbContext;
    }

    /// <summary>
    /// Retrieves Notifications for a specific User with pagination.
    /// </summary>
    public async Task<IEnumerable<Notification>> GetNotificationsByUserIdAsync(string userId, int page = 1, int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbContext.Notifications
            .Where(r => r.UserId == userId)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    /// <summary>
    /// Deletes a Notification only if it belongs to the specified user.
    /// </summary>
    public async Task<bool> UpdateStatusByUserIdAsync(int NotificationId, string userId)
    {
        var Notification = await _dbContext.Notifications.FirstOrDefaultAsync(r => r.Id == NotificationId && r.UserId == userId);
        if (Notification == null)
        {
            return false;
        }
        Notification.IsRead = true;

        _dbContext.Notifications.Update(Notification);
        await _dbContext.SaveChangesAsync();
        return true;
    }
}