using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FutsalApi.Data.DTO;

public enum PaymentMethod
{
    Cash,
    Online,
    ESewa,
    Khalti
}

public enum PaymentStatus
{
    Pending,
    PartiallyCompleted,
    Completed,
    Failed
}

public class Payment
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public int BookingId { get; set; }
    public PaymentMethod Method { get; set; }
    public string? TransactionId { get; set; }
    public decimal AmountPaid { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public DateTime PaymentDate { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(BookingId))]
    public Booking Booking { get; set; } = null!;
}

