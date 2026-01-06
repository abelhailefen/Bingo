using Bingo.API.Services;
using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileSystemGlobbing.Internal;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// 1. Get the connection string from Environment or Config
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

if (string.IsNullOrEmpty(connectionString))
{
    throw new Exception("Connection string is missing! Check Render Environment Variables.");
}

// 2. CONVERT URI FORMAT (postgres://) TO KEY-VALUE FORMAT
// Render provides a URL, but .NET needs Key=Value
if (connectionString.StartsWith("postgres://"))
{
    var databaseUri = new Uri(connectionString);
    var userInfo = databaseUri.UserInfo.Split(':');

    connectionString = $"Host={databaseUri.Host};Port={databaseUri.Port};Database={databaseUri.AbsolutePath.TrimStart('/')};Username={userInfo[0]};Password={userInfo[1]};SSL Mode=Require;Trust Server Certificate=true;";
}

// 3. Configure Npgsql Data Source with Enums
var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
dataSourceBuilder.MapEnum<RoomStatusEnum>();
dataSourceBuilder.MapEnum<WinPatternEnum>();
dataSourceBuilder.MapEnum<WinTypeEnum>();

var dataSource = dataSourceBuilder.Build();

// 4. Add DbContext
builder.Services.AddDbContext<BingoDbContext>(options =>
    options.UseNpgsql(dataSource)
           .UseSnakeCaseNamingConvention());

// ... rest of your code (AddControllers, CORS, etc.)
// REMOVE the second builder.Services.AddDbContext call at the bottom of your file
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