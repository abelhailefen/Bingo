using Bingo.Core.Entities.Enums;

namespace Bingo.Core.Entities;

public class Payment
{
    public long PaymentId { get; set; }
    public long UserId { get; set; }
    public string TransactionReference { get; set; } = null!;
    public decimal Amount { get; set; }
    public PaymentProviderEnum Provider { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation property
    public virtual User User { get; set; } = null!;
}