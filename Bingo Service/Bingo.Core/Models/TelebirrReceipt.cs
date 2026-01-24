using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Models
{
    public record TelebirrReceipt(
     string TransactionId,
     string CreditedPartyName,
     string CreditedPartyAccountLast4,
     decimal AmountEtb
 );

   

}
