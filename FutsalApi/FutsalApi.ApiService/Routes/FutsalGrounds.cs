using System.Security.Claims;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Infrastructure;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Routes;

public class FutsalGroundApiEndpoints : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/FutsalGround")
            .WithTags("FutsalGround")
            .RequireAuthorization();

        routeGroup.MapGet("/", GetAllFutsalGrounds)
            .WithName("GetAllFutsalGround")
            .WithSummary("Retrieves all futsal grounds with pagination.")
            .WithDescription("Returns a paginated list of all futsal grounds available in the system.")
            .Produces<IEnumerable<FutsalGroundResponse>>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapGet("/search", SearchFutsalGrounds)
       .WithName("SearchFutsalGrounds")
       .WithSummary("Search futsal grounds by name and filters.")
       .WithDescription("Searches futsal grounds by name, location, and average rating with pagination.")
       .Produces<IEnumerable<FutsalGroundResponse>>(StatusCodes.Status200OK)
       .ProducesProblem(StatusCodes.Status400BadRequest)
       .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapGet("/{id:int}", GetFutsalGroundById)
            .WithName("GetFutsalGroundById")
            .WithSummary("Retrieves a futsal ground by ID.")
            .WithDescription("Returns the details of a specific futsal ground identified by its ID.")
            .Produces<FutsalGroundResponse>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPost("/", CreateFutsalGround)
            .WithName("CreateFutsalGround")
            .WithSummary("Creates a new futsal ground.")
            .WithDescription("Adds a new futsal ground to the system.")
            .Accepts<FutsalGroundRequest>("application/json")
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPut("/{id:int}", UpdateFutsalGround)
            .WithName("UpdateFutsalGround")
            .WithSummary("Updates an existing futsal ground.")
            .WithDescription("Modifies the details of an existing futsal ground identified by its ID.")
            .Produces<string>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapDelete("/{id:int}", DeleteFutsalGround)
            .WithName("DeleteFutsalGround")
            .WithSummary("Deletes a futsal ground.")
            .WithDescription("Removes a futsal ground from the system identified by its ID.")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status500InternalServerError);
    }

    internal async Task<Results<Ok<IEnumerable<FutsalGroundResponse>>, ProblemHttpResult>> GetAllFutsalGrounds(
        [FromServices] IFutsalGroundRepository repository,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: StatusCodes.Status400BadRequest);
        }

        try
        {
            var futsalGrounds = await repository.GetAllAsync(page, pageSize);
            return TypedResults.Ok(futsalGrounds);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while retrieving futsal grounds: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<FutsalGroundResponse>, NotFound, ProblemHttpResult>> GetFutsalGroundById(
        [FromServices] IFutsalGroundRepository repository,
        int id)
    {
        try
        {
            var futsalGround = await repository.GetByIdAsync(e => e.Id == id);
            if (futsalGround is null)
            {
                return TypedResults.NotFound();
            }

            return TypedResults.Ok(futsalGround);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while retrieving the futsal ground: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<List<FutsalGroundResponse>>, ProblemHttpResult>> SearchFutsalGrounds(
    [FromServices] IFutsalGroundRepository repository,
    [FromQuery] string? name,
    [FromQuery] string? location,
    [FromQuery] double? minRating,
    [FromQuery] double? maxRating,
    [FromQuery] int page = 1,
    [FromQuery] int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: StatusCodes.Status400BadRequest);
        }

        try
        {
            var query = repository.Query();

            if (!string.IsNullOrWhiteSpace(name))
                query = query.Where(f => f.Name.Contains(name));

            if (!string.IsNullOrWhiteSpace(location))
                query = query.Where(f => f.Location.Contains(location));

            if (minRating.HasValue)
                query = query.Where(f => f.AverageRating >= minRating.Value);

            if (maxRating.HasValue)
                query = query.Where(f => f.AverageRating <= maxRating.Value);

            var futsalGrounds = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(f => new FutsalGroundResponse
                {
                    Id = f.Id,
                    Name = f.Name,
                    Location = f.Location,
                    PricePerHour = f.PricePerHour,
                    OpenTime = f.OpenTime,
                    CloseTime = f.CloseTime,
                    AverageRating = f.AverageRating,
                })
                .ToListAsync();

            return TypedResults.Ok(futsalGrounds);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while searching futsal grounds: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult>> CreateFutsalGround(
        [FromServices] IFutsalGroundRepository repository,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        [FromBody] FutsalGroundRequest futsalGroundRequest)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("User not found.", statusCode: StatusCodes.Status404NotFound);
            }
            FutsalGround futsalGround = new FutsalGround
            {
                Name = futsalGroundRequest.Name,
                OwnerId = user.Id,
                Location = futsalGroundRequest.Location,
                PricePerHour = futsalGroundRequest.PricePerHour,
                OpenTime = futsalGroundRequest.OpenTime,
                CloseTime = futsalGroundRequest.CloseTime,
                Latitude = futsalGroundRequest.Latitude,
                Longitude = futsalGroundRequest.Longitude,
                Description = futsalGroundRequest.Description,
                ImageUrl = futsalGroundRequest.ImageUrl
            };
            var result = await repository.CreateAsync(futsalGround);
            if (result is null)
            {
                return TypedResults.Problem("Failed to create the futsal ground.", statusCode: StatusCodes.Status400BadRequest);
            }
            return TypedResults.Ok("Futsal ground created successfully.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while creating the futsal ground: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, NotFound, ProblemHttpResult>> UpdateFutsalGround(
        [FromServices] IFutsalGroundRepository repository,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        int id,
        [FromBody] FutsalGroundRequest updatedGroundRequest)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("You are not authorized to update this futsalground", statusCode: StatusCodes.Status404NotFound);
            }
            var existingGround = await repository.GetByIdAsync(e => e.Id == id && e.OwnerId == user.Id);
            if (existingGround is null)
            {
                return TypedResults.NotFound();
            }
            FutsalGround updatedGround = new FutsalGround
            {
                OwnerId = user.Id,
                Name = updatedGroundRequest.Name,
                Location = updatedGroundRequest.Location,
                PricePerHour = updatedGroundRequest.PricePerHour,
                OpenTime = updatedGroundRequest.OpenTime,
                CloseTime = updatedGroundRequest.CloseTime,
                Latitude = updatedGroundRequest.Latitude,
                Longitude = updatedGroundRequest.Longitude,
                Description = updatedGroundRequest.Description,
                ImageUrl = updatedGroundRequest.ImageUrl,
            };


            var result = await repository.UpdateAsync(e => e.Id == id, updatedGround);
            return TypedResults.Ok("Futsal ground updated successfully.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while updating the futsal ground: {ex.Message}");
        }
    }

    internal async Task<Results<NoContent, NotFound, ProblemHttpResult>> DeleteFutsalGround(
        [FromServices] IFutsalGroundRepository repository,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        int id)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("You are not authorized to delete this futsal ground.", statusCode: StatusCodes.Status404NotFound);
            }
            var futsalGround = await repository.GetByIdAsync(e => e.Id == id && e.OwnerId == user.Id);

            if (futsalGround is null)
            {
                return TypedResults.NotFound();
            }

            var success = await repository.DeleteAsync(e => e.Id == id);
            if (success)
            {
                return TypedResults.NoContent();
            }

            return TypedResults.Problem("Failed to delete the futsal ground.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while deleting the futsal ground: {ex.Message}");
        }
    }
}
