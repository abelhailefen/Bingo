using Microsoft.AspNetCore.Mvc;
using Bingo.Core.Models;

namespace Bingo.API.Controllers;

[ApiController]
[Route("api/webhook")]
public class WebhookController : ControllerBase
{
    [HttpPost("telegram")]
    public IActionResult HandleTelegramWebhook([FromBody] object update)
    {
        // This receives updates from Telegram Bot API
        // Typically dispatched to a service to handle commands.
        // Since we have `TelegramBotService` (Hosted Service) which likely uses Long Polling or can be configured for Webhook.
        // If using polling, this might not be needed.
        // If using webhook, we need to pass this update to the bot client.
        
        // For now, just log and return OK to acknowledge telegram.
        // Assuming the HostedService handles everything via Polling or this controller needs to push to mediator.
        
        // Placeholder implementation
        return Ok();
    }
}
