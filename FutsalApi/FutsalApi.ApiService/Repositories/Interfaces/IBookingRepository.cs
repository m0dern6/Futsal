using System;
using System.Linq.Expressions;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;

namespace FutsalApi.ApiService.Repositories;

public interface IBookingRepository : IGenericRepository<Booking>
{
    Task<List<BookingResponse>> GetAllAsync(Expression<Func<Booking, bool>> predicate, int page, int pageSize);
    Task<IEnumerable<BookingResponse>> GetBookingsByUserIdAsync(string userId, int page, int pageSize);

}
