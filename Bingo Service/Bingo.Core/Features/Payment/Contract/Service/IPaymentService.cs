using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Bingo.Core.Models;

namespace Bingo.Core.Features.PaymentService.Contract.Service
{
    public interface IPaymentService
    {
        Task<TelebirrReceipt?> ValidateTeleBirrPayment(string smsText);
        Task<CbeReceipt?> ValidateTCBEPayment(string smsText);
    }
}
