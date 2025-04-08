using System;

namespace FutsalApi.ApiService.Models;

public class ClaimModel
{
    public string Type { get; set; } = string.Empty; // The claim type (e.g., "Permission")
    public string Value { get; set; } = string.Empty; // The claim value (e.g., "CanEdit")
}
