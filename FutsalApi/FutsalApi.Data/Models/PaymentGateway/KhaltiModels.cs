using System.ComponentModel.DataAnnotations;

namespace PaymentGateway;

// Khalti Request Models
public class KhaltiInitiateRequest
{
    [Required]
    public string ReturnUrl { get; set; } = string.Empty;
    
    [Required]
    public string WebsiteUrl { get; set; } = string.Empty;
    
    [Required]
    public int Amount { get; set; } // Amount in paisa (1 NPR = 100 paisa)
    
    [Required]
    public string PurchaseOrderId { get; set; } = string.Empty;
    
    [Required]
    public string PurchaseOrderName { get; set; } = string.Empty;
    
    public KhaltiCustomerInfo? CustomerInfo { get; set; }
    
    public List<KhaltiAmountBreakdown>? AmountBreakdown { get; set; }
    
    public List<KhaltiProductDetail>? ProductDetails { get; set; }
}

public class KhaltiCustomerInfo
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
}

public class KhaltiAmountBreakdown
{
    public string Label { get; set; } = string.Empty;
    public int Amount { get; set; }
}

public class KhaltiProductDetail
{
    public string Identity { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public int TotalPrice { get; set; }
    public int Quantity { get; set; }
    public int UnitPrice { get; set; }
}

public class KhaltiLookupRequest
{
    [Required]
    public string PidxToken { get; set; } = string.Empty;
}

// Khalti Response Models
public class KhaltiInitiateResponse
{
    public string Pidx { get; set; } = string.Empty;
    public string PaymentUrl { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public int ExpiresIn { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class KhaltiLookupResponse
{
    public string Pidx { get; set; } = string.Empty;
    public int TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string TransactionId { get; set; } = string.Empty;
    public decimal Fee { get; set; }
    public bool Refunded { get; set; }
    public KhaltiCustomerInfo? Customer { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

// Khalti Webhook Model
public class KhaltiWebhookPayload
{
    public string Pidx { get; set; } = string.Empty;
    public int TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string TransactionId { get; set; } = string.Empty;
    public decimal Fee { get; set; }
    public bool Refunded { get; set; }
    public string PurchaseOrderId { get; set; } = string.Empty;
    public string PurchaseOrderName { get; set; } = string.Empty;
}
