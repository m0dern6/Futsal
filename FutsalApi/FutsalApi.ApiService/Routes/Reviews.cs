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

        // GET: /Reviews (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<Review>>, ProblemHttpResult>>
            ([FromServices] IReviewRepository repository,
            [FromQuery] int page = 1,
             [FromQuery] int pageSize = 10) =>
        {
            if (page <= 0 || pageSize <= 0)
            {
                return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: StatusCodes.Status400BadRequest);
            }

            try
            {
                var reviews = await repository.GetAllAsync(page, pageSize);
                return TypedResults.Ok(reviews);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving reviews: {ex.Message}");
            }
        })
        .WithName("GetAllReviews")
        .WithSummary("Retrieves all reviews with pagination.")
        .WithDescription("Returns a paginated list of all reviews available in the system.")
        .Produces<IEnumerable<Review>>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // GET: /Reviews/Ground/{groundId}
        routeGroup.MapGet("/Ground/{groundId:int}", async Task<Results<Ok<IEnumerable<Review>>, ProblemHttpResult>>
            ([FromServices] IReviewRepository repository,
            int groundId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10) =>
        {
            if (page <= 0 || pageSize <= 0)
            {
                return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: StatusCodes.Status400BadRequest);
            }

            try
            {
                var reviews = await repository.GetReviewsByGroundIdAsync(groundId, page, pageSize);
                return TypedResults.Ok(reviews);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving reviews: {ex.Message}");
            }
        })
        .WithName("GetReviewsByGroundId")
        .WithSummary("Retrieves reviews for a specific ground.")
        .WithDescription("Returns a paginated list of reviews for a specific ground identified by its ID.")
        .Produces<IEnumerable<Review>>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);


        // GET: /Reviews/{id}
        routeGroup.MapGet("/{id:int}", async Task<Results<Ok<Review>, NotFound, ProblemHttpResult>>
            ([FromServices] IReviewRepository repository,
            int id) =>
        {
            try
            {
                var review = await repository.GetByIdAsync(e => e.Id == id);
                if (review is null)
                {
                    return TypedResults.NotFound();
                }

                return TypedResults.Ok(review);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving the review: {ex.Message}");
            }
        })
        .WithName("GetReviewById")
        .WithSummary("Retrieves a review by ID.")
        .WithDescription("Returns the details of a specific review identified by its ID.")
        .Produces<Review>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // POST: /Reviews
        routeGroup.MapPost("/", async Task<Results<Ok<Review>, ProblemHttpResult>>
            ([FromServices] IReviewRepository repository,
            [FromBody] Review review) =>
        {
            try
            {
                var result = await repository.CreateAsync(review);
                if (result is null)
                {
                    return TypedResults.Problem("Failed to create the review.", statusCode: StatusCodes.Status400BadRequest);
                }
                return TypedResults.Ok(result);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while creating the review: {ex.Message}");
            }
        })
        .WithName("CreateReview")
        .WithSummary("Creates a new review.")
        .WithDescription("Adds a new review to the system.")
        .Accepts<Review>("application/json")
        .Produces<Review>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // PUT: /Reviews/{id}
        routeGroup.MapPut("/{id:int}", async Task<Results<Ok<Review>, NotFound, ProblemHttpResult>>
            ([FromServices] IReviewRepository repository,
            int id,
            [FromBody] Review updatedReview) =>
        {
            try
            {
                var existingReview = await repository.GetByIdAsync(e => e.Id == id);
                if (existingReview is null)
                {
                    return TypedResults.NotFound();
                }

                var result = await repository.UpdateAsync(e => e.Id == id, updatedReview);
                return TypedResults.Ok(result);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while updating the review: {ex.Message}");
            }
        })
        .WithName("UpdateReview")
        .WithSummary("Updates an existing review.")
        .WithDescription("Modifies the details of an existing review identified by its ID.")
        .Accepts<Review>("application/json")
        .Produces<Review>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // DELETE: /Reviews/{id}
        routeGroup.MapDelete("/{id:int}", async Task<Results<NoContent, NotFound, ProblemHttpResult>>
         ([FromServices] IReviewRepository repository,
         int id,
         HttpContext httpContext) =>
        {
            try
            {
                // Extract UserId from the token (claims)
                var userIdClaim = httpContext.User.Claims.FirstOrDefault(c => c.Type == "sub");
                if (userIdClaim == null || string.IsNullOrWhiteSpace(userIdClaim.Value))
                {
                    return TypedResults.Problem("User ID not found in token.", statusCode: StatusCodes.Status401Unauthorized);
                }

                var userId = userIdClaim.Value;

                var review = await repository.GetByIdAsync(e => e.Id == id);
                if (review is null)
                {
                    return TypedResults.NotFound();
                }

                if (review.UserId != userId)
                {
                    return TypedResults.Problem("You can only delete your own reviews.", statusCode: StatusCodes.Status403Forbidden);
                }

                var success = await repository.DeleteReviewByUserAsync(id, userId);
                if (success)
                {
                    return TypedResults.NoContent();
                }

                return TypedResults.Problem("Failed to delete the review.");
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while deleting the review: {ex.Message}");
            }
        })
        .WithName("DeleteReview")
        .WithSummary("Deletes a review.")
        .WithDescription("Removes a review from the system identified by its ID. Users can only delete their own reviews.")
        .Produces(StatusCodes.Status204NoContent)
        .ProducesProblem(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status403Forbidden)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        return routeGroup;
    }
}