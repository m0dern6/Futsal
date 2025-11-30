using System;
using PaymentGateway;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Services.PaymentGateway;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Services;

public interface IPaymentService
{
    Task<Payment?> OnlinePaymentAsync(Payment payment);
    Task<KhaltiInitiateResponse> InitiateKhaltiPaymentAsync(User user, int bookingId, string returnUrl, string websiteUrl);
    Task<Payment?> ProcessKhaltiCallbackAsync(string pidx);
}

public class PaymentService : IPaymentService
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IKhaltiService _khaltiService;
    private readonly ILogger<PaymentService> _logger;

    public PaymentService(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        IKhaltiService khaltiService,
        ILogger<PaymentService> logger)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _khaltiService = khaltiService;
        _logger = logger;
    }

    public async Task<Payment?> OnlinePaymentAsync(Payment payment)
    {
        if (payment == null)
        {
            throw new ArgumentNullException(nameof(payment), "Payment cannot be null.");
        }

        decimal remainingAmount = await CalculateRemainingAmountAsync(payment);

        if (remainingAmount < 0)
        {
            throw new ArgumentException("Payment exceeds the total amount.", nameof(payment.AmountPaid));
        }

        payment.Status = remainingAmount == 0 ? PaymentStatus.Completed :
                        remainingAmount > 0 && remainingAmount < payment.Booking.TotalAmount ?
                        PaymentStatus.PartiallyCompleted : PaymentStatus.Pending;

        return await _paymentRepository.CreatePaymentAsync(payment);
    }


    public async Task<KhaltiInitiateResponse> InitiateKhaltiPaymentAsync(User user, int bookingId, string returnUrl, string websiteUrl)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(b => b.Id == bookingId);
            if (booking == null)
            {
                return new KhaltiInitiateResponse
                {
                    Success = false,
                    Message = "Booking not found"
                };
            }

            // Ensure booking belongs to user
            if (booking.UserId != user.Id)
            {
                return new KhaltiInitiateResponse
                {
                    Success = false,
                    Message = "Booking does not belong to the current user"
                };
            }

            var remainingAmount = await GetRemainingAmountForBookingAsync(bookingId, booking.TotalAmount);

            var khaltiRequest = new KhaltiInitiateRequest
            {
                ReturnUrl = returnUrl,
                WebsiteUrl = websiteUrl,
                Amount = (int)(remainingAmount * 100), // Convert to paisa
                PurchaseOrderId = $"FUTSAL_BOOKING_{bookingId}",
                PurchaseOrderName = $"Futsal Booking Payment - {bookingId}",
                CustomerInfo = new KhaltiCustomerInfo
                {
                    Name = string.IsNullOrWhiteSpace(user.UserName) ? "Customer" : user.UserName,
                    Email = string.IsNullOrWhiteSpace(user.Email) ? "customer@example.com" : user.Email,
                    Phone = string.IsNullOrWhiteSpace(user.PhoneNumber) ? "9800000000" : user.PhoneNumber
                }
            };

            return await _khaltiService.InitiatePaymentAsync(khaltiRequest);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error initiating Khalti payment for booking {BookingId}", bookingId);
            return new KhaltiInitiateResponse
            {
                Success = false,
                Message = "Failed to initiate Khalti payment"
            };
        }
    }


    public async Task<Payment?> ProcessKhaltiCallbackAsync(string pidx)
    {
        try
        {
            var lookupRequest = new KhaltiLookupRequest { PidxToken = pidx };
            var lookupResponse = await _khaltiService.LookupPaymentAsync(lookupRequest);

            if (!lookupResponse.Success || lookupResponse.Status != "Completed")
            {
                _logger.LogWarning("Khalti payment verification failed for pidx {Pidx}", pidx);
                return null;
            }

            // Extract booking ID from purchase order ID
            var bookingIdStr = lookupResponse.Customer?.Name?.Replace("FUTSAL_BOOKING_", "") ?? "";
            if (!int.TryParse(bookingIdStr, out int bookingId))
            {
                _logger.LogError("Invalid booking ID in Khalti purchase order: {PurchaseOrderId}", lookupResponse.Customer?.Name);
                return null;
            }

            var booking = await _bookingRepository.GetByIdAsync(b => b.Id == bookingId);
            if (booking == null)
            {
                _logger.LogError("Booking not found for ID: {BookingId}", bookingId);
                return null;
            }

            var payment = new Payment
            {
                BookingId = bookingId,
                Method = PaymentMethod.Khalti,
                TransactionId = lookupResponse.TransactionId,
                AmountPaid = lookupResponse.TotalAmount / 100m, // Convert from paisa to NPR
                Status = PaymentStatus.Completed,
                Booking = booking
            };

            return await OnlinePaymentAsync(payment);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Khalti callback");
            return null;
        }
    }

    private async Task<decimal> CalculateRemainingAmountAsync(Payment payment)
    {
        decimal paidAmount = await _paymentRepository.GetPaidAmountAsync(payment.BookingId);
        decimal totalAmount = payment.Booking.TotalAmount;

        return paidAmount == 0
            ? totalAmount - payment.AmountPaid
            : totalAmount - paidAmount - payment.AmountPaid;
    }

    private async Task<decimal> GetRemainingAmountForBookingAsync(int bookingId, decimal totalAmount)
    {
        decimal paidAmount = await _paymentRepository.GetPaidAmountAsync(bookingId);
        return totalAmount - paidAmount;
    }
}
