using System;
using System.Runtime.CompilerServices;
using System.Security.Claims;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Infrastructure;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

[assembly: InternalsVisibleTo("FutsalApi.Tests")]
namespace FutsalApi.ApiService.Routes;
public class BookingApiEndpoints : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/Booking")
            .WithTags("Booking")
            .RequireAuthorization();

        routeGroup.MapGet("/", GetBookingsByUserId)
            .WithName("GetBookingsByUserId")
            .WithSummary("Get Bookings of a user")
            .WithDescription("Get all the Bookings for a particular user using userid")
            .Produces<IEnumerable<BookingResponse>>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPost("/", CreateBooking)
            .WithName("CreateBooking")
            .WithSummary("Create a new booking")
            .WithDescription("Create a new booking for a user")
            .Accepts<BookingRequest>("application/json")
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPut("/{id}", UpdateBooking)
            .WithName("UpdateBooking")
            .WithSummary("Update an existing booking")
            .WithDescription("Update an existing booking for a user")
            .Accepts<BookingRequest>("application/json")
            .Produces<string>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPatch("/cancel/{id}", CancelBooking)
            .WithName("CancelBooking")
            .WithSummary("Cancel an existing booking")
            .WithDescription("Cancel an existing booking for a user")
            .Produces<string>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);
    }

    internal async Task<Results<Ok<IEnumerable<BookingResponse>>, ProblemHttpResult, NotFound>> GetBookingsByUserId(
        [FromServices] IBookingRepository repository,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: StatusCodes.Status400BadRequest);
        }

        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.NotFound();
            }
            var bookings = await repository.GetBookingsByUserIdAsync(user.Id, page, pageSize);
            return TypedResults.Ok(bookings);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while retrieving Bookings: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult>> CreateBooking(
        [FromServices] IBookingRepository repository,
        [FromServices] IFutsalGroundRepository groundRepository,
        [FromBody] BookingRequest bookingRequest)
    {
        try
        {
            var ground = await groundRepository.GetByIdAsync(e => e.Id == bookingRequest.GroundId);
            if (ground == null)
            {
                return TypedResults.Problem("Ground not found.", statusCode: StatusCodes.Status404NotFound);
            }
            Booking booking = new Booking
            {
                UserId = bookingRequest.UserId,
                GroundId = bookingRequest.GroundId,
                BookingDate = bookingRequest.BookingDate,
                StartTime = bookingRequest.StartTime,
                EndTime = bookingRequest.EndTime,
                TotalAmount = ground.PricePerHour * (decimal)(bookingRequest.EndTime - bookingRequest.StartTime).TotalHours
            };
            await repository.CreateAsync(booking);
            return TypedResults.Ok("Booking created successfully.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while creating the booking: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult, NotFound>> UpdateBooking(
        [FromServices] IBookingRepository repository,
        [FromRoute] int id,
        [FromBody] BookingRequest bookingRequest)
    {
        try
        {
            var existingBooking = await repository.GetByIdAsync(e => e.Id == id);
            if (existingBooking == null)
            {
                return TypedResults.NotFound();
            }

            existingBooking.StartTime = bookingRequest.StartTime;
            existingBooking.EndTime = bookingRequest.EndTime;

            await repository.UpdateAsync(e => e.Id == id, existingBooking);
            return TypedResults.Ok("Booking updated successfully.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while updating the booking: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult, NotFound>> CancelBooking(
        [FromServices] IBookingRepository repository,
        ClaimsPrincipal claimsPrincipal,
        [FromServices] UserManager<User> userManager,
        [FromRoute] int id)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.NotFound();
            }
            var existingBooking = await repository.GetByIdAsync(e => e.Id == id && e.UserId == user.Id);
            if (existingBooking == null)
            {
                return TypedResults.NotFound();
            }

            existingBooking.Status = BookingStatus.Cancelled;
            var result = await repository.UpdateAsync(e => e.Id == id, existingBooking);
            if (result == null)
            {
                return TypedResults.Problem("Failed to cancel the booking.", statusCode: StatusCodes.Status400BadRequest);
            }
            return TypedResults.Ok("Booking cancelled successfully.");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while updating the booking: {ex.Message}");
        }
    }
}
