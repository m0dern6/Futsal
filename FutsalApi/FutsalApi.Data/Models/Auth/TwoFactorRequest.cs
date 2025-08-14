using System.ComponentModel.DataAnnotations;

namespace Auth;

public class TwoFactorRequest
{
    public bool Enable { get; set; }
    public string? TwoFactorCode { get; set; }
    public bool ResetSharedKey { get; set; }
    public bool ResetRecoveryCodes { get; set; }
    public bool ForgetMachine { get; set; }
}