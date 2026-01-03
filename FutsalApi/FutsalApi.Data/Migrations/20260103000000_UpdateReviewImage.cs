using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FutsalApi.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateReviewImage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ImageUrl",
                table: "Reviews",
                newName: "ImageId");

            migrationBuilder.Sql("UPDATE \"Reviews\" SET \"ImageId\" = NULL;");

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

            migrationBuilder.RenameColumn(
                name: "ImageId",
                table: "Reviews",
                newName: "ImageUrl");
        }
    }
}