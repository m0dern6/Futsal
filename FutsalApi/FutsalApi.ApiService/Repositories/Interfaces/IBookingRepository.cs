using System;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;

namespace FutsalApi.ApiService.Repositories;

public interface IBookingRepository : IGenericRepository<Booking>
{
    Task<IEnumerable<BookingResponse>> GetBookingsByUserIdAsync(string userId, int page, int pageSize);

}
