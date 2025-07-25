using System.ComponentModel.DataAnnotations;

namespace FutsalApi.Auth.Models;

public class InfoRequest
{
    public string? NewEmail { get; set; }
    public string? NewPassword { get; set; }
    public string? OldPassword { get; set; }
}