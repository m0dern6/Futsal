using FutsalApi.UI.Shared.Services;

namespace FutsalApi.UI.Web.Services;
public class FormFactor : IFormFactor
{
    public string GetFormFactor()
    {
        return "Web";
    }

    public string GetPlatform()
    {
        return Environment.OSVersion.ToString();
    }
}
