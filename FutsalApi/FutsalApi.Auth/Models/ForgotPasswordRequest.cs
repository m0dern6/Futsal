using System.ComponentModel.DataAnnotations;

namespace FutsalApi.Auth.Models;

public class ForgotPasswordRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}