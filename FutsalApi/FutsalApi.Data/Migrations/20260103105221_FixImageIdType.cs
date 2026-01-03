using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FutsalApi.Data.Migrations
{
    /// <inheritdoc />
    public partial class FixImageIdType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Images_ImageId",
                table: "Reviews");

            migrationBuilder.DropUniqueConstraint(
                name: "AK_Images_TempId",
                table: "Images");

            migrationBuilder.DropColumn(
                name: "TempId",
                table: "Images");

            // Set ImageId to NULL to avoid casting issues
            migrationBuilder.Sql("UPDATE \"Reviews\" SET \"ImageId\" = NULL WHERE \"ImageId\" IS NOT NULL;");

            migrationBuilder.AlterColumn<int>(
                name: "ImageId",
                table: "Reviews",
                type: "integer",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Images_ImageId",
                table: "Reviews",
                column: "ImageId",
                principalTable: "Images",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Images_ImageId",
                table: "Reviews");

            migrationBuilder.AlterColumn<string>(
                name: "ImageId",
                table: "Reviews",
                type: "text",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TempId",
                table: "Images",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddUniqueConstraint(
                name: "AK_Images_TempId",
                table: "Images",
                column: "TempId");

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Images_ImageId",
                table: "Reviews",
                column: "ImageId",
                principalTable: "Images",
                principalColumn: "TempId");
        }
    }
}
