using System;
using FluentValidation;
using FutsalApi.ApiService.Models;

namespace FutsalApi.ApiService.Validators;

public class FutsalGroundValidator : AbstractValidator<FutsalGroundRequest>
{
    public FutsalGroundValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.OwnerId).NotEmpty().WithMessage("Owner ID is required");
        RuleFor(x => x.Latitude).InclusiveBetween(-90, 90).WithMessage("Latitude must be between -90 and 90");
        RuleFor(x => x.Longitude).InclusiveBetween(-180, 180).WithMessage("Longitude must be between -180 and 180");
        RuleFor(x => x.PricePerHour).GreaterThan(0).WithMessage("Price must be greater than zero");
        RuleFor(x => x.OpenTime).LessThan(x => x.CloseTime).WithMessage("Open time must be before close time");
    }
}
