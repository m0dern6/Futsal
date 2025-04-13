using System.Diagnostics;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace FutsalApi.ApiService.Routes;

/// <summary>
/// Provides API endpoints for managing FutsalGround entities.
/// Includes CRUD operations: GetAll, GetById, Create, Update, and Delete.
/// </summary>
public static class FutsalGroundApiEndpointRouteBuilderExtensions
{
    /// <summary>
    /// Maps API endpoints for FutsalGround management.
    /// </summary>
    /// <param name="endpoints">The <see cref="IEndpointRouteBuilder"/> to add the endpoints to.</param>
    /// <returns>An <see cref="IEndpointConventionBuilder"/> to further customize the added endpoints.</returns>
    public static IEndpointConventionBuilder MapFutsalGroundApi(this IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/FutsalGround");

        // GET: /FutsalGround (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<FutsalGround>>, ProblemHttpResult>>
            ([FromServices] FutsalGroundRepository repository,
             [FromQuery] int page = 1,
             [FromQuery] int pageSize = 10) =>
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
        })
        .WithName("GetAllFutsalGround")
        .WithSummary("Retrieves all futsal grounds with pagination.")
        .WithDescription("Returns a paginated list of all futsal grounds available in the system.")
        .Produces<IEnumerable<FutsalGround>>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // GET: /FutsalGround/{id}
        routeGroup.MapGet("/{id:int}", async Task<Results<Ok<FutsalGround>, NotFound, ProblemHttpResult>>
            ([FromServices] FutsalGroundRepository repository,
            int id) =>
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
        })
        .WithName("GetFutsalGroundById")
        .WithSummary("Retrieves a futsal ground by ID.")
        .WithDescription("Returns the details of a specific futsal ground identified by its ID.")
        .Produces<FutsalGround>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // POST: /FutsalGround
        routeGroup.MapPost("/", async Task<Results<Ok<FutsalGround>, ProblemHttpResult>>
            ([FromServices] FutsalGroundRepository repository,
            [FromBody] FutsalGround futsalGround) =>
        {
            try
            {
                var result = await repository.CreateAsync(futsalGround);
                if (result is null)
                {
                    return TypedResults.Problem("Failed to create the futsal ground.", statusCode: StatusCodes.Status400BadRequest);
                }
                return TypedResults.Ok(result); // Changed to Ok for consistency
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while creating the futsal ground: {ex.Message}");
            }
        })
        .WithName("CreateFutsalGround")
        .WithSummary("Creates a new futsal ground.")
        .WithDescription("Adds a new futsal ground to the system.")
        .Accepts<FutsalGround>("application/json")
        .Produces<FutsalGround>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // PUT: /FutsalGround/{id}
        routeGroup.MapPut("/{id:int}", async Task<Results<Ok<FutsalGround>, NotFound, ProblemHttpResult>>
            ([FromServices] FutsalGroundRepository repository,
            int id,
            [FromBody] FutsalGround updatedGround) =>
        {
            try
            {
                var existingGround = await repository.GetByIdAsync(e => e.Id == id);
                if (existingGround is null)
                {
                    return TypedResults.NotFound();
                }

                var result = await repository.UpdateAsync(e => e.Id == id, updatedGround);
                return TypedResults.Ok(result);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while updating the futsal ground: {ex.Message}");
            }
        })
        .WithName("UpdateFutsalGround")
        .WithSummary("Updates an existing futsal ground.")
        .WithDescription("Modifies the details of an existing futsal ground identified by its ID.")
        .Produces<FutsalGround>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // DELETE: /FutsalGround/{id}
        routeGroup.MapDelete("/{id:int}", async Task<Results<NoContent, NotFound, ProblemHttpResult>>
            ([FromServices] FutsalGroundRepository repository,
            int id) =>
        {
            try
            {
                var futsalGround = await repository.GetByIdAsync(e => e.Id == id);
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
        })
        .WithName("DeleteFutsalGround")
        .WithSummary("Deletes a futsal ground.")
        .WithDescription("Removes a futsal ground from the system identified by its ID.")
        .Produces(StatusCodes.Status204NoContent)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);


        return routeGroup;
    }
}