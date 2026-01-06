using Bingo.API.Services;
using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// --- 1. CONNECTION STRING LOGIC ---
// Look for 'ConnectionStrings:DefaultConnection' (from appsettings or Render Env Var)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// Fallback to 'DATABASE_URL' (Render's internal variable) if the above is empty
if (string.IsNullOrWhiteSpace(connectionString))
{
    connectionString = Environment.GetEnvironmentVariable("DATABASE_URL");
}

Console.WriteLine("--- System Startup ---");

if (string.IsNullOrWhiteSpace(connectionString))
{
    Console.WriteLine("ERROR: No connection string found in Environment Variables or Configuration.");
    throw new Exception("Connection string is missing.");
}

connectionString = connectionString.Trim();

// If the string is a URI (starts with postgres://), convert it for Npgsql
if (connectionString.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase))
{
    Console.WriteLine("Detected URI format (postgres://). Converting to Key-Value format...");
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

        Console.WriteLine("Conversion successful.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"ERROR parsing connection string: {ex.Message}");
        throw;
    }
}

// --- 2. CONFIGURE NPGSQL DATA SOURCE ---
// This is required for mapping Enums to Postgres
var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);

// Map your C# enums to the Postgres types
dataSourceBuilder.MapEnum<RoomStatusEnum>();
dataSourceBuilder.MapEnum<WinPatternEnum>();
dataSourceBuilder.MapEnum<WinTypeEnum>();

var dataSource = dataSourceBuilder.Build();

// --- 3. REGISTER SERVICES ---
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure CORS for your Vercel frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

// Register the DbContext
builder.Services.AddDbContext<BingoDbContext>(options =>
    options.UseNpgsql(dataSource)
           .UseSnakeCaseNamingConvention());

// Register the Telegram Bot as a background service
builder.Services.AddHostedService<TelegramBotService>();

var app = builder.Build();

// --- 4. CONFIGURE HTTP PIPELINE ---

// Enable Swagger on all environments for now so you can test on Render easily
app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

// Simple health check endpoint for Render
app.MapGet("/", () => "Bingo API is running and Bot is active!");

Console.WriteLine("Application starting...");
app.Run();