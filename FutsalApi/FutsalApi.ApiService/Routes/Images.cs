using FutsalApi.ApiService.Services;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;
using System.Collections.Generic;
using FutsalApi.Data.DTO;
using Microsoft.AspNetCore.Mvc;
using FutsalApi.ApiService.Infrastructure;
using System.Security.Claims;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using FutsalApi.Data.Models;

namespace FutsalApi.ApiService.Routes
{
    public class ImageEndpoints : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder endpoints)
        {
            var group = endpoints.MapGroup("/images").WithTags("Images");

            group.MapPost("/upload/single", UploadSingleFile)
                .WithName("UploadSingleFile")
                .WithSummary("Uploads a single image file.")
                .WithDescription("Uploads a single image file to the server and returns the image details.")
                .DisableAntiforgery()
                .Produces<Ok<Image>>(StatusCodes.Status200OK)
                .Produces<BadRequest>(StatusCodes.Status400BadRequest)
                .Produces<UnauthorizedHttpResult>(StatusCodes.Status401Unauthorized)
                .ProducesProblem(StatusCodes.Status500InternalServerError);

            group.MapPost("/upload/multiple", UploadMultipleFiles)
                .WithName("UploadMultipleFiles")
                .WithSummary("Uploads multiple image files.")
                .WithDescription("Uploads multiple image files to the server and returns the list of uploaded images.")
                .DisableAntiforgery()
                .Produces<Ok<List<Image>>>(StatusCodes.Status200OK)
                .Produces<BadRequest>(StatusCodes.Status400BadRequest)
                .Produces<UnauthorizedHttpResult>(StatusCodes.Status401Unauthorized)
                .ProducesProblem(StatusCodes.Status500InternalServerError);

            group.MapDelete("/delete/single/{imageId:int}", DeleteSingleFile)
                .WithName("DeleteSingleFile")
                .WithSummary("Deletes a single image.")
                .WithDescription("Deletes a single image by its ID.")
                .Produces<NoContent>(StatusCodes.Status204NoContent)
                .Produces<NotFound>(StatusCodes.Status404NotFound)
                .Produces<UnauthorizedHttpResult>(StatusCodes.Status401Unauthorized)
                .ProducesProblem(StatusCodes.Status500InternalServerError);

            group.MapDelete("/delete/multiple", DeleteMultipleFiles)
                .WithName("DeleteMultipleFiles")
                .WithSummary("Deletes multiple images.")
                .WithDescription("Deletes multiple images by their IDs.")
                .Produces<NoContent>(StatusCodes.Status204NoContent)
                .Produces<BadRequest>(StatusCodes.Status400BadRequest)
                .Produces<UnauthorizedHttpResult>(StatusCodes.Status401Unauthorized)
                .ProducesProblem(StatusCodes.Status500InternalServerError);

            group.MapGet("/user", GetImagesByUserId)
                .WithName("GetImagesByUserId")
                .WithSummary("Gets images for the current user.")
                .WithDescription("Retrieves all images uploaded by the current user.")
                .Produces<Ok<List<Image>>>(StatusCodes.Status200OK)
                .Produces<UnauthorizedHttpResult>(StatusCodes.Status401Unauthorized)
                .ProducesProblem(StatusCodes.Status500InternalServerError);
        }

        internal async Task<Results<Ok<Image>, BadRequest, UnauthorizedHttpResult>> UploadSingleFile(
            ClaimsPrincipal claimsPrincipal, [FromServices] ImageService imageService, [FromServices] UserManager<User> userManager, IFormFile file)
        {

            if (file == null || file.Length == 0)
            {
                return TypedResults.BadRequest();
            }
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Unauthorized();
            }
            var uploadedImage = await imageService.UploadSingleFile(user, file);
            return TypedResults.Ok(uploadedImage);
        }

        internal async Task<Results<Ok<List<Image>>, BadRequest, UnauthorizedHttpResult>> UploadMultipleFiles(
            ClaimsPrincipal claimsPrincipal, [FromServices] ImageService imageService, [FromServices] UserManager<User> userManager, [FromForm] List<IFormFile> files)
        {
            if (files == null || files.Count == 0)
            {
                return TypedResults.BadRequest();
            }
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Unauthorized();
            }
            var uploadedImages = await imageService.UploadMultipleFiles(user, files);
            return TypedResults.Ok(uploadedImages);
        }

        internal async Task<Results<NoContent, NotFound, UnauthorizedHttpResult>> DeleteSingleFile(
            ClaimsPrincipal claimsPrincipal, [FromServices] ImageService imageService, [FromServices] UserManager<User> userManager, int imageId)
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Unauthorized();
            }
            var result = await imageService.DeleteSingleFile(user, imageId);
            if (result)
            {
                return TypedResults.NoContent();
            }
            return TypedResults.NotFound();
        }

        internal async Task<Results<NoContent, BadRequest, UnauthorizedHttpResult>> DeleteMultipleFiles(
            ClaimsPrincipal claimsPrincipal, [FromServices] ImageService imageService, [FromServices] UserManager<User> userManager, [FromBody] List<int> imageIds)
        {
            if (imageIds == null || imageIds.Count == 0)
            {
                return TypedResults.BadRequest();
            }
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Unauthorized();
            }
            var result = await imageService.DeleteMultipleFiles(user, imageIds);
            if (result)
            {
                return TypedResults.NoContent();
            }
            return TypedResults.BadRequest();
        }

        internal async Task<Results<Ok<List<Image>>, UnauthorizedHttpResult>> GetImagesByUserId(
            ClaimsPrincipal claimsPrincipal, [FromServices] ImageService imageService, [FromServices] UserManager<User> userManager)
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Unauthorized();
            }
            var images = await imageService.GetImagesByUserId(user);
            return TypedResults.Ok(images);
        }
    }
}