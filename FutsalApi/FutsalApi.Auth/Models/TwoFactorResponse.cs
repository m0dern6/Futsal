using System.ComponentModel.DataAnnotations;

namespace FutsalApi.Auth.Models;

public class TwoFactorResponse
{
    public string SharedKey { get; set; } = string.Empty;
    public string[]? RecoveryCodes { get; set; }
    public int RecoveryCodesLeft { get; set; }
    public bool IsTwoFactorEnabled { get; set; }
    public bool IsMachineRemembered { get; set; }
}