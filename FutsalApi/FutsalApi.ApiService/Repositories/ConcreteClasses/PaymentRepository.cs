using System;
using System.Linq.Expressions;

using FutsalApi.ApiService.Data;
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
    public async Task<IEnumerable<Payment>> GetPaymentsByUserIdAsync(string userId, int page, int pageSize)
    {
        return await _context.Payments
            .Include(p => p.Booking)
            .Where(p => p.Booking.UserId == userId)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }
    public async Task<Payment> GetPaymentByBookingIdAsync(int bookingId)
    {
        return await _context.Payments
            .FirstOrDefaultAsync(p => p.BookingId == bookingId)
            ?? throw new Exception($"Payment with BookingId {bookingId} not found.");
    }

}
