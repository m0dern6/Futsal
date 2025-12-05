using System.ComponentModel.DataAnnotations;

namespace Auth;

public class GoogleTokenRequest
{
    [Required]
    public string IdToken { get; set; } = string.Empty;
}
