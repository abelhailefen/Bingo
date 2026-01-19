using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Bingo.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddMasterCardsRefactor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "card_numbers");

            migrationBuilder.DropTable(
                name: "room_chat");

            

            migrationBuilder.AddColumn<long>(
                name: "master_card_id",
                table: "cards",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AlterColumn<int>(
                name: "number",
                table: "called_numbers",
                type: "integer",
                nullable: false,
                oldClrType: typeof(short),
                oldType: "smallint");

            migrationBuilder.CreateTable(
                name: "master_cards",
                columns: table => new
                {
                    master_card_id = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_master_cards", x => x.master_card_id);
                });

            migrationBuilder.CreateTable(
                name: "master_card_numbers",
                columns: table => new
                {
                    master_card_number_id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    master_card_id = table.Column<long>(type: "bigint", nullable: false),
                    PositionRow = table.Column<int>(type: "integer", nullable: false),
                    PositionCol = table.Column<int>(type: "integer", nullable: false),
                    number = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_master_card_numbers", x => x.master_card_number_id);
                    table.ForeignKey(
                        name: "FK_master_card_numbers_master_cards_master_card_id",
                        column: x => x.master_card_id,
                        principalTable: "master_cards",
                        principalColumn: "master_card_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_cards_master_card_id",
                table: "cards",
                column: "master_card_id");

            migrationBuilder.CreateIndex(
                name: "IX_cards_room_id_user_id_master_card_id",
                table: "cards",
                columns: new[] { "room_id", "user_id", "master_card_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_master_card_numbers_master_card_id",
                table: "master_card_numbers",
                column: "master_card_id");

            migrationBuilder.AddForeignKey(
                name: "FK_cards_master_cards_master_card_id",
                table: "cards",
                column: "master_card_id",
                principalTable: "master_cards",
                principalColumn: "master_card_id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_cards_master_cards_master_card_id",
                table: "cards");

            migrationBuilder.DropTable(
                name: "master_card_numbers");

            migrationBuilder.DropTable(
                name: "master_cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_master_card_id",
                table: "cards");

            migrationBuilder.DropIndex(
                name: "IX_cards_room_id_user_id_master_card_id",
                table: "cards");

            migrationBuilder.DropColumn(
                name: "master_card_id",
                table: "cards");


            migrationBuilder.AlterColumn<short>(
                name: "number",
                table: "called_numbers",
                type: "smallint",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.CreateTable(
                name: "card_numbers",
                columns: table => new
                {
                    card_number_id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    card_id = table.Column<long>(type: "bigint", nullable: false),
                    is_marked = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    number = table.Column<short>(type: "smallint", nullable: false),
                    position_col = table.Column<short>(type: "smallint", nullable: false),
                    position_row = table.Column<short>(type: "smallint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_card_numbers", x => x.card_number_id);
                    table.ForeignKey(
                        name: "FK_card_numbers_cards_card_id",
                        column: x => x.card_id,
                        principalTable: "cards",
                        principalColumn: "card_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "room_chat",
                columns: table => new
                {
                    message_id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    room_id = table.Column<long>(type: "bigint", nullable: false),
                    user_id = table.Column<long>(type: "bigint", nullable: false),
                    message = table.Column<string>(type: "text", nullable: false),
                    sent_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_room_chat", x => x.message_id);
                    table.ForeignKey(
                        name: "FK_room_chat_rooms_room_id",
                        column: x => x.room_id,
                        principalTable: "rooms",
                        principalColumn: "room_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_room_chat_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "user_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_cards_room_id",
                table: "cards",
                column: "room_id");

            migrationBuilder.CreateIndex(
                name: "IX_card_numbers_card_id_position_row_position_col",
                table: "card_numbers",
                columns: new[] { "card_id", "position_row", "position_col" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_room_chat_room_id",
                table: "room_chat",
                column: "room_id");

            migrationBuilder.CreateIndex(
                name: "IX_room_chat_user_id",
                table: "room_chat",
                column: "user_id");
        }
    }
}
