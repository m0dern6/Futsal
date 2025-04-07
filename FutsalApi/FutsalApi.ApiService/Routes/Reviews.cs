using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Data;

/// <summary>
/// Provides API endpoints for managing Review entities.
/// Includes CRUD operations: GetAll, GetById, Create, Update, and Delete.
/// </summary>
public static class ReviewApiEndpointRouteBuilderExtensions
{
    /// <summary>
    /// Maps API endpoints for Review management.
    /// </summary>
    /// <param name="endpoints">The <see cref="IEndpointRouteBuilder"/> to add the endpoints to.</param>
    /// <returns>An <see cref="IEndpointConventionBuilder"/> to further customize the added endpoints.</returns>
    public static IEndpointConventionBuilder MapReviewApi(this IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/Reviews").RequireAuthorization();

        var repository = endpoints.ServiceProvider.GetRequiredService<IReviewRepository>();
        var logger = endpoints.ServiceProvider.GetRequiredService<ILogger>();

        // GET: /Reviews (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<Review>>, ProblemHttpResult>>
            ([FromQuery] int page = 1, [FromQuery] int pageSize = 10) =>
        {
            if (page <= 0 || pageSize <= 0)
            {
                return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: 400);
            }

            try
            {
                var reviews = await repository.GetAllAsync(page, pageSize);
                return TypedResults.Ok(reviews);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving reviews.");
                return TypedResults.Problem($"An error occurred while retrieving reviews: {ex.Message}");
            }
        })
        .WithName("GetAllReviews")
        .WithSummary("Retrieves all reviews with pagination.")
        .WithDescription("Returns a paginated list of all reviews available in the system.")
        .Produces<IEnumerable<Review>>(200)
        .ProducesProblem(400)
        .ProducesProblem(500);

        // GET: /Reviews/Ground/{groundId}
        routeGroup.MapGet("/Ground/{groundId:int}", async Task<Results<Ok<IEnumerable<Review>>, ProblemHttpResult>>
            (int groundId, [FromQuery] int page = 1, [FromQuery] int pageSize = 10) =>
        {
            if (page <= 0 || pageSize <= 0)
            {
                return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: 400);
            }

            try
            {
                var reviews = await repository.GetReviewsByGroundIdAsync(groundId, page, pageSize);
                return TypedResults.Ok(reviews);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving reviews for ground ID {GroundId}.", groundId);
                return TypedResults.Problem($"An error occurred while retrieving reviews: {ex.Message}");
            }
        })
        .WithName("GetReviewsByGroundId")
        .WithSummary("Retrieves reviews for a specific ground.")
        .WithDescription("Returns a paginated list of reviews for a specific ground identified by its ID.")
        .Produces<IEnumerable<Review>>(200)
        .ProducesProblem(400)
        .ProducesProblem(500);

        // GET: /Reviews/{id}
        routeGroup.MapGet("/{id:int}", async Task<Results<Ok<Review>, NotFound, ProblemHttpResult>>
            (int id) =>
        {
            try
            {
                var review = await repository.GetByIdAsync(e => e.Id == id);
                if (review is null)
                {
                    logger.LogWarning("Review with ID {Id} not found.", id);
                    return TypedResults.NotFound();
                }

                return TypedResults.Ok(review);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving the review with ID {Id}.", id);
                return TypedResults.Problem($"An error occurred while retrieving the review: {ex.Message}");
            }
        })
        .WithName("GetReviewById")
        .WithSummary("Retrieves a review by ID.")
        .WithDescription("Returns the details of a specific review identified by its ID.")
        .Produces<Review>(200)
        .Produces(404)
        .ProducesProblem(500);

        // POST: /Reviews
        routeGroup.MapPost("/", async Task<Results<Ok<Review>, ProblemHttpResult>>
            ([FromBody] Review review) =>
        {
            try
            {
                var result = await repository.CreateAsync(review);
                if (result is null)
                {
                    logger.LogWarning("Failed to create Review.");
                    return TypedResults.Problem("Failed to create the review.");
                }
                logger.LogInformation("Review with ID {Id} created successfully.", result.Id);
                return TypedResults.Ok(result);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while creating the review.");
                return TypedResults.Problem($"An error occurred while creating the review: {ex.Message}");
            }
        })
        .WithName("CreateReview")
        .WithSummary("Creates a new review.")
        .WithDescription("Adds a new review to the system.")
        .Produces<Review>(200)
        .ProducesProblem(500);

        // PUT: /Reviews/{id}
        routeGroup.MapPut("/{id:int}", async Task<Results<Ok<Review>, NotFound, ProblemHttpResult>>
            (int id, [FromBody] Review updatedReview) =>
        {
            try
            {
                var existingReview = await repository.GetByIdAsync(e => e.Id == id);
                if (existingReview is null)
                {
                    logger.LogWarning("Review with ID {Id} not found for update.", id);
                    return TypedResults.NotFound();
                }

                var result = await repository.UpdateAsync(e => e.Id == id, updatedReview);
                logger.LogInformation("Review with ID {Id} updated successfully.", id);
                return TypedResults.Ok(result);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while updating the review with ID {Id}.", id);
                return TypedResults.Problem($"An error occurred while updating the review: {ex.Message}");
            }
        })
        .WithName("UpdateReview")
        .WithSummary("Updates an existing review.")
        .WithDescription("Modifies the details of an existing review identified by its ID.")
        .Produces<Review>(200)
        .Produces(404)
        .ProducesProblem(500);

        // DELETE: /Reviews/{id}
        routeGroup.MapDelete("/{id:int}", async Task<Results<NoContent, NotFound, ProblemHttpResult>>
         (int id, HttpContext httpContext) =>
        {
            try
            {
                // Extract UserId from the token (claims)
                var userIdClaim = httpContext.User.Claims.FirstOrDefault(c => c.Type == "sub");
                if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
                {
                    return TypedResults.Problem("User ID not found in token.", statusCode: 401);
                }

                // var review = await repository.GetByIdAsync(id);
                // if (review is null)
                // {
                //     logger.LogWarning("Review with ID {Id} not found for deletion.", id);
                //     return TypedResults.NotFound();
                // }

                // if (review.UserId != userId)
                // {
                //     logger.LogWarning("User {UserId} attempted to delete a review they do not own.", userId);
                //     return TypedResults.Problem("You can only delete your own reviews.", statusCode: 403);
                // }

                var success = await repository.DeleteReviewByUserAsync(id, userId);
                if (success)
                {
                    logger.LogInformation("Review with ID {Id} deleted successfully.", id);
                    return TypedResults.NoContent();
                }

                logger.LogError("Failed to delete Review with ID {Id}.", id);
                return TypedResults.Problem("Failed to delete the review.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while deleting the review with ID {Id}.", id);
                return TypedResults.Problem($"An error occurred while deleting the review: {ex.Message}");
            }
        })
        .WithName("DeleteReview")
        .WithSummary("Deletes a review.")
        .WithDescription("Removes a review from the system identified by its ID. Users can only delete their own reviews.")
        .Produces(204)
        .Produces(404)
        .ProducesProblem(403)
        .ProducesProblem(401)
        .ProducesProblem(500);

        return routeGroup;
    }
}