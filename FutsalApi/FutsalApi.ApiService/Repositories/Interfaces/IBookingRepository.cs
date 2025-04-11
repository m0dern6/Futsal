using System;

using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Repositories;

public interface IBookingRepository : IGenericrepository<Booking>
{
    Task<IEnumerable<Booking>> GetBookingsByUserIdAsync(string userId, int page, int pageSize);

}
