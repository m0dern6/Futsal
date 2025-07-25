using FutsalApi.UI.Services;
using FutsalApi.UI.Shared.Services;

using Microsoft.Extensions.Logging;

namespace FutsalApi.UI;
public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts =>
            {
                fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
            });

        // Add device-specific services used by the FutsalApi.UI.Shared project
        builder.Services.AddSingleton<IFormFactor, FormFactor>();

        builder.Services.AddMauiBlazorWebView();

        builder.Services.AddBlazorBootstrap();

#if DEBUG
        builder.Services.AddBlazorWebViewDeveloperTools();
        builder.Logging.AddDebug();
#endif

        return builder.Build();
    }
}
