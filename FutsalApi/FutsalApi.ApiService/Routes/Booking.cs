using System;
using System.Security.Claims;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Routes;

public static class BookingApiEndpointRouteBuilderExtensions
{
    public static IEndpointConventionBuilder MapBookingApi(this IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/Booking").RequireAuthorization();

        // GET: /Booking (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<Booking>>, ProblemHttpResult, NotFound>>
            ([FromServices] IBookingRepository repository,
             [FromServices] UserManager<User> userManager,
             ClaimsPrincipal claimsPrincipal,
             [FromQuery] int page = 1,
             [FromQuery] int pageSize = 10) =>
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
        })
        .WithName("GetBookingsByUserId")
        .WithSummary("Get Bookings of a user")
        .WithDescription("Get all the Bookings for a partucular user using userid")
        .Accepts<ClaimsPrincipal>("User")
        .Accepts<int>("page")
        .Accepts<int>("pageSize")
        .Produces<IEnumerable<Notification>>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        //Post: /Booking
        routeGroup.MapPost("/", async Task<Results<Ok<string>, ProblemHttpResult>>
            ([FromServices] IBookingRepository repository,
             [FromBody] Booking booking) =>
        {
            try
            {
                await repository.CreateAsync(booking);
                return TypedResults.Ok("Booking created successfully.");
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while creating the booking: {ex.Message}");
            }
        })
        .WithName("CreateBooking")
        .WithSummary("Create a new booking")
        .WithDescription("Create a new booking for a user")
        .Accepts<Booking>("application/json")
        .Produces<string>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // PUT: /Booking/{id}
        routeGroup.MapPut("/{id}", async Task<Results<Ok<string>, ProblemHttpResult, NotFound>>
            ([FromServices] IBookingRepository repository,
             [FromRoute] int id,
             [FromBody] Booking booking) =>
        {
            try
            {
                var existingBooking = await repository.GetByIdAsync(e => e.Id == id);
                if (existingBooking == null)
                {
                    return TypedResults.NotFound();
                }

                existingBooking.StartTime = booking.StartTime;
                existingBooking.EndTime = booking.EndTime;


                await repository.UpdateAsync(e => e.Id == id, existingBooking);
                return TypedResults.Ok("Booking updated successfully.");
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while updating the booking: {ex.Message}");
            }
        })
        .WithName("UpdateBooking")
        .WithSummary("Update an existing booking")
        .WithDescription("Update an existing booking for a user")
        .Accepts<Booking>("application/json")
        .Produces<string>(StatusCodes.Status200OK)
        .Produces<Booking>(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        //Patch: /Booking/cancel/{id}
        routeGroup.MapPatch("/cancel/{id}", async Task<Results<Ok<string>, ProblemHttpResult, NotFound>>
            ([FromServices] IBookingRepository repository,
            ClaimsPrincipal claimsPrincipal,
            [FromServices] UserManager<User> userManager,
             [FromRoute] int id) =>
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
        })
        .WithName("CancelBooking")
        .WithSummary("Cancel an existing booking")
        .WithDescription("Cancel an existing booking for a user")
        .Produces<string>(StatusCodes.Status200OK)
        .Produces<Booking>(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);




        return routeGroup;
    }


}
