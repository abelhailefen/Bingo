using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Microsoft.EntityFrameworkCore;

namespace Bingo.Infrastructure.Context;

public class BingoDbContext : DbContext
{
    public BingoDbContext(DbContextOptions<BingoDbContext> options)
        : base(options) { }

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

        /* ============================================================
         * PostgreSQL Enums
         * ============================================================ */
        modelBuilder.HasPostgresEnum<RoomStatusEnum>();
        modelBuilder.HasPostgresEnum<WinPatternEnum>();
        modelBuilder.HasPostgresEnum<WinTypeEnum>();

        /* ============================================================
         * Users
         * ============================================================ */
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");

            entity.HasKey(e => e.UserId);

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.Username)
                .HasColumnName("username")
                .HasMaxLength(50)
                .IsRequired();

            entity.HasIndex(e => e.Username).IsUnique();

            entity.Property(e => e.PhoneNumber)
                .HasColumnName("phone_number")
                .HasMaxLength(100)
                .IsRequired();

            entity.HasIndex(e => e.PhoneNumber).IsUnique();

            entity.Property(e => e.PasswordHash)
                .HasColumnName("password_hash")
                .HasMaxLength(255)
                .IsRequired();

            entity.Property(e => e.Balance)
                .HasColumnName("balance")
                .HasPrecision(10, 2)
                .HasDefaultValue(0);

            entity.Property(e => e.CreatedAt)
                .HasColumnName("created_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(e => e.UpdatedAt)
                .HasColumnName("updated_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");
        });

        /* ============================================================
         * Rooms
         * ============================================================ */
        modelBuilder.Entity<Room>(entity =>
        {
            entity.ToTable("rooms");

            entity.HasKey(e => e.RoomId);

            entity.Property(e => e.RoomId)
                .HasColumnName("room_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.RoomCode)
                .HasColumnName("room_code")
                .HasMaxLength(10)
                .IsRequired();

            entity.HasIndex(e => e.RoomCode).IsUnique();

            entity.Property(e => e.Name)
                .HasColumnName("name")
                .HasMaxLength(100)
                .IsRequired();

            entity.Property(e => e.HostUserId)
                .HasColumnName("host_user_id")
                .IsRequired();

            entity.Property(e => e.Status)
                .HasColumnName("status")
                .HasDefaultValue(RoomStatusEnum.Waiting);

            entity.Property(e => e.MaxPlayers)
                .HasColumnName("max_players")
                .HasDefaultValue(100);

            entity.Property(e => e.CardPrice)
                .HasColumnName("card_price")
                .HasPrecision(8, 2)
                .HasDefaultValue(0);

            entity.Property(e => e.Pattern)
                .HasColumnName("pattern")
                .HasDefaultValue(WinPatternEnum.Line);

            entity.Property(e => e.CreatedAt)
                .HasColumnName("created_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(e => e.StartedAt)
                .HasColumnName("started_at");

            entity.Property(e => e.EndedAt)
                .HasColumnName("ended_at");

            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.HostUserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
         * Room Players
         * ============================================================ */
        modelBuilder.Entity<RoomPlayer>(entity =>
        {
            entity.ToTable("room_players");

            entity.HasKey(e => e.RoomPlayerId);

            entity.Property(e => e.RoomPlayerId)
                .HasColumnName("room_player_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.RoomId)
                .HasColumnName("room_id")
                .IsRequired();

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .IsRequired();

            entity.Property(e => e.JoinedAt)
                .HasColumnName("joined_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(e => e.IsReady)
                .HasColumnName("is_ready")
                .HasDefaultValue(false);

            entity.HasIndex(e => new { e.RoomId, e.UserId }).IsUnique();

            entity.HasOne<Room>()
                .WithMany()
                .HasForeignKey(e => e.RoomId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
         * Cards
         * ============================================================ */
        modelBuilder.Entity<Card>(entity =>
        {
            entity.ToTable("cards");

            entity.HasKey(e => e.CardId);

            entity.Property(e => e.CardId)
                .HasColumnName("card_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.RoomId)
                .HasColumnName("room_id")
                .IsRequired();

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .IsRequired();

            entity.Property(e => e.PurchasedAt)
                .HasColumnName("purchased_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne<Room>()
                .WithMany()
                .HasForeignKey(e => e.RoomId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne<User>()
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
         * Card Numbers
         * ============================================================ */
        modelBuilder.Entity<CardNumber>(entity =>
        {
            entity.ToTable("card_numbers");

            entity.HasKey(e => e.CardNumberId);

            entity.Property(e => e.CardNumberId)
                .HasColumnName("card_number_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.CardId)
                .HasColumnName("card_id")
                .IsRequired();

            entity.Property(e => e.PositionRow)
                .HasColumnName("position_row")
                .IsRequired();

            entity.Property(e => e.PositionCol)
                .HasColumnName("position_col")
                .IsRequired();

            entity.Property(e => e.Number)
                .HasColumnName("number")
                .IsRequired();

            entity.Property(e => e.IsMarked)
                .HasColumnName("is_marked")
                .HasDefaultValue(false);

            entity.HasIndex(e => new { e.CardId, e.PositionRow, e.PositionCol })
                .IsUnique();

            entity.HasOne<Card>()
                .WithMany()
                .HasForeignKey(e => e.CardId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
         * Called Numbers
         * ============================================================ */
        modelBuilder.Entity<CalledNumber>(entity =>
        {
            entity.ToTable("called_numbers");

            entity.HasKey(e => e.CalledId);

            entity.Property(e => e.CalledId)
                .HasColumnName("called_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.RoomId)
                .HasColumnName("room_id")
                .IsRequired();

            entity.Property(e => e.Number)
                .HasColumnName("number")
                .IsRequired();

            entity.Property(e => e.CalledAt)
                .HasColumnName("called_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasIndex(e => new { e.RoomId, e.Number }).IsUnique();

            entity.HasOne<Room>()
                .WithMany()
                .HasForeignKey(e => e.RoomId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
         * Wins
         * ============================================================ */
        modelBuilder.Entity<Win>(entity =>
        {
            entity.ToTable("wins");

            entity.HasKey(e => e.WinId);

            entity.Property(e => e.WinId)
                .HasColumnName("win_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.RoomId)
                .HasColumnName("room_id")
                .IsRequired();

            entity.Property(e => e.CardId)
                .HasColumnName("card_id")
                .IsRequired();

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .IsRequired();

            entity.Property(e => e.ClaimedAt)
                .HasColumnName("claimed_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(e => e.Verified)
                .HasColumnName("verified")
                .HasDefaultValue(false);

            entity.Property(e => e.VerifiedAt)
                .HasColumnName("verified_at");

            entity.Property(e => e.Prize)
                .HasColumnName("prize")
                .HasPrecision(10, 2)
                .HasDefaultValue(0);

            entity.Property(e => e.WinType)
                .HasColumnName("win_type")
                .HasDefaultValue(WinTypeEnum.Line);

            entity.HasOne<Room>().WithMany().HasForeignKey(e => e.RoomId);
            entity.HasOne<Card>().WithMany().HasForeignKey(e => e.CardId);
            entity.HasOne<User>().WithMany().HasForeignKey(e => e.UserId);
        });

        /* ============================================================
         * Room Chat
         * ============================================================ */
        modelBuilder.Entity<RoomChat>(entity =>
        {
            entity.ToTable("room_chat");

            entity.HasKey(e => e.MessageId);

            entity.Property(e => e.MessageId)
                .HasColumnName("message_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.RoomId)
                .HasColumnName("room_id")
                .IsRequired();

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .IsRequired();

            entity.Property(e => e.Message)
                .HasColumnName("message")
                .IsRequired();

            entity.Property(e => e.SentAt)
                .HasColumnName("sent_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne<Room>().WithMany().HasForeignKey(e => e.RoomId);
            entity.HasOne<User>().WithMany().HasForeignKey(e => e.UserId);
        });
    }
}
