using System;
using System.Linq.Expressions;

using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Repositories;

public interface IPaymentRepository : IGenericRepository<Payment>
{
    Task<IEnumerable<Payment>> GetPaymentsByUserIdAsync(string bookingId, int page, int pageSize);
    Task<Payment> GetPaymentByBookingIdAsync(int bookingId);
}
