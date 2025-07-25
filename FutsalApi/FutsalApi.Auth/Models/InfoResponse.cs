using System.ComponentModel.DataAnnotations;

namespace FutsalApi.Auth.Models;

public class InfoResponse
{
    public string Id { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool IsEmailConfirmed { get; set; }
}