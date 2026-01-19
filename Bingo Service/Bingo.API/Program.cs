using Bingo.Core.Services;
using Bingo.Infrastructure.Hubs;

using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Bingo.Infrastructure.Dependency;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Features.Gameplay.Contract.Command;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddBingoInfrastructure(builder.Configuration);
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(JoinLobbyCommand).Assembly));


builder.Services.AddSignalR();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(o => o.AddPolicy("AllowAll", p =>
    p.WithOrigins("http://localhost:53032") // Use your actual React URL here
     .AllowAnyMethod()
     .AllowAnyHeader()
     .AllowCredentials())); // Required for SignalRbuilder.Services.AddHostedService<TelegramBotService>();

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