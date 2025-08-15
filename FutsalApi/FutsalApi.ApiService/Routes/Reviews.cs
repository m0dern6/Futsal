﻿using System.Security.Claims;

using FutsalApi.ApiService.Infrastructure;
using FutsalApi.Data.Models;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Infrastructure;


using FutsalApi.Data.Models;
using FutsalApi.Data.DTO;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Data;

public class ReviewApiEndpoints : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/Reviews")
            .WithTags("Reviews")
            .CacheOutput()
            .RequireAuthorization();

        // GET: /Reviews (with pagination)
        routeGroup.MapGet("/", GetAllReviews)
            .WithName("GetAllReviews")
            .WithSummary("Retrieves all reviews with pagination.")
            .WithDescription("Returns a paginated list of all reviews available in the system.")
            .Produces<IEnumerable<ReviewResponse>>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // GET: /Reviews/Ground/{groundId}
        routeGroup.MapGet("/Ground/{groundId:int}", GetReviewsByGroundId)
            .WithName("GetReviewsByGroundId")
            .WithSummary("Retrieves reviews for a specific ground.")
            .WithDescription("Returns a paginated list of reviews for a specific ground identified by its ID.")
            .Produces<IEnumerable<ReviewResponse>>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // GET: /Reviews/{id}
        routeGroup.MapGet("/{id:int}", GetReviewById)
            .WithName("GetReviewById")
            .WithSummary("Retrieves a review by ID.")
            .WithDescription("Returns the details of a specific review identified by its ID.")
            .Produces<ReviewResponse>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // POST: /Reviews
        routeGroup.MapPost("/", CreateReview)
            .WithName("CreateReview")
            .WithSummary("Creates a new review.")
            .WithDescription("Adds a new review to the system.")
            .Accepts<ReviewRequest>("application/json")
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // PUT: /Reviews/{id}
        routeGroup.MapPut("/{id:int}", UpdateReview)
            .WithName("UpdateReview")
            .WithSummary("Updates an existing review.")
            .WithDescription("Modifies the details of an existing review identified by its ID.")
            .Accepts<ReviewRequest>("application/json")
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // DELETE: /Reviews/{id}
        routeGroup.MapDelete("/{id:int}", DeleteReview)
            .WithName("DeleteReview")
            .WithSummary("Deletes a review.")
            .WithDescription("Removes a review from the system identified by its ID. Users can only delete their own reviews.")
            .Produces(StatusCodes.Status204NoContent)
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status403Forbidden)
            .ProducesProblem(StatusCodes.Status500InternalServerError);
    }

    internal async Task<Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult>> GetAllReviews(
        [FromServices] IReviewRepository repository,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
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
    }

    internal async Task<Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult>> GetReviewsByGroundId(
        [FromServices] IReviewRepository repository,
        int groundId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
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
    }

    internal async Task<Results<Ok<ReviewResponse>, NotFound, ProblemHttpResult>> GetReviewById(
        [FromServices] IReviewRepository repository,
        int id)
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
    }

    internal async Task<Results<Ok<int>, ProblemHttpResult>> CreateReview(
        [FromServices] IReviewRepository repository,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        [FromBody] ReviewRequest reviewRequest)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("User not found.", statusCode: StatusCodes.Status404NotFound);
            }

            var existingReview = await repository.GetByIdAsync(e => e.GroundId == reviewRequest.GroundId && e.UserId == user.Id);
            if (existingReview is not null)
            {
                return TypedResults.Problem("You have already reviewed this ground.", statusCode: StatusCodes.Status400BadRequest);
            }

            Review review = new Review
            {
                UserId = user.Id,
                GroundId = reviewRequest.GroundId,
                Rating = reviewRequest.Rating,
                Comment = reviewRequest.Comment,
                ImageUrl = reviewRequest.ImageId.ToString()
            };

            var reviewId = await repository.CreateReviewAsync(review);

            if (reviewId == 0)
            {
                return TypedResults.Problem("Failed to create the review.", statusCode: StatusCodes.Status400BadRequest);
            }

            return TypedResults.Ok(reviewId);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while creating the review: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, NotFound, ProblemHttpResult>> UpdateReview(
        [FromServices] IReviewRepository repository,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        int id,
        [FromBody] ReviewRequest updatedReviewRequest)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("User not found.", statusCode: StatusCodes.Status404NotFound);
            }

            var existingReview = await repository.GetByIdAsync(e => e.Id == id && e.UserId == user.Id);
            if (existingReview is null)
            {
                return TypedResults.NotFound();
            }

            Review updatedReview = new Review
            {
                Id = id,
                UserId = user.Id,
                GroundId = updatedReviewRequest.GroundId,
                Rating = updatedReviewRequest.Rating,
                Comment = updatedReviewRequest.Comment,
                ImageUrl = updatedReviewRequest.ImageId.ToString()
            };

            await repository.UpdateReviewAsync(updatedReview);

            return TypedResults.Ok("Review updated successfully.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while updating the review: {ex.Message}");
        }
    }

    internal async Task<Results<NoContent, NotFound, ProblemHttpResult>> DeleteReview(
        [FromServices] IReviewRepository repository,
        [FromServices] IFutsalGroundRepository groundRepository,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        int id)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("User not found.", statusCode: StatusCodes.Status404NotFound);
            }

            var review = await repository.GetByIdAsync(e => e.Id == id && e.UserId == user.Id);
            if (review is null)
            {
                return TypedResults.NotFound();
            }
            var success = await repository.DeleteReviewByUserAsync(id, user.Id);
            if (success)
            {
                return TypedResults.NoContent();
            }
            await groundRepository.UpdateRatingAsync(review.GroundId);
            return TypedResults.Problem("Failed to delete the review.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while deleting the review: {ex.Message}");
        }
    }
}
