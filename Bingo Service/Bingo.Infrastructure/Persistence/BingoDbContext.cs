using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Microsoft.EntityFrameworkCore;

namespace Bingo.Infrastructure.Persistence;

public class BingoDbContext : DbContext
{
    public BingoDbContext(DbContextOptions<BingoDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<RoomPlayer> RoomPlayers => Set<RoomPlayer>();
    public DbSet<Card> Cards => Set<Card>();
    public DbSet<CardNumber> CardNumbers => Set<CardNumber>();
    public DbSet<CalledNumber> CalledNumbers => Set<CalledNumber>();
    public DbSet<Win> Wins => Set<Win>();
    public DbSet<RoomChat> RoomChats => Set<RoomChat>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // 1. Enums (Postgres specific)
        // Note: You must register these in Program.cs as well for Npgsql
        modelBuilder.HasPostgresEnum<RoomStatusEnum>();
        modelBuilder.HasPostgresEnum<WinPatternEnum>();
        modelBuilder.HasPostgresEnum<WinTypeEnum>();

        // 2. Users
        modelBuilder.Entity<User>(entity => {
            entity.ToTable("users");
            entity.HasKey(e => e.UserId);
            entity.Property(e => e.UserId).UseIdentityAlwaysColumn().HasColumnName("user_id");
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Balance).HasPrecision(10, 2);
        });

        // 3. Rooms
        modelBuilder.Entity<Room>(entity => {
            entity.ToTable("rooms");
            entity.HasKey(e => e.RoomId);
            entity.Property(e => e.RoomId).UseIdentityAlwaysColumn().HasColumnName("room_id");
            entity.Property(e => e.CardPrice).HasPrecision(8, 2);

            entity.HasOne(d => d.Host)
                .WithMany(p => p.HostedRooms)
                .HasForeignKey(d => d.HostUserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // 4. Room Players (Many-to-Many Join Table)
        modelBuilder.Entity<RoomPlayer>(entity => {
            entity.ToTable("room_players");
            entity.HasKey(e => e.RoomPlayerId);
            entity.Property(e => e.RoomPlayerId).UseIdentityAlwaysColumn().HasColumnName("room_player_id");
            entity.HasIndex(e => new { e.RoomId, e.UserId }).IsUnique();
        });

        // 5. Cards
        modelBuilder.Entity<Card>(entity => {
            entity.ToTable("cards");
            entity.HasKey(e => e.CardId);
            entity.Property(e => e.CardId).UseIdentityAlwaysColumn().HasColumnName("card_id");
        });

        // 6. Card Numbers (Composite Unique Constraint)
        modelBuilder.Entity<CardNumber>(entity => {
            entity.ToTable("card_numbers");
            entity.HasKey(e => e.CardNumberId);
            entity.Property(e => e.CardNumberId).UseIdentityAlwaysColumn().HasColumnName("card_number_id");
            entity.HasIndex(e => new { e.CardId, e.PositionRow, e.PositionCol }).IsUnique();
        });

        // 7. Called Numbers
        modelBuilder.Entity<CalledNumber>(entity => {
            entity.ToTable("called_numbers");
            entity.HasKey(e => e.CalledId);
            entity.Property(e => e.CalledId).UseIdentityAlwaysColumn().HasColumnName("called_id");
            entity.HasIndex(e => new { e.RoomId, e.Number }).IsUnique();
        });

        // 8. Wins
        modelBuilder.Entity<Win>(entity => {
            entity.ToTable("wins");
            entity.HasKey(e => e.WinId);
            entity.Property(e => e.WinId).UseIdentityAlwaysColumn().HasColumnName("win_id");
            entity.Property(e => e.Prize).HasPrecision(10, 2);
        });

        // 9. Chat
        modelBuilder.Entity<RoomChat>(entity => {
            entity.ToTable("room_chat");
            entity.HasKey(e => e.MessageId);
            entity.Property(e => e.MessageId).UseIdentityAlwaysColumn().HasColumnName("message_id");
        });
    }
}