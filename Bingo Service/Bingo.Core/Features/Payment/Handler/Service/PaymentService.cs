using Bingo.Core.Features.PaymentService.Contract.Service;
using Bingo.Core.Models;
using HtmlAgilityPack;
using System.Globalization;
using System.Net.Http;
using System.Text.RegularExpressions;
using UglyToad.PdfPig;

namespace Bingo.Core.Features.PaymentService.Handler.Service
{
    public class PaymentService : IPaymentService
    {
        // Increased timeout to 60 seconds to handle slow networks/servers
        private static readonly HttpClient _http = new HttpClient(new HttpClientHandler { AllowAutoRedirect = true })
        {
            Timeout = TimeSpan.FromSeconds(60)
        };

        static PaymentService()
        {
            // Using a more complete set of headers to avoid being blocked as a bot
            _http.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");
            _http.DefaultRequestHeaders.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8");
            _http.DefaultRequestHeaders.Add("Accept-Language", "en-US,en;q=0.5");
        }

        /* ================= TELEBIRR ================= */

        public async Task<TelebirrReceipt?> ValidateTeleBirrPayment(string smsText)
        {
            string receiptUrl = "";
            try
            {
                receiptUrl = ExtractUrl(smsText);
                Console.WriteLine($"[TELEBIRR] Fetching receipt: {receiptUrl}");

                var html = await _http.GetStringAsync(receiptUrl);
                var doc = new HtmlDocument();
                doc.LoadHtml(html);

                // 1. Extract Name (Look for text containing 'Party name')
                var nameNode = doc.DocumentNode.SelectSingleNode("//td[contains(text(), 'Party name')]/following-sibling::td");
                string creditedName = HtmlEntity.DeEntitize(nameNode?.InnerText ?? "").Trim();

                // 2. Extract Account (Look for text containing 'party account')
                var accountNode = doc.DocumentNode.SelectSingleNode("//td[contains(text(), 'party account')]/following-sibling::td");
                string creditedAccount = HtmlEntity.DeEntitize(accountNode?.InnerText ?? "").Trim();

                // 3. Extract Amount & ID from the table
                var allDataCells = doc.DocumentNode.SelectNodes("//td[contains(@class, 'receipttableTd')]");
                string transactionId = "";
                decimal amount = 0;

                if (allDataCells != null)
                {
                    for (int i = 0; i < allDataCells.Count; i++)
                    {
                        string cellText = allDataCells[i].InnerText;
                        if (cellText.Contains("Birr") && !cellText.Contains("Settled"))
                        {
                            if (i >= 2)
                            {
                                transactionId = HtmlEntity.DeEntitize(allDataCells[i - 2].InnerText).Trim();
                                string amountRaw = cellText.ToLower().Replace("birr", "").Replace(",", "").Trim();
                                decimal.TryParse(amountRaw, NumberStyles.Any, CultureInfo.InvariantCulture, out amount);
                                if (amount > 0) break;
                            }
                        }
                    }
                }

                if (string.IsNullOrEmpty(transactionId))
                    transactionId = receiptUrl.Split('/').Last().Split('?').First();

                Console.WriteLine($"[TELEBIRR] Extracted -> ID: {transactionId}, Name: {creditedName}, Amt: {amount}");

                if (amount <= 0 || string.IsNullOrEmpty(creditedName))
                    return null;

                return new TelebirrReceipt(transactionId, creditedName, creditedAccount, amount);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[TELEBIRR] Error fetching {receiptUrl}: {ex.Message}");
                return null;
            }
        }


        /* ================= CBE ================= */

        public async Task<CbeReceipt?> ValidateTCBEPayment(string smsText)
        {
            try
            {
                var receiptUrl = ExtractUrl(smsText);
                var reference = ExtractCbeReference(receiptUrl);

                Console.WriteLine($"[CBE] Fetching PDF from: {receiptUrl}");
                var pdfBytes = await _http.GetByteArrayAsync(receiptUrl);

                using var pdf = PdfDocument.Open(pdfBytes);
                var text = string.Join(" ", pdf.GetPages().Select(p => p.Text));

                // CRITICAL: PDF extraction often removes spaces between labels and values
                // We normalize whitespace but keep the "squeezed" structure
                text = Regex.Replace(text, @"\s+", " ");

                // 1. Extract Receiver Name
                // Matches everything between 'Receiver' and 'Account' (non-greedy)
                string receiver = string.Empty;
                var receiverMatch = Regex.Match(text, @"Receiver\s*(.*?)\s*(?=Account)", RegexOptions.IgnoreCase);
                if (receiverMatch.Success)
                    receiver = receiverMatch.Groups[1].Value.Trim();

                // 2. Extract Receiver Account
                // Usually the second account (1****XXXX) in the receipt
                string account = string.Empty;
                var accountMatches = Regex.Matches(text, @"\d\*+\d{4}");
                if (accountMatches.Count >= 2)
                    account = accountMatches[1].Value;

                // 3. Extract Amount
                // Matches digits after 'Transferred Amount' even if touching
                decimal amount = 0;
                var amountMatch = Regex.Match(text, @"Transferred\s*Amount\s*([\d,.]+)", RegexOptions.IgnoreCase);
                if (amountMatch.Success)
                {
                    string amountStr = amountMatch.Groups[1].Value.Replace(",", "");
                    decimal.TryParse(amountStr, NumberStyles.Any, CultureInfo.InvariantCulture, out amount);
                }

                Console.WriteLine($"[CBE] Parsed -> Ref: {reference}, Rec: {receiver}, Acc: {account}, Amt: {amount}");

                if (amount <= 0 || string.IsNullOrWhiteSpace(receiver) || string.IsNullOrWhiteSpace(account))
                {
                    Console.WriteLine("[CBE] Validation failed: Missing data fields.");
                    return null;
                }

                return new CbeReceipt(reference, receiver, GetLast4Digits(account), amount);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[CBE] Error: {ex.Message}");
                return null;
            }
        }

        /* ================= HELPERS ================= */

        private static string ExtractUrl(string text)
        {
            // Better URL regex that finds http/https links
            var match = Regex.Match(text, @"https?:\/\/[^\s\)]+");
            if (!match.Success)
                throw new InvalidOperationException("Receipt URL not found");

            // Trim common punctuation that might get caught at the end of the URL in SMS
            return match.Value.TrimEnd('.', ')', ',', '!');
        }

        private static string ExtractCbeReference(string url)
        {
            var match = Regex.Match(url, @"[?&]id=([A-Z0-9]+)");
            if (match.Success) return match.Groups[1].Value;

            return url.Split('/').Last().Split('?').First();
        }

        private static string GetLast4Digits(string account)
        {
            if (string.IsNullOrEmpty(account)) return string.Empty;
            var digits = new string(account.Where(char.IsDigit).ToArray());
            return digits.Length >= 4 ? digits.Substring(digits.Length - 4) : digits;
        }
    }
}