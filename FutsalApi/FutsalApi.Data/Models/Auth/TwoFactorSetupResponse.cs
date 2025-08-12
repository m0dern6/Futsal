using System;

namespace Auth;

public class TwoFactorSetupResponse
{
    public string SharedKey { get; set; } = string.Empty;
    public string QrCodeUri { get; set; } = string.Empty;
}
