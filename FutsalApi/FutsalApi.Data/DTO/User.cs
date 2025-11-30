using Microsoft.AspNetCore.Identity;

namespace FutsalApi.Data.DTO;

public class User : IdentityUser
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public int? ProfileImageId { get; set; } = null;

}
