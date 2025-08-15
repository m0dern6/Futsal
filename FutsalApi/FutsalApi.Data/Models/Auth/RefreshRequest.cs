﻿using System.ComponentModel.DataAnnotations;

namespace Auth;

public class RefreshRequest
{
    [Required]
    public string RefreshToken { get; set; } = string.Empty;
}