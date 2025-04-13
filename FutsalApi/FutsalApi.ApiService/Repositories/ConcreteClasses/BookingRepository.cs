using System;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

public class BookingRepository : GenericRepository<Booking>, IBookingRepository
{
    private readonly AppDbContext _dbContext;
    public BookingRepository(AppDbContext dbContext) : base(dbContext)
    {
        _dbContext = dbContext;
    }
    public async Task<IEnumerable<Booking>> GetBookingsByUserIdAsync(string userId, int page, int pageSize)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbContext.Bookings
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.BookingDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public override async Task<Booking> CreateAsync(Booking booking)
    {
        if (booking == null)
        {
            throw new ArgumentNullException(nameof(booking), "Booking cannot be null.");
        }
        //check if the time slot is already booked
        var existingBooking = await _dbContext.Bookings
            .FirstOrDefaultAsync(b => b.StartTime < booking.EndTime && b.EndTime > booking.StartTime && b.GroundId == booking.GroundId);
        if (existingBooking != null)
        {
            throw new InvalidOperationException("The selected time slot is already booked.");
        }

        return await base.CreateAsync(booking);
    }

}
