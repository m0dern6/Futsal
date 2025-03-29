using System;
using FluentValidation;
using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Validators;

public class FutsalGroundValidator : AbstractValidator<FutsalGround>
{
    public FutsalGroundValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.Location).NotEmpty().WithMessage("Location is required");
        RuleFor(x => x.OwnerId).NotEmpty().WithMessage("Owner ID is required");
        RuleFor(x => x.PricePerHour).GreaterThan(0).WithMessage("Price must be greater than zero");
        RuleFor(x => x.OpenTime).LessThan(x => x.CloseTime).WithMessage("Open time must be before close time");
    }
}
