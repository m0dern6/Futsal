using System;
using FluentValidation;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Validators;

public class PaymentRequestValidator : AbstractValidator<PaymentRequest>
{
    public PaymentRequestValidator()
    {
        RuleFor(x => x.BookingId).NotEmpty().WithMessage("Booking ID is required");
        RuleFor(x => x.AmountPaid).GreaterThan(0).WithMessage("Amount must be greater than zero");
        RuleFor(x => x.Method).IsInEnum().WithMessage("Invalid payment method");
        RuleFor(x => x.Status).IsInEnum().WithMessage("Invalid payment status");
    }
}
