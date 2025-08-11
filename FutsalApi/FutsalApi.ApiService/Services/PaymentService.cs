using System;
using FutsalApi.ApiService.Models.PaymentGateway;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Services.PaymentGateway;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Services;

public interface IPaymentService
{
    Task<Payment?> OnlinePaymentAsync(Payment payment);
    Task<ESewaInitiateResponse> InitiateESewaPaymentAsync(int bookingId, string successUrl, string failureUrl);
    Task<KhaltiInitiateResponse> InitiateKhaltiPaymentAsync(int bookingId, string returnUrl, string websiteUrl);
    Task<Payment?> ProcessESewaCallbackAsync(ESewaCallbackResponse callback);
    Task<Payment?> ProcessKhaltiCallbackAsync(string pidx);
}

public class PaymentService : IPaymentService
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IESewaService _esewaService;
    private readonly IKhaltiService _khaltiService;
    private readonly ILogger<PaymentService> _logger;

    public PaymentService(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        IESewaService esewaService,
        IKhaltiService khaltiService,
        ILogger<PaymentService> logger)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _esewaService = esewaService;
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

    public async Task<ESewaInitiateResponse> InitiateESewaPaymentAsync(int bookingId, string successUrl, string failureUrl)
    {
        try
        {
            var booking = await _bookingRepository.GetByIdAsync(b => b.Id == bookingId);
            if (booking == null)
            {
                return new ESewaInitiateResponse
                {
                    Success = false,
                    Message = "Booking not found"
                };
            }

            var remainingAmount = await GetRemainingAmountForBookingAsync(bookingId, booking.TotalAmount);
            
            var esewaRequest = new ESewaInitiateRequest
            {
                Amount = remainingAmount,
                ProductCode = $"FUTSAL_BOOKING_{bookingId}",
                ProductServiceCharge = "0",
                ProductDeliveryCharge = "0",
                TaxAmount = "0",
                TotalAmount = remainingAmount,
                TransactionUuid = Guid.NewGuid().ToString(),
                SuccessUrl = successUrl,
                FailureUrl = failureUrl
            };

            return await _esewaService.InitiatePaymentAsync(esewaRequest);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error initiating eSewa payment for booking {BookingId}", bookingId);
            return new ESewaInitiateResponse
            {
                Success = false,
                Message = "Failed to initiate eSewa payment"
            };
        }
    }

    public async Task<KhaltiInitiateResponse> InitiateKhaltiPaymentAsync(int bookingId, string returnUrl, string websiteUrl)
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
                    Name = "Customer", // You might want to get this from user data
                    Email = "customer@example.com",
                    Phone = "9800000000"
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

    public async Task<Payment?> ProcessESewaCallbackAsync(ESewaCallbackResponse callback)
    {
        try
        {
            if (!callback.Success)
            {
                _logger.LogWarning("eSewa payment failed for transaction {TransactionUuid}", callback.TransactionUuid);
                return null;
            }

            // Verify the payment with eSewa
            var verificationRequest = new ESewaVerificationRequest
            {
                ProductCode = callback.ProductCode,
                TransactionUuid = callback.TransactionUuid,
                TotalAmount = callback.TotalAmount
            };

            var verificationResponse = await _esewaService.VerifyPaymentAsync(verificationRequest);
            
            if (!verificationResponse.HasData || verificationResponse.Status != "COMPLETE")
            {
                _logger.LogWarning("eSewa payment verification failed for transaction {TransactionUuid}", callback.TransactionUuid);
                return null;
            }

            // Extract booking ID from product code
            var bookingIdStr = callback.ProductCode.Replace("FUTSAL_BOOKING_", "");
            if (!int.TryParse(bookingIdStr, out int bookingId))
            {
                _logger.LogError("Invalid booking ID in eSewa product code: {ProductCode}", callback.ProductCode);
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
                Method = PaymentMethod.ESewa,
                TransactionId = verificationResponse.ReferenceId,
                AmountPaid = callback.TotalAmount,
                Status = PaymentStatus.Completed,
                Booking = booking
            };

            return await OnlinePaymentAsync(payment);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing eSewa callback");
            return null;
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
