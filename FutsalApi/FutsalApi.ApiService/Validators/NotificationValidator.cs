using System;
using FluentValidation;

using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Validators;
public class NotificationValidator : AbstractValidator<Notification>
{
    public NotificationValidator()
    {
        RuleFor(x => x.UserId).NotEmpty().WithMessage("User ID is required");
        RuleFor(x => x.Message).NotEmpty().WithMessage("Message is required");
    }
}

