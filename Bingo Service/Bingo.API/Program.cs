using Bingo.API.Services;
using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileSystemGlobbing.Internal;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// 1. Configure Npgsql Data Source with Enums
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);

// Map your C# enums to the Postgres types
dataSourceBuilder.MapEnum<RoomStatusEnum>();
dataSourceBuilder.MapEnum<WinPatternEnum>();
dataSourceBuilder.MapEnum<WinTypeEnum>();

var dataSource = dataSourceBuilder.Build();

// 2. Add DbContext using the data source
builder.Services.AddDbContext<BingoDbContext>(options =>
    options.UseNpgsql(dataSource));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});
builder.Services.AddHostedService<TelegramBotService>();
builder.Services.AddDbContext<BingoDbContext>(options =>
    options.UseNpgsql(dataSource)
           .UseSnakeCaseNamingConvention());
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.Run();