using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Models
{
    public record CbeReceipt(
        string ReferenceNumber,
        string ReceiverName,
        string ReceiverAccountLast4,
        decimal AmountEtb
    );
}
