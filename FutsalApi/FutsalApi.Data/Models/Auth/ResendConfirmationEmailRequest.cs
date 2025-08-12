using System.ComponentModel.DataAnnotations;

namespace Auth;

public class ResendConfirmationEmailRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}