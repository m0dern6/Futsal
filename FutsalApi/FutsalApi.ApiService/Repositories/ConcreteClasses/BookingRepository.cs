using System;
using System.Data;
using System.Linq.Expressions;
using Dapper;
using FutsalApi.Data.DTO;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

public class BookingRepository : GenericRepository<Booking>, IBookingRepository
{
    private readonly AppDbContext _dbContext;
    private readonly IDbConnection _dbConnection;

    public BookingRepository(AppDbContext dbContext, IDbConnection dbConnection) : base(dbContext)
    {
        _dbContext = dbContext;
        _dbConnection = dbConnection;
    }

    public async Task<List<BookingResponse>> GetAllAsync(Expression<Func<Booking, bool>> predicate, int page, int pageSize)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbContext.Bookings
            .Where(predicate)
            .OrderByDescending(r => r.BookingDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(e => new BookingResponse
            {
                Id = e.Id,
                BookingDate = e.BookingDate,
                StartTime = e.StartTime,
                EndTime = e.EndTime,
                Status = e.Status,
                TotalAmount = e.TotalAmount,
                CreatedAt = e.CreatedAt,
                GroundName = e.Ground.Name
            })
            .ToListAsync();
    }

    public async Task<IEnumerable<BookingResponse>> GetBookingsByUserIdAsync(string userId, int page, int pageSize)
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
            .Select(e => new BookingResponse
            {
                Id = e.Id,
                BookingDate = e.BookingDate,
                StartTime = e.StartTime,
                EndTime = e.EndTime,
                Status = e.Status,
                TotalAmount = e.TotalAmount,
                CreatedAt = e.CreatedAt,
                GroundName = e.Ground.Name
            })
            .ToListAsync();
    }

    public async Task<int> CreateBookingAsync(Booking booking)
    {
        if (booking == null)
        {
            throw new ArgumentNullException(nameof(booking), "Booking cannot be null.");
        }

        var parameters = new DynamicParameters();
        parameters.Add("p_user_id", booking.UserId);
        parameters.Add("p_ground_id", booking.GroundId);
        parameters.Add("p_booking_date", booking.BookingDate);
        parameters.Add("p_start_time", booking.StartTime);
        parameters.Add("p_end_time", booking.EndTime);
        parameters.Add("p_total_amount", booking.TotalAmount);

        return await _dbConnection.ExecuteScalarAsync<int>("create_booking", parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<bool> CancelBookingAsync(int bookingId, string userId)
    {
        var parameters = new { p_booking_id = bookingId, p_user_id = userId };
        return await _dbConnection.ExecuteScalarAsync<bool>("cancel_booking", parameters, commandType: CommandType.StoredProcedure);
    }
}
