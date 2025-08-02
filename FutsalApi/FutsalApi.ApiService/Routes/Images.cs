using FutsalApi.ApiService.Services;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;
using System.Collections.Generic;
using FutsalApi.Data.DTO;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Routes
{
    public static class Images
    {
        public static void MapImageEndpoints(this IEndpointRouteBuilder app)
        {
            app.MapPost("/images/upload/single", async ([FromServices] ImageService imageService, IFormFile file) =>
            {
                if (file == null || file.Length == 0)
                {
                    return Results.BadRequest("No file uploaded.");
                }
                var uploadedImage = await imageService.UploadSingleFile(file);
                return Results.Ok(uploadedImage);
            }).DisableAntiforgery();

            app.MapPost("/images/upload/multiple", async ([FromServices] ImageService imageService, [FromForm] List<IFormFile> files) =>
            {
                if (files == null || files.Count == 0)
                {
                    return Results.BadRequest("No files uploaded.");
                }
                var uploadedImages = await imageService.UploadMultipleFiles(files);
                return Results.Ok(uploadedImages);
            }).DisableAntiforgery();

            app.MapDelete("/images/delete/single/{imageId:int}", async ([FromServices] ImageService imageService, int imageId) =>
            {
                var result = await imageService.DeleteSingleFile(imageId);
                if (result)
                {
                    return Results.NoContent();
                }
                return Results.NotFound();
            });

            app.MapDelete("/images/delete/multiple", async ([FromServices] ImageService imageService, [FromBody] List<int> imageIds) =>
            {
                if (imageIds == null || imageIds.Count == 0)
                {
                    return Results.BadRequest("No image IDs provided.");
                }
                var result = await imageService.DeleteMultipleFiles(imageIds);
                if (result)
                {
                    return Results.NoContent();
                }
                return Results.BadRequest("Some images could not be deleted.");
            });

            app.MapGet("/images/user", async ([FromServices] ImageService imageService) =>
            {
                var images = await imageService.GetImagesByUserId();
                return Results.Ok(images);
            });
        }
    }
}