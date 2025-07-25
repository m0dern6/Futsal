using System.ComponentModel.DataAnnotations;

namespace FutsalApi.Auth.Models;

public class RefreshRequest
{
    [Required]
    public string RefreshToken { get; set; } = string.Empty;
}