using Microsoft.AspNetCore.Identity;

namespace FutsalApi.Data.DTO;

public class User : IdentityUser
{
    public int? ProfileImageId { get; set; } = null;

}
