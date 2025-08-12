using System;
using System.Data;
using System.Linq.Expressions;
using Dapper;
using FutsalApi.Data.DTO;
using FutsalApi.Data.Models;
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
        return await _dbConnection.QueryAsync<PaymentResponse>(
            "SELECT * FROM get_payments_by_user_id(@p_user_id, @p_page, @p_page_size)",
            parameters,
            commandType: CommandType.Text);
    }

    public async Task<PaymentResponse?> GetPaymentByBookingIdAsync(Expression<Func<Payment, bool>> predicate)
    {
        if (_context.Payments == null)
            throw new InvalidOperationException("Payments DbSet is null.");

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
        return await _dbConnection.ExecuteScalarAsync<decimal>(
            "SELECT get_paid_amount(@p_booking_id)",
            parameters,
            commandType: CommandType.Text);
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
        var paymentId = await _dbConnection.ExecuteScalarAsync<int>(
            "SELECT create_payment(@p_amount_paid, @p_booking_id, @p_method, @p_status, @p_transaction_id)",
            parameters,
            commandType: CommandType.Text);
        var createdPayment = await GetByIdAsync(p => p.Id == paymentId);
        if (createdPayment == null)
            throw new InvalidOperationException("Payment creation failed.");
        return createdPayment;
    }
}
