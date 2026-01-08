using FutsalApi.Data.DTO;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Services;

/// <summary>
/// Background service that automatically updates confirmed bookings to completed
/// when their scheduled time passes.
/// </summary>
public class BookingStatusUpdateService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<BookingStatusUpdateService> _logger;
    private readonly TimeSpan _checkInterval = TimeSpan.FromMinutes(5); // Check every 5 minutes

    public BookingStatusUpdateService(IServiceProvider serviceProvider, ILogger<BookingStatusUpdateService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Booking Status Update Service is starting.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await UpdateExpiredBookingsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while updating booking statuses.");
            }

            // Wait for the specified interval before checking again
            await Task.Delay(_checkInterval, stoppingToken);
        }

        _logger.LogInformation("Booking Status Update Service is stopping.");
    }

    private async Task UpdateExpiredBookingsAsync(CancellationToken cancellationToken)
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            // Get current UTC time
            var now = DateTime.UtcNow;
            var today = now.Date;

            // Find all confirmed bookings that have passed their end time
            var expiredBookings = await dbContext.Bookings
                .Where(b => b.Status == BookingStatus.Confirmed &&
                            b.BookingDate == today &&
                            b.EndTime < now.TimeOfDay)
                .ToListAsync(cancellationToken);

            if (expiredBookings.Count > 0)
            {
                _logger.LogInformation($"Found {expiredBookings.Count} confirmed bookings that have expired.");

                foreach (var booking in expiredBookings)
                {
                    booking.Status = BookingStatus.Completed;
                    booking.UpdatedAt = DateTime.UtcNow;
                    _logger.LogInformation($"Updated booking {booking.Id} status to Completed.");
                }

                await dbContext.SaveChangesAsync(cancellationToken);
                _logger.LogInformation($"Successfully updated {expiredBookings.Count} bookings to Completed status.");
            }
        }
    }
}
