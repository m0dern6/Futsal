using System;

using FutsalApi.Data.DTO;

using Microsoft.AspNetCore.Identity;

namespace FutsalApi.ApiService.Services;

public class EmailSender : IEmailSender<User>
{
    private readonly ISmtpService _smtpService;
    
    public EmailSender(ISmtpService smtpService)
    {
        _smtpService = smtpService;
    }
    
    public async Task SendConfirmationLinkAsync(User user, string email, string confirmationLink)
    {
        var subject = "Confirm Your Email - Futsal Booking";
        var body = $@"
            <html>
            <body>
                <h2>Welcome to Futsal Booking, {user.FirstName}!</h2>
                <p>Please confirm your email address by clicking the link below:</p>
                <p><a href='{confirmationLink}'>Confirm Email</a></p>
                <p>If you didn't create an account, please ignore this email.</p>
                <br/>
                <p>Best regards,<br/>Futsal Booking Team</p>
            </body>
            </html>
        ";
        await _smtpService.SendEmailAsync(email, subject, body);
    }

    public async Task SendPasswordResetLinkAsync(User user, string email, string resetLink)
    {
        var subject = "Reset Your Password - Futsal Booking";
        var body = $@"
            <html>
            <body>
                <h2>Password Reset Request</h2>
                <p>Hi {user.FirstName},</p>
                <p>You requested to reset your password. Click the link below to reset it:</p>
                <p><a href='{resetLink}'>Reset Password</a></p>
                <p>If you didn't request this, please ignore this email.</p>
                <br/>
                <p>Best regards,<br/>Futsal Booking Team</p>
            </body>
            </html>
        ";
        await _smtpService.SendEmailAsync(email, subject, body);
    }

    public async Task SendPasswordResetCodeAsync(User user, string email, string resetCode)
    {
        var subject = "Your Password Reset Code - Futsal Booking";
        var body = $@"
            <html>
            <body>
                <h2>Password Reset Code</h2>
                <p>Hi {user.FirstName},</p>
                <p>Your password reset code is:</p>
                <h3 style='background-color: #f0f0f0; padding: 10px; display: inline-block;'>{resetCode}</h3>
                <p>This code will expire in 24 hours.</p>
                <p>If you didn't request this, please ignore this email.</p>
                <br/>
                <p>Best regards,<br/>Futsal Booking Team</p>
            </body>
            </html>
        ";
        await _smtpService.SendEmailAsync(email, subject, body);
    }
}
