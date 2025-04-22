using System;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

namespace FutsalApi.ApiService.Services;

public interface IPaymentService
{
    Task<Payment> OnlinePaymentAsync(Payment payment);

}
public class PaymentService : IPaymentService
{
    private readonly IPaymentRepository _paymentRepository;
    public PaymentService(IPaymentRepository paymentRepository)
    {
        _paymentRepository = paymentRepository;
    }
    public async Task<Payment> OnlinePaymentAsync(Payment payment)
    {
        if (payment == null)
        {
            throw new ArgumentNullException(nameof(payment), "Payment cannot be null.");
        }
        if (payment.AmountPaid != payment.Booking.TotalAmount)
        {
            payment.Status = PaymentStatus.PartiallyCompleted;
            // throw new ArgumentException("Payment amount does not match the total amount of the booking.", nameof(payment.AmountPaid));
        }
        return await _paymentRepository.CreateAsync(payment);
    }
}