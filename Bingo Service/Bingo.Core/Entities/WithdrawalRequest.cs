using Bingo.Core.Entities.Enums;
using System.ComponentModel.DataAnnotations.Schema;

namespace Bingo.Core.Entities;

public class WithdrawalRequest
{
    public long WithdrawalRequestId { get; set; }
    public long UserId { get; set; }
    public decimal Amount { get; set; }
    public WithdrawalStatusEnum Status { get; set; }
    public string? AdminComment { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
    
    // Navigation property
    [ForeignKey("UserId")]
    public virtual User User { get; set; } = null!;
}
