using System;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authentication;
using FutsalApi.ServiceDefaults.Services;

namespace FutsalApi.Auth.Infrastructure;

public static class GoogleAuthConfiguration
{
    public static AuthenticationBuilder AddGoogleAuthentication(
            this AuthenticationBuilder builder)
    {
        var serviceProvider = builder.Services.BuildServiceProvider();
        var secretRetriever = serviceProvider.GetRequiredService<IGeneralSettingsService>();

        var googleClientId = secretRetriever.GetSettingAsync("Google:ClientId").GetAwaiter().GetResult();
        var googleClientSecret = secretRetriever.GetSettingAsync("Google:ClientSecret").GetAwaiter().GetResult();

        builder.AddGoogle(googleOptions =>
        {
            googleOptions.ClientId = googleClientId;
            googleOptions.ClientSecret = googleClientSecret;
            googleOptions.CallbackPath = "/auth/google/callback";
        });

        return builder;
    }
}
