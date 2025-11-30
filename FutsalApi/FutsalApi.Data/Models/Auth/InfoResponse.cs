
public class InfoResponse
{
    public string Id { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool IsEmailConfirmed { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string? Username { get; set; }
    public string? PhoneNumber { get; set; }
    public bool IsPhoneNumberConfirmed { get; set; } // isphoneverified
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string FullName => $"{FirstName} {LastName}".Trim();
    public int TotalBookings { get; set; } = 0;
    public int TotalReviews { get; set; } = 0;
    public int TotalFavorites { get; set; } = 0;
}