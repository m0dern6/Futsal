using System;
using System.Linq.Expressions;
using FutsalApi.Data.DTO;
using FutsalApi.Data.Models;

namespace FutsalApi.ApiService.Repositories;

public interface IBookingRepository : IGenericRepository<Booking>
{
    Task<List<BookingResponse>> GetAllAsync(Expression<Func<Booking, bool>> predicate, int page, int pageSize);
    Task<IEnumerable<BookingResponse>> GetBookingsByUserIdAsync(string userId, int page, int pageSize);
    Task<int> CreateBookingAsync(Booking booking);
    Task<bool> CancelBookingAsync(int bookingId, string userId);
    Task<Booking?> GetBookingByIdAndUserIdAsync(int id, string userId);
    Task<bool> HasValidBookingForReviewAsync(int groundId, string userId);
}
