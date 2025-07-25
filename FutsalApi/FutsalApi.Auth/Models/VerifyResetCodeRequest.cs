using System.ComponentModel.DataAnnotations;

namespace FutsalApi.Auth.Models;

public class VerifyResetCodeRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string ResetCode { get; set; } = string.Empty;
}