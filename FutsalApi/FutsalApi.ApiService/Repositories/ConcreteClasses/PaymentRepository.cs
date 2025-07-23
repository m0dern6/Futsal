using System;
using System.Data;
using System.Linq.Expressions;
using Dapper;
using FutsalApi.Data.DTO;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

public class PaymentRepository : GenericRepository<Payment>, IPaymentRepository
{
    private readonly AppDbContext _context;
    private readonly IDbConnection _dbConnection;

    public PaymentRepository(AppDbContext context, IDbConnection dbConnection) : base(context)
    {
        _context = context;
        _dbConnection = dbConnection;
    }

    public async Task<IEnumerable<PaymentResponse>> GetPaymentsByUserIdAsync(string userId, int page, int pageSize)
    {
        var parameters = new
        {
            p_user_id = userId,
            p_page = page,
            p_page_size = pageSize
        };
        return await _dbConnection.QueryAsync<PaymentResponse>("get_payments_by_user_id", parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<PaymentResponse?> GetPaymentByBookingIdAsync(Expression<Func<Payment, bool>> predicate)
    {
        return await _context.Payments
            .Where(predicate)
            .Select(p => new PaymentResponse
            {
                Id = p.Id,
                AmountPaid = p.AmountPaid,
                PaymentDate = p.PaymentDate,
                RemainingAmount = p.Booking.TotalAmount - p.AmountPaid,
                BookingId = p.BookingId,
                Method = p.Method,
                Status = p.Status,
                TransactionId = p.TransactionId
            })
            .FirstOrDefaultAsync();
    }

    public async Task<decimal> GetPaidAmountAsync(int bookingId)
    {
        var parameters = new { p_booking_id = bookingId };
        return await _dbConnection.ExecuteScalarAsync<decimal>("get_paid_amount", parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<Payment> CreatePaymentAsync(Payment payment)
    {
        var parameters = new
        {
            p_amount_paid = payment.AmountPaid,
            p_booking_id = payment.BookingId,
            p_method = payment.Method,
            p_status = payment.Status,
            p_transaction_id = payment.TransactionId
        };

        var paymentId = await _dbConnection.ExecuteScalarAsync<int>("create_payment", parameters, commandType: CommandType.StoredProcedure);
        return await GetByIdAsync(p => p.Id == paymentId);
    }
}
