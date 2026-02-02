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
            _http.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
        }

        /* ================= TELEBIRR ================= */

        public async Task<TelebirrReceipt?> ValidateTeleBirrPayment(string smsText)
        {
            try
            {
                var receiptUrl = ExtractUrl(smsText);
                // Remove trailing dots from URL if regex caught them from the SMS
                receiptUrl = receiptUrl.TrimEnd('.');

                var html = await _http.GetStringAsync(receiptUrl);
                var doc = new HtmlDocument();
                doc.LoadHtml(html);

                // 1. Extract Name
                // Logic: Find TD that contains 'Credited Party name', get the next TD
                var nameNode = doc.DocumentNode.SelectSingleNode("//td[contains(text(), 'Credited Party name')]/following-sibling::td");
                string creditedName = HtmlEntity.DeEntitize(nameNode?.InnerText ?? "").Trim();

                // 2. Extract Account
                var accountNode = doc.DocumentNode.SelectSingleNode("//td[contains(text(), 'Credited party account no')]/following-sibling::td");
                string creditedAccount = HtmlEntity.DeEntitize(accountNode?.InnerText ?? "").Trim();

                // 3. Extract Transaction ID and Amount
                // These are in cells with class 'receipttableTd'
                var allDataCells = doc.DocumentNode.SelectNodes("//td[contains(@class, 'receipttableTd')]");

                string transactionId = "";
                decimal amount = 0;

                if (allDataCells != null)
                {
                    // We are looking for the row that has the actual data.
                    // In your HTML, the 3rd <td> in the data row contains "Birr"
                    for (int i = 0; i < allDataCells.Count; i++)
                    {
                        string cellText = allDataCells[i].InnerText;

                        if (cellText.Contains("Birr") && !cellText.Contains("Settled Amount"))
                        {
                            // Found the amount cell!
                            // Amount is usually cells[i]
                            // Date is usually cells[i-1]
                            // Transaction ID is usually cells[i-2]

                            if (i >= 2)
                            {
                                transactionId = HtmlEntity.DeEntitize(allDataCells[i - 2].InnerText).Trim();

                                string amountRaw = cellText.ToLower().Replace("birr", "").Replace(",", "").Trim();
                                decimal.TryParse(amountRaw, NumberStyles.Any, CultureInfo.InvariantCulture, out amount);

                                // If we found a valid amount, we can stop searching
                                if (amount > 0) break;
                            }
                        }
                    }
                }

                // Final fallback for Transaction ID from URL if scraping failed
                if (string.IsNullOrEmpty(transactionId))
                {
                    transactionId = receiptUrl.Split('/').Last().Split('?').First();
                }

                Console.WriteLine($"Extracted -> ID: '{transactionId}', Name: '{creditedName}', Acc: '{creditedAccount}', Amt: {amount}");

                if (amount <= 0 || string.IsNullOrEmpty(creditedName))
                    return null;

                return new TelebirrReceipt(transactionId, creditedName, creditedAccount, amount);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Scraping Error: {ex.Message}");
                return null;
            }
        }


        /* ================= CBE ================= */


        public async Task<CbeReceipt?> ValidateTCBEPayment(string smsText)
        {
            try
            {
                var receiptUrl = ExtractUrl(smsText);
                // The URL ID is a better unique reference than the short Reference No inside the PDF
                var urlReference = ExtractCbeReference(receiptUrl);

                Console.WriteLine($"Fetching CBE PDF from: {receiptUrl}");

                var pdfBytes = await _http.GetByteArrayAsync(receiptUrl);

                using var pdf = PdfDocument.Open(pdfBytes);
                // Join text from all pages with a space to ensure we can regex across lines
                var text = string.Join(" ", pdf.GetPages().Select(p => p.Text));

                // Clean up whitespace (PDFs often have multiple spaces/newlines)
                text = Regex.Replace(text, @"\s+", " ");

                Console.WriteLine($"Extracted PDF Text: {text}");

                // 1. Extract Receiver Name
                // Logic: Look for text between "Receiver" and "Account"
                string receiver = string.Empty;
                var receiverMatch = Regex.Match(text, @"Receiver\s+(.*?)\s+Account", RegexOptions.IgnoreCase);
                if (receiverMatch.Success)
                {
                    receiver = receiverMatch.Groups[1].Value.Trim();
                }

                // 2. Extract Receiver Account (The second account mentioned in the file)
                // Logic: Find all patterns like 1****3124
                string account = string.Empty;
                var accountMatches = Regex.Matches(text, @"\d\*+\d{4}");
                if (accountMatches.Count >= 2)
                {
                    // The second one is the Receiver's account
                    account = accountMatches[1].Value;
                }

                // 3. Extract Transferred Amount
                // Logic: Look for "Transferred Amount" followed by "ETB"
                decimal amount = 0;
                var amountMatch = Regex.Match(text, @"Transferred Amount\s+([\d,.]+)\s+ETB", RegexOptions.IgnoreCase);
                if (amountMatch.Success)
                {
                    string amountStr = amountMatch.Groups[1].Value.Replace(",", "");
                    decimal.TryParse(amountStr, NumberStyles.Any, CultureInfo.InvariantCulture, out amount);
                }

                // 4. Extract Internal Reference (Optional validation)
                var pdfRefMatch = Regex.Match(text, @"Reference No\.\s+\(VAT Invoice No\)\s+([A-Z0-9]+)", RegexOptions.IgnoreCase);
                string pdfReference = pdfRefMatch.Success ? pdfRefMatch.Groups[1].Value : urlReference;

                Console.WriteLine($"Parsed -> Ref: {pdfReference}, Rec: {receiver}, Acc: {account}, Amt: {amount}");

                if (amount <= 0 || string.IsNullOrWhiteSpace(receiver) || string.IsNullOrWhiteSpace(account))
                {
                    return null;
                }

                return new CbeReceipt(
                    urlReference, // Use the full URL ID as the DB key to prevent reuse
                    receiver,
                    GetLast4Digits(account),
                    amount
                );
            }
            catch (Exception ex)
            {
                Console.WriteLine($"CBE Validation Error: {ex.Message}");
                return null;
            }
        }

        private static string ExtractCbeReference(string url)
        {
            // Extract everything after 'id='
            var match = Regex.Match(url, @"id=([A-Z0-9]+)");
            if (match.Success)
                return match.Groups[1].Value;

            throw new InvalidOperationException("Invalid CBE receipt URL format");
        }

        private static decimal ExtractCbeAmount(string text)
        {
            try
            {
                Console.WriteLine("Looking for Transferred Amount in CBE PDF...");

                // Pattern to find "Transferred Amount" followed by the amount
                var pattern = @"Transferred\s+Amount[^\d]*(\d[\d,]*\.\d{2})";
                var match = Regex.Match(text, pattern, RegexOptions.IgnoreCase);

                if (match.Success)
                {
                    var amountStr = match.Groups[1].Value.Replace(",", "");
                    Console.WriteLine($"Found amount via regex: {amountStr}");

                    if (decimal.TryParse(amountStr, NumberStyles.Any, CultureInfo.InvariantCulture, out var amount))
                    {
                        return amount;
                    }
                }

                // Alternative: Look for amount with ETB suffix
                var etbPattern = @"(\d[\d,]*\.\d{2})\s*ETB";
                var etbMatches = Regex.Matches(text, etbPattern);

                Console.WriteLine($"Found {etbMatches.Count} ETB amount matches");

                // The first ETB amount is usually the transferred amount
                if (etbMatches.Count > 0)
                {
                    var amountStr = etbMatches[0].Groups[1].Value.Replace(",", "");
                    Console.WriteLine($"First ETB amount: {amountStr}");

                    if (decimal.TryParse(amountStr, NumberStyles.Any, CultureInfo.InvariantCulture, out var amount))
                    {
                        return amount;
                    }
                }

                throw new InvalidOperationException("CBE amount not found");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in ExtractCbeAmount: {ex.Message}");
                throw;
            }
        }

        /* ================= HELPERS ================= */

        private static string GetLast4Digits(string account)
        {
            if (string.IsNullOrEmpty(account))
                return string.Empty;

            // Remove any non-digit characters and get last 4 digits
            var digits = new string(account.Where(char.IsDigit).ToArray());
            return digits.Length >= 4 ? digits.Substring(digits.Length - 4) : digits;
        }

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

      
    }
}