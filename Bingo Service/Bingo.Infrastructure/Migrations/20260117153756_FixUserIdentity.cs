using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Bingo.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FixUserIdentity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Fix user_id identity column
            migrationBuilder.Sql("ALTER TABLE users ALTER COLUMN user_id DROP IDENTITY IF EXISTS;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Restore identity (optional, but good for reversibility)
            migrationBuilder.Sql("ALTER TABLE users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY;");
        }
    }
}
