using Bingo.Core.Features.PaymentService.Contract.Service;
using Bingo.Core.Models;
using HtmlAgilityPack;
using System;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using UglyToad.PdfPig;

namespace Bingo.Core.Features.PaymentService.Handler.Service
{
    public class PaymentService : IPaymentService
    {
        private static readonly HttpClient _http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(15)
        };
        static PaymentService()
        {
            // Add a browser-like User-Agent to avoid being blocked by the bank's server
            _http.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
        }
        /* ================= TELEBIRR ================= */

        public async Task<TelebirrReceipt?> ValidateTeleBirrPayment(string smsText)
        {
            var receiptUrl = ExtractUrl(smsText);
            var transactionId = ExtractTelebirrTxId(receiptUrl);

            var html = await _http.GetStringAsync(receiptUrl);

            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            string creditedName = FindValue(doc, "የገንዘብ ተቀባይ ስም");
            string creditedAccount = FindValue(doc, "የገንዘብ ተቀባይ ቴሌብር ቁ.");
            decimal amount = ExtractTelebirrAmount(doc);

            if (string.IsNullOrWhiteSpace(creditedName) ||
                string.IsNullOrWhiteSpace(creditedAccount))
                return null;

            return new TelebirrReceipt(
                transactionId,
                creditedName.Trim(),
                creditedAccount[^4..],
                amount
            );
        }

        private static decimal ExtractTelebirrAmount(HtmlDocument doc)
        {
            var node = doc.DocumentNode
                .Descendants("td")
                .FirstOrDefault(td =>
                    td.InnerText.Contains("የተከፈለው መጠን/Settled Amount") ||
                    td.InnerText.Contains("የተከፈለው መጠን/Settled Amount"));

            if (node == null)
                throw new InvalidOperationException("Telebirr amount not found");

            var raw = node.NextSibling?.InnerText ?? string.Empty;

            var match = Regex.Match(raw, @"([\d,]+(\.\d{2})?)");
            if (!match.Success)
                throw new InvalidOperationException("Invalid Telebirr amount format");

            return decimal.Parse(
                match.Groups[1].Value.Replace(",", ""),
                CultureInfo.InvariantCulture
            );
        }

        /* ================= CBE ================= */

        public async Task<CbeReceipt?> ValidateTCBEPayment(string smsText)
        {
            var receiptUrl = ExtractUrl(smsText);
            var reference = ExtractCbeReference(receiptUrl);

            var pdfBytes = await _http.GetByteArrayAsync(receiptUrl);

            using var pdf = PdfDocument.Open(pdfBytes);
            var text = string.Join("\n", pdf.GetPages().Select(p => p.Text));

            string receiver = ExtractPdfValue(text, "Receiver");
            string account = ExtractPdfValue(text, "Account");
            decimal amount = ExtractCbeAmount(text);

            if (string.IsNullOrWhiteSpace(receiver) ||
                string.IsNullOrWhiteSpace(account))
                return null;

            return new CbeReceipt(
                reference,
                receiver.Trim(),
                account[^4..],
                amount
            );
        }

        private static decimal ExtractCbeAmount(string text)
        {
            var lines = text
                .Split('\n', StringSplitOptions.RemoveEmptyEntries)
                .Select(l => l.Trim())
                .ToList();

            for (int i = 0; i < lines.Count; i++)
            {
                if (lines[i].Contains("Transferred Amount", StringComparison.OrdinalIgnoreCase))
                {
                    if (i + 1 < lines.Count)
                    {
                        var match = Regex.Match(lines[i + 1], @"([\d,]+(\.\d{2})?)");
                        if (match.Success)
                        {
                            return decimal.Parse(
                                match.Groups[1].Value.Replace(",", ""),
                                CultureInfo.InvariantCulture
                            );
                        }
                    }
                }
            }

            throw new InvalidOperationException("CBE amount not found");
        }

        /* ================= HELPERS ================= */

        private static string ExtractUrl(string text)
        {
            var match = Regex.Match(text, @"https?:\/\/\S+");
            if (!match.Success)
                throw new InvalidOperationException("Receipt URL not found");
            return match.Value;
        }

        private static string ExtractTelebirrTxId(string url)
        {
            return url.Split('/').Last();
        }

        private static string ExtractCbeReference(string url)
        {
            var match = Regex.Match(url, @"id=([A-Z0-9]+)");
            if (!match.Success)
                throw new InvalidOperationException("Invalid CBE receipt URL");
            return match.Groups[1].Value;
        }

        private static string FindValue(HtmlDocument doc, string label)
        {
            // Look for a cell containing the label, then find the next cell in the same row
            var node = doc.DocumentNode
                .Descendants("td")
                .FirstOrDefault(td => td.InnerText.Contains(label));

            // Instead of NextSibling, get the next 'td' element in the parent row
            var valueNode = node?.ParentNode?.Descendants("td").ElementAtOrDefault(1);

            return valueNode?.InnerText?.Trim() ?? string.Empty;
        }

        private static string ExtractPdfValue(string text, string label)
        {
            var lines = text
                .Split('\n', StringSplitOptions.RemoveEmptyEntries)
                .Select(l => l.Trim())
                .ToList();

            for (int i = 0; i < lines.Count; i++)
            {
                if (lines[i].Equals(label, StringComparison.OrdinalIgnoreCase))
                {
                    if (i + 1 < lines.Count)
                        return lines[i + 1];
                }
            }

            return string.Empty;
        }
    }
}
