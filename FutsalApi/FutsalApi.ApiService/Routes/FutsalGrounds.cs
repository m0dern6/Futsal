using System.Diagnostics;
using FutsalApi.ApiService.Repositories;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace FutsalApi.ApiService.Data;

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
        var routeGroup = endpoints.MapGroup("/FutsalGround").RequireAuthorization();

        var repository = endpoints.ServiceProvider.GetRequiredService<IGenericrepository<FutsalGround>>();
        var logger = endpoints.ServiceProvider.GetRequiredService<ILogger>();

        // GET: /FutsalGround (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<FutsalGround>>, ProblemHttpResult>>
            ([FromQuery] int page = 1, [FromQuery] int pageSize = 10) =>
        {
            if (page <= 0 || pageSize <= 0)
            {
                return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: 400);
            }

            try
            {
                var futsalGrounds = await repository.GetAllAsync(page, pageSize);
                return TypedResults.Ok(futsalGrounds);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving futsal grounds.");
                return TypedResults.Problem($"An error occurred while retrieving futsal grounds: {ex.Message}");
            }
        })
        .WithName("GetAllFutsalGround")
        .WithSummary("Retrieves all futsal grounds with pagination.")
        .WithDescription("Returns a paginated list of all futsal grounds available in the system.")
        .Produces<IEnumerable<FutsalGround>>(200)
        .ProducesProblem(400)
        .ProducesProblem(500);

        // GET: /FutsalGround/{id}
        routeGroup.MapGet("/{id:int}", async Task<Results<Ok<FutsalGround>, NotFound, ProblemHttpResult>>
            (int id) =>
        {
            try
            {
                var futsalGround = await repository.GetByIdAsync(id);
                if (futsalGround is null)
                {
                    logger.LogWarning("FutsalGround with ID {Id} not found.", id);
                    return TypedResults.NotFound();
                }

                return TypedResults.Ok(futsalGround);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving the futsal ground with ID {Id}.", id);
                return TypedResults.Problem($"An error occurred while retrieving the futsal ground: {ex.Message}");
            }
        })
        .WithName("GetFutsalGroundById")
        .WithSummary("Retrieves a futsal ground by ID.")
        .WithDescription("Returns the details of a specific futsal ground identified by its ID.")
        .Produces<FutsalGround>(200)
        .Produces(404)
        .ProducesProblem(500);

        // POST: /FutsalGround
        routeGroup.MapPost("/", async Task<Results<Ok<FutsalGround>, ProblemHttpResult>>
            ([FromBody] FutsalGround futsalGround) =>
        {
            try
            {
                var result = await repository.CreateAsync(futsalGround);
                if (result is null)
                {
                    logger.LogWarning("Failed to create FutsalGround.");
                    return TypedResults.Problem("Failed to create the futsal ground.");
                }
                logger.LogInformation("FutsalGround with ID {Id} created successfully.", result.Id);
                return TypedResults.Ok(result); // Changed to Ok for consistency
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while creating the futsal ground.");
                return TypedResults.Problem($"An error occurred while creating the futsal ground: {ex.Message}");
            }
        })
        .WithName("CreateFutsalGround")
        .WithSummary("Creates a new futsal ground.")
        .WithDescription("Adds a new futsal ground to the system.")
        .Produces<FutsalGround>(200)
        .ProducesProblem(500);

        // PUT: /FutsalGround/{id}
        routeGroup.MapPut("/{id:int}", async Task<Results<Ok<FutsalGround>, NotFound, ProblemHttpResult>>
            (int id, [FromBody] FutsalGround updatedGround) =>
        {
            try
            {
                var existingGround = await repository.GetByIdAsync(id);
                if (existingGround is null)
                {
                    logger.LogWarning("FutsalGround with ID {Id} not found for update.", id);
                    return TypedResults.NotFound();
                }

                var result = await repository.UpdateAsync(id, updatedGround);
                logger.LogInformation("FutsalGround with ID {Id} updated successfully.", id);
                return TypedResults.Ok(result);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while updating the futsal ground with ID {Id}.", id);
                return TypedResults.Problem($"An error occurred while updating the futsal ground: {ex.Message}");
            }
        })
        .WithName("UpdateFutsalGround")
        .WithSummary("Updates an existing futsal ground.")
        .WithDescription("Modifies the details of an existing futsal ground identified by its ID.")
        .Produces<FutsalGround>(200)
        .Produces(404)
        .ProducesProblem(500);

        // DELETE: /FutsalGround/{id}
        routeGroup.MapDelete("/{id:int}", async Task<Results<NoContent, NotFound, ProblemHttpResult>>
            (int id) =>
        {
            try
            {
                var futsalGround = await repository.GetByIdAsync(id);
                if (futsalGround is null)
                {
                    logger.LogWarning("FutsalGround with ID {Id} not found for deletion.", id);
                    return TypedResults.NotFound();
                }

                var success = await repository.DeleteAsync(id);
                if (success)
                {
                    logger.LogInformation("FutsalGround with ID {Id} deleted successfully.", id);
                    return TypedResults.NoContent();
                }

                logger.LogError("Failed to delete FutsalGround with ID {Id}.", id);
                return TypedResults.Problem("Failed to delete the futsal ground.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while deleting the futsal ground with ID {Id}.", id);
                return TypedResults.Problem($"An error occurred while deleting the futsal ground: {ex.Message}");
            }
        })
        .WithName("DeleteFutsalGround")
        .WithSummary("Deletes a futsal ground.")
        .WithDescription("Removes a futsal ground from the system identified by its ID.")
        .Produces(204)
        .Produces(404)
        .ProducesProblem(500);


        return routeGroup;
    }
}