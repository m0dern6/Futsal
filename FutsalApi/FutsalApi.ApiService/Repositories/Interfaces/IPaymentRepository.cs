using System;
using System.Linq.Expressions;

using FutsalApi.Data.DTO;
using FutsalApi.ApiService.Models;

namespace FutsalApi.ApiService.Repositories;

public interface IPaymentRepository : IGenericRepository<Payment>
{
    Task<IEnumerable<PaymentResponse>> GetPaymentsByUserIdAsync(string userId, int page, int pageSize);
    Task<PaymentResponse?> GetPaymentByBookingIdAsync(Expression<Func<Payment, bool>> predicate);
    Task<decimal> GetPaidAmountAsync(int bookingId);
    Task<Payment> CreatePaymentAsync(Payment payment);
}
