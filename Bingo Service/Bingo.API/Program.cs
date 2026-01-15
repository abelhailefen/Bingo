using Bingo.Infrastructure.Service;
using Bingo.Infrastructure.Hubs;

using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Bingo.Infrastructure.Dependency;
using Bingo.Core.Features.Rooms.Contract.Command;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddBingoInfrastructure(builder.Configuration);
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(JoinRoomCommand).Assembly));


builder.Services.AddSignalR();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(o => o.AddPolicy("AllowAll", p => p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));
builder.Services.AddHostedService<TelegramBotService>();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();
app.MapHub<BingoHub>("/bingoHub");
app.MapGet("/", () => "Bingo API is Online");

Console.WriteLine("=== APPLICATION READY ===");
app.Run();