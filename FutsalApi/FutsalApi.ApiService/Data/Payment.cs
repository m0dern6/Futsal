using System;

namespace FutsalApi.ApiService.Data;

public enum PaymentMethod
{
    Cash,
    Online
}

public enum PaymentStatus
{
    Pending,
    Completed,
    Failed
}

public class Payment
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public PaymentMethod Method { get; set; }
    public string? TransactionId { get; set; }
    public decimal AmountPaid { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public DateTime PaymentDate { get; set; } = DateTime.UtcNow;
}

