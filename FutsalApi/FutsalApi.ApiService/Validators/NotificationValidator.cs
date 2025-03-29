using System;
using FluentValidation;
using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Validators;
public class NotificationValidator : AbstractValidator<Notification>
{
    public NotificationValidator()
    {
        RuleFor(x => x.UserId).NotEmpty().WithMessage("User ID is required");
        RuleFor(x => x.Message).NotEmpty().WithMessage("Message is required");
    }
}

