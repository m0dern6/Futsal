using System.ComponentModel.DataAnnotations;

namespace FutsalApi.ApiService.Models.PaymentGateway;

// eSewa Request Models
public class ESewaInitiateRequest
{
    [Required]
    public decimal Amount { get; set; }
    
    [Required]
    public string ProductCode { get; set; } = string.Empty;
    
    [Required]
    public string ProductServiceCharge { get; set; } = "0";
    
    [Required]
    public string ProductDeliveryCharge { get; set; } = "0";
    
    [Required]
    public string TaxAmount { get; set; } = "0";
    
    [Required]
    public decimal TotalAmount { get; set; }
    
    [Required]
    public string TransactionUuid { get; set; } = string.Empty;
    
    [Required]
    public string SuccessUrl { get; set; } = string.Empty;
    
    [Required]
    public string FailureUrl { get; set; } = string.Empty;
}

public class ESewaVerificationRequest
{
    [Required]
    public string ProductCode { get; set; } = string.Empty;
    
    [Required]
    public string TransactionUuid { get; set; } = string.Empty;
    
    [Required]
    public decimal TotalAmount { get; set; }
}

// eSewa Response Models
public class ESewaInitiateResponse
{
    public string PaymentUrl { get; set; } = string.Empty;
    public string TransactionUuid { get; set; } = string.Empty;
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class ESewaVerificationResponse
{
    public string ProductId { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string Environment { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string TransactionDetails { get; set; } = string.Empty;
    public string ReferenceId { get; set; } = string.Empty;
    public bool HasData { get; set; }
    public string Message { get; set; } = string.Empty;
}

// eSewa Callback Model
public class ESewaCallbackResponse
{
    public string Data { get; set; } = string.Empty;
    public string TransactionCode { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string TransactionUuid { get; set; } = string.Empty;
    public string ProductCode { get; set; } = string.Empty;
    public bool Success { get; set; }
}
