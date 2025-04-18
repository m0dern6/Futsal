using System;
using System.Linq.Expressions;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

public class PaymentRepository : GenericRepository<Payment>, IPaymentRepository
{
    private readonly AppDbContext _context;
    public PaymentRepository(AppDbContext context) : base(context)
    {
        _context = context;
    }
    public async Task<IEnumerable<PaymentResponse>> GetPaymentsByUserIdAsync(string userId, int page, int pageSize)
    {
        return await _context.Payments
            .Include(p => p.Booking)
            .Where(p => p.Booking.UserId == userId)
            .OrderByDescending(p => p.Booking.BookingDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(p => new PaymentResponse
            {
                Id = p.Id,
                AmountPaid = p.AmountPaid,
                PaymentDate = p.PaymentDate,
                BookingId = p.BookingId,
                Method = p.Method,
                Status = p.Status,
                TransactionId = p.TransactionId
            })
            .ToListAsync();
    }
    public async Task<PaymentResponse?> GetPaymentByBookingIdAsync(int bookingId)
    {
        return await _context.Payments
        .Select(p => new PaymentResponse
        {
            Id = p.Id,
            AmountPaid = p.AmountPaid,
            PaymentDate = p.PaymentDate,
            BookingId = p.BookingId,
            Method = p.Method,
            Status = p.Status,
            TransactionId = p.TransactionId
        })
            .FirstOrDefaultAsync(p => p.BookingId == bookingId);

    }

}
