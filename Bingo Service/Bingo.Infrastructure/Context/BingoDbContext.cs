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
    public DbSet<CalledNumber> CalledNumbers => Set<CalledNumber>();
    public DbSet<Win> Wins => Set<Win>();
    public DbSet<MasterCard> MasterCards => Set<MasterCard>();
    public DbSet<MasterCardNumber> MasterCardNumbers => Set<MasterCardNumber>();
    public DbSet<WithdrawalRequest> WithdrawalRequests => Set<WithdrawalRequest>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        /* ============================================================
         * Users
         * ============================================================ */
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");

            entity.HasKey(e => e.UserId);

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .ValueGeneratedNever();

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

            entity.Property(e => e.IsBot)
                .HasColumnName("is_bot")
                .HasDefaultValue(false);

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
            entity.Property(e => e.ScheduledStartTime)
                .HasColumnName("scheduled_start_time");
           

            // ENUM CONVERTED TO INT
            entity.Property(e => e.Status)
                .HasColumnName("status")
                .HasConversion<int>()
                .HasDefaultValue(RoomStatusEnum.Waiting);

            entity.Property(e => e.MaxPlayers)
                .HasColumnName("max_players")
                .HasDefaultValue(100);

            entity.Property(e => e.CardPrice)
                .HasColumnName("card_price")
                .HasPrecision(8, 2)
                .HasDefaultValue(0);

            // ENUM CONVERTED TO INT
            entity.Property(e => e.Pattern)
                .HasColumnName("pattern")
                .HasConversion<int>()
                .HasDefaultValue(WinPatternEnum.Line);

            entity.Property(e => e.CreatedAt)
                .HasColumnName("created_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(e => e.StartedAt)
                .HasColumnName("started_at");

            entity.Property(e => e.EndedAt)
                .HasColumnName("ended_at");

           
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

            entity.HasOne(e => e.Room)
                .WithMany(r => r.Players)
                .HasForeignKey(e => e.RoomId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.User)
                .WithMany(u => u.RoomParticipations)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
 * Master Cards
 * ============================================================ */
        modelBuilder.Entity<MasterCard>(entity =>
        {
            entity.ToTable("master_cards");
            entity.HasKey(e => e.MasterCardId);

            // Manual IDs (1-100)
            entity.Property(e => e.MasterCardId)
                .HasColumnName("master_card_id")
                .ValueGeneratedNever();
        });

        /* ============================================================
         * Master Card Numbers
         * ============================================================ */
        modelBuilder.Entity<MasterCardNumber>(entity =>
        {
            entity.ToTable("master_card_numbers");
            entity.HasKey(e => e.MasterCardNumberId);

            entity.Property(e => e.MasterCardNumberId)
                .HasColumnName("master_card_number_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.MasterCardId)
                .HasColumnName("master_card_id")
                .IsRequired();

            // ADD THESE TWO LINES:
            entity.Property(e => e.PositionRow)
                .HasColumnName("position_row")
                .IsRequired();

            entity.Property(e => e.PositionCol)
                .HasColumnName("position_col")
                .IsRequired();

            entity.Property(e => e.Number)
                .HasColumnName("number")
                .IsRequired(false);

            entity.HasOne(e => e.MasterCard)
                .WithMany(m => m.Numbers)
                .HasForeignKey(e => e.MasterCardId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
         * Cards (Player's Active Selection for a Room)
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

            entity.Property(e => e.MasterCardId)
                .HasColumnName("master_card_id")
                .IsRequired();

            entity.Property(e => e.PurchasedAt)
                .HasColumnName("purchased_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasIndex(e => new { e.RoomId, e.UserId, e.MasterCardId })
                .IsUnique();

            entity.HasOne(e => e.Room)
                .WithMany(r => r.Cards)
                .HasForeignKey(e => e.RoomId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.MasterCard)
                .WithMany()
                .HasForeignKey(e => e.MasterCardId)
                .OnDelete(DeleteBehavior.Restrict);
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

            entity.HasOne(e => e.Room)
                .WithMany(r => r.CalledNumbers)
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

            // ENUM CONVERTED TO INT
            entity.Property(e => e.WinType)
                .HasColumnName("win_type")
                .HasConversion<int>()
                .HasDefaultValue(WinTypeEnum.Line);

            entity.HasOne(e => e.Room).WithMany().HasForeignKey(e => e.RoomId);
            entity.HasOne(e => e.Card).WithMany().HasForeignKey(e => e.CardId);
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.ToTable("payments");

            entity.HasKey(e => e.PaymentId);

            entity.Property(e => e.PaymentId)
                .HasColumnName("payment_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .IsRequired();

            entity.Property(e => e.TransactionReference)
                .HasColumnName("transaction_reference")
                .HasMaxLength(100)
                .IsRequired();

            entity.HasIndex(e => e.TransactionReference).IsUnique();

            entity.Property(e => e.Amount)
                .HasColumnName("amount")
                .HasPrecision(10, 2)
                .IsRequired();

            entity.Property(e => e.Provider)
                .HasColumnName("provider")
                .HasConversion<int>()
                .IsRequired();

            entity.Property(e => e.CreatedAt)
                .HasColumnName("created_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.HasOne(e => e.User)
                .WithMany() // Or add a collection to User entity if preferred
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        /* ============================================================
         * Withdrawal Requests
         * ============================================================ */
        modelBuilder.Entity<WithdrawalRequest>(entity =>
        {
            entity.ToTable("withdrawal_requests");

            entity.HasKey(e => e.WithdrawalRequestId);

            entity.Property(e => e.WithdrawalRequestId)
                .HasColumnName("withdrawal_request_id")
                .UseIdentityAlwaysColumn();

            entity.Property(e => e.UserId)
                .HasColumnName("user_id")
                .IsRequired();

            entity.Property(e => e.Amount)
                .HasColumnName("amount")
                .HasPrecision(10, 2)
                .IsRequired();

            entity.Property(e => e.Status)
                .HasColumnName("status")
                .HasConversion<int>()
                .HasDefaultValue(WithdrawalStatusEnum.Pending);

            entity.Property(e => e.AdminComment)
                .HasColumnName("admin_comment")
                .HasMaxLength(500);

            entity.Property(e => e.CreatedAt)
                .HasColumnName("created_at")
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            entity.Property(e => e.ProcessedAt)
                .HasColumnName("processed_at");

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}