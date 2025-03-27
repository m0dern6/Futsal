using System;
using FluentValidation;
using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Validators;

public class BookingValidator : AbstractValidator<Booking>
{
    public BookingValidator()
    {
        RuleFor(x => x.UserId).NotEmpty().WithMessage("User ID is required");
        RuleFor(x => x.GroundId).NotEmpty().WithMessage("Ground ID is required");
        RuleFor(x => x.BookingDate).GreaterThanOrEqualTo(DateTime.UtcNow.Date)
            .WithMessage("Booking date cannot be in the past");
        RuleFor(x => x.StartTime).LessThan(x => x.EndTime)
            .WithMessage("Start time must be before end time");
        RuleFor(x => x.TotalAmount).GreaterThan(0)
            .WithMessage("Total amount must be greater than zero");
    }
}

