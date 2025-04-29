using System;

using FutsalApi.ApiService.Repositories;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Services;

public interface IPaymentService
{
    Task<Payment?> OnlinePaymentAsync(Payment payment);

}
public class PaymentService : IPaymentService
{
    private readonly IPaymentRepository _paymentRepository;
    public PaymentService(IPaymentRepository paymentRepository)
    {
        _paymentRepository = paymentRepository;
    }
    public async Task<Payment?> OnlinePaymentAsync(Payment payment)
    {
        if (payment == null)
        {
            throw new ArgumentNullException(nameof(payment), "Payment cannot be null.");
        }
        decimal RemainingAmount;
        decimal paidAmount = await _paymentRepository.GetPaidAmount(payment.BookingId);
        if (paidAmount == 0)
        {
            RemainingAmount = payment.Booking.TotalAmount - payment.AmountPaid;
        }
        else if (paidAmount > 0 && paidAmount < payment.Booking.TotalAmount)
        {
            RemainingAmount = payment.Booking.TotalAmount - paidAmount - payment.AmountPaid;
        }
        else if (paidAmount == payment.Booking.TotalAmount)
        {
            RemainingAmount = 0;
        }
        else
        {
            throw new ArgumentException("Invalid paid amount.", nameof(paidAmount));
        }
        if (RemainingAmount < 0)
        {
            throw new ArgumentException("Payment exceeds the total amount.", nameof(payment.AmountPaid));
        }
        else if (RemainingAmount == 0)
        {
            payment.Status = PaymentStatus.Completed;
        }
        else if (RemainingAmount > 0 && RemainingAmount < payment.Booking.TotalAmount)
        {
            payment.Status = PaymentStatus.PartiallyCompleted;
        }


        return await _paymentRepository.CreateAsync(payment);
    }
}
