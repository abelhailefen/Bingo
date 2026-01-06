using Bingo.API.Services;
using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

Console.WriteLine("=== BINGO BACKEND STARTING ===");

// 1. Prioritize DATABASE_URL (Render's internal variable)
// Then check for ConnectionStrings:DefaultConnection
string? rawConnectionString = Environment.GetEnvironmentVariable("DATABASE_URL")
                             ?? builder.Configuration.GetConnectionString("DefaultConnection")
                             ?? Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");

if (string.IsNullOrWhiteSpace(rawConnectionString))
{
    Console.WriteLine("CRITICAL: No connection string found in environment variables!");
    throw new Exception("Missing Database Connection String");
}

// 2. Clean the string (Remove any hidden spaces or quotes from index 0)
string connectionString = rawConnectionString.Trim().Replace("\"", "");

Console.WriteLine($"Debug: Connection string length: {connectionString.Length}");
Console.WriteLine($"Debug: First 10 characters: {connectionString.Substring(0, Math.Min(10, connectionString.Length))}");

// 3. Convert URI format (postgres://) to Npgsql Key-Value format
if (connectionString.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase))
{
    Console.WriteLine("Action: Converting postgres:// URI to Key-Value format...");
    try
    {
        var databaseUri = new Uri(connectionString);
        var userInfo = databaseUri.UserInfo.Split(':');

        connectionString = $"Host={databaseUri.Host};" +
                           $"Port={databaseUri.Port};" +
                           $"Database={databaseUri.AbsolutePath.TrimStart('/')};" +
                           $"Username={userInfo[0]};" +
                           $"Password={userInfo[1]};" +
                           $"SSL Mode=Require;Trust Server Certificate=true;";

        Console.WriteLine("Action: Conversion complete.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"CRITICAL: Error parsing URI: {ex.Message}");
        throw;
    }
}
else
{
    Console.WriteLine("Action: Using connection string as-is (Already in Key-Value format).");
    // Ensure SSL is enabled for Render if not already in the string
    if (!connectionString.Contains("SSL Mode", StringComparison.OrdinalIgnoreCase))
    {
        connectionString += ";SSL Mode=Require;Trust Server Certificate=true;";
    }
}

// --- DATABASE & SERVICES SETUP ---

try
{
    var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
    dataSourceBuilder.MapEnum<RoomStatusEnum>();
    dataSourceBuilder.MapEnum<WinPatternEnum>();
    dataSourceBuilder.MapEnum<WinTypeEnum>();
    var dataSource = dataSourceBuilder.Build();

    builder.Services.AddDbContext<BingoDbContext>(options =>
        options.UseNpgsql(dataSource)
               .UseSnakeCaseNamingConvention());
}
catch (Exception ex)
{
    Console.WriteLine($"CRITICAL: Npgsql Setup Failed: {ex.Message}");
    throw;
}

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
app.MapGet("/", () => "Bingo API is Online");

Console.WriteLine("=== APPLICATION READY ===");
app.Run();