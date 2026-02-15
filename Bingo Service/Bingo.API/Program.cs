using Bingo.Core.Services;
using Bingo.Core.Hubs;
using Telegram.Bot; // Add this using

using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Bingo.Infrastructure.Dependency;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Features.Gameplay.Contract.Command;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<ITelegramBotClient>(provider =>
    new TelegramBotClient(builder.Configuration["TelegramBot:Token"]!));

builder.Services.AddBingoInfrastructure(builder.Configuration);
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(JoinLobbyCommand).Assembly));

// Register BotPlayerService for bot management
builder.Services.AddScoped<BotPlayerService>();

builder.Services.AddHostedService<TelegramBotService>();
builder.Services.AddSignalR();
builder.Services.AddHostedService<RoomManagerService>();
builder.Services.AddControllers().AddJsonOptions(options =>
{
    // This prevents the infinite loop: MasterCard -> Number -> MasterCard
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
}); ;
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
// Program.cs
builder.Services.AddCors(o => o.AddPolicy("AllowAll", p =>
    p.SetIsOriginAllowed(_ => true) // Allow any origin (Ngrok URLs change)
     .AllowAnyMethod()
     .AllowAnyHeader()
     .AllowCredentials()));
var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();
app.MapHub<BingoHub>("/bingohub"); 
app.MapGet("/", () => "Bingo API is Online");

Console.WriteLine("=== APPLICATION READY ===");
app.Run();