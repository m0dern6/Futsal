using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FutsalApi.Data.Migrations
{
    /// <inheritdoc />
    public partial class RemoveUrlInImage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Url",
                table: "Images");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Url",
                table: "Images",
                type: "text",
                nullable: false,
                defaultValue: "");
        }
    }
}
