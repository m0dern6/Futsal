using System;

using FutsalApi.ApiService.Data;

using Microsoft.AspNetCore.Identity;

namespace FutsalApi.ApiService.Services;

public class EmailSender : IEmailSender<User>
{
    public Task SendConfirmationLinkAsync(User user, string email, string confirmationLink)
    {
        Console.WriteLine($"Sending confirmation link to {email} with link {confirmationLink}");
        return Task.CompletedTask;
    }
    public Task SendPasswordResetLinkAsync(User user, string email, string resetLink)
    {
        Console.WriteLine($"Sending password reset link to {email} with link {resetLink}");
        return Task.CompletedTask;
    }
    public Task SendPasswordResetCodeAsync(User user, string email, string resetCode)
    {
        Console.WriteLine($"Sending password reset code to {email} with code {resetCode}");
        return Task.CompletedTask;
    }
}
