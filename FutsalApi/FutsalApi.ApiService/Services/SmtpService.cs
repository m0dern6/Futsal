using System;
using System.Net.Mail;

using FutsalApi.ServiceDefaults.Services;

namespace FutsalApi.ApiService.Services;
public interface ISmtpService
{
    Task SendEmailAsync(string to, string subject, string body);
}
public class SmtpService : ISmtpService
{
    private readonly SmtpClient _smtpClient;
    private readonly string _fromEmail;
    private readonly IGeneralSettingsService _generalSettingsService;

    public SmtpService(IGeneralSettingsService generalSettingsService)
    {
        _generalSettingsService = generalSettingsService;
        var smtpServer = _generalSettingsService.GetSettingAsync("Email:SmtpServer").Result;
        var smtpPort = _generalSettingsService.GetSettingAsync("Email:SmtpPort").Result;
        var smtpUser = _generalSettingsService.GetSettingAsync("Email:SmtpUser").Result;
        var smtpPassword = _generalSettingsService.GetSettingAsync("Email:SmtpPassword").Result;
        _fromEmail = _generalSettingsService.GetSettingAsync("Email:FromEmail").Result;
        _smtpClient = new SmtpClient(smtpServer, int.Parse(smtpPort))
        {
            Credentials = new System.Net.NetworkCredential(smtpUser, smtpPassword),
            EnableSsl = true
        };

    }
    public async Task SendEmailAsync(string to, string subject, string body)
    {
        var mailMessage = new MailMessage(_fromEmail, to, subject, body);
        await _smtpClient.SendMailAsync(mailMessage);
    }

}
