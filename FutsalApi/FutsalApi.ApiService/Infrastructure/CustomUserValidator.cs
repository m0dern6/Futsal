using Microsoft.AspNetCore.Identity;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Infrastructure;

public class CustomUserValidator : IUserValidator<User>
{
    public async Task<IdentityResult> ValidateAsync(UserManager<User> manager, User user)
    {
        var errors = new List<IdentityError>();

        // Only validate unique email during user creation or when email is actually being changed
        // This prevents the "email already taken" error during password resets
        if (manager.SupportsUserEmail)
        {
            var email = await manager.GetEmailAsync(user);
            if (!string.IsNullOrWhiteSpace(email))
            {
                var owner = await manager.FindByEmailAsync(email);
                // Only fail if there's a different user with the same email
                if (owner != null && !string.Equals(await manager.GetUserIdAsync(owner), await manager.GetUserIdAsync(user)))
                {
                    errors.Add(new IdentityError
                    {
                        Code = "DuplicateEmail",
                        Description = $"Email '{email}' is already taken."
                    });
                }
            }
        }

        // Validate unique username
        var userName = await manager.GetUserNameAsync(user);
        if (!string.IsNullOrWhiteSpace(userName))
        {
            var owner = await manager.FindByNameAsync(userName);
            // Only fail if there's a different user with the same username
            if (owner != null && !string.Equals(await manager.GetUserIdAsync(owner), await manager.GetUserIdAsync(user)))
            {
                errors.Add(new IdentityError
                {
                    Code = "DuplicateUserName",
                    Description = $"User name '{userName}' is already taken."
                });
            }
        }

        return errors.Count > 0 ? IdentityResult.Failed(errors.ToArray()) : IdentityResult.Success;
    }
}
