using System.ComponentModel.DataAnnotations;

namespace Auth;

public class VerifyResetCodeRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string ResetCode { get; set; } = string.Empty;
}