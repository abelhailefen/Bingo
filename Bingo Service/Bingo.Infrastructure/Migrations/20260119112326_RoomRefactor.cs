using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Bingo.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RoomRefactor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_rooms_users_host_user_id",
                table: "rooms");

            migrationBuilder.DropIndex(
                name: "IX_rooms_host_user_id",
                table: "rooms");

            migrationBuilder.DropColumn(
                name: "host_user_id",
                table: "rooms");

            migrationBuilder.RenameColumn(
                name: "PositionRow",
                table: "master_card_numbers",
                newName: "position_row");

            migrationBuilder.RenameColumn(
                name: "PositionCol",
                table: "master_card_numbers",
                newName: "position_col");

            migrationBuilder.AddColumn<DateTime>(
                name: "ScheduledStartTime",
                table: "rooms",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "UserId",
                table: "rooms",
                type: "bigint",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_rooms_UserId",
                table: "rooms",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_rooms_users_UserId",
                table: "rooms",
                column: "UserId",
                principalTable: "users",
                principalColumn: "user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_rooms_users_UserId",
                table: "rooms");

            migrationBuilder.DropIndex(
                name: "IX_rooms_UserId",
                table: "rooms");

            migrationBuilder.DropColumn(
                name: "ScheduledStartTime",
                table: "rooms");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "rooms");

            migrationBuilder.RenameColumn(
                name: "position_row",
                table: "master_card_numbers",
                newName: "PositionRow");

            migrationBuilder.RenameColumn(
                name: "position_col",
                table: "master_card_numbers",
                newName: "PositionCol");

            migrationBuilder.AddColumn<long>(
                name: "host_user_id",
                table: "rooms",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateIndex(
                name: "IX_rooms_host_user_id",
                table: "rooms",
                column: "host_user_id");

            migrationBuilder.AddForeignKey(
                name: "FK_rooms_users_host_user_id",
                table: "rooms",
                column: "host_user_id",
                principalTable: "users",
                principalColumn: "user_id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
