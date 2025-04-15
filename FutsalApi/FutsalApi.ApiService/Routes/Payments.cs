using System;
using System.Security.Claims;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Infrastructure;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Services;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Routes;

public class PaymentApiEndpoints : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/Payment")
            .WithTags("Payment")
            .RequireAuthorization();

        //Get: /Payment (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<Payment>>, ProblemHttpResult, NotFound>>
            ([FromServices] IPaymentRepository repository,
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
                var payments = await repository.GetPaymentsByUserIdAsync(user.Id, page, pageSize);
                return TypedResults.Ok(payments);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving Payments: {ex.Message}");
            }
        })
        .WithName("GetPaymentsByUserId")
        .WithSummary("Get Payments of a user")
        .WithDescription("Get all the Payments for a partucular user using userid")
        .Produces<IEnumerable<Payment>>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        //Get: /Payment/{bookingId}
        routeGroup.MapGet("/{bookingId:int}", async Task<Results<Ok<Payment>, ProblemHttpResult, NotFound>>
            ([FromServices] IPaymentRepository repository,
             [FromRoute] int bookingId) =>
        {
            try
            {
                var payment = await repository.GetPaymentByBookingIdAsync(bookingId);
                if (payment == null)
                {
                    return TypedResults.NotFound();
                }
                return TypedResults.Ok(payment);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving Payment: {ex.Message}");
            }
        })
        .WithName("GetPaymentByBookingId")
        .WithSummary("Get Payment by bookingId")
        .WithDescription("Get Payment by bookingId")
        .Produces<Payment>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        //Post: /Payment
        routeGroup.MapPost("/", async Task<Results<Ok<string>, ProblemHttpResult>>
            ([FromServices] IPaymentRepository repository,
            [FromServices] IPaymentService paymentService,
             [FromBody] Payment payment) =>
        {
            try
            {
                if (payment.Method == PaymentMethod.Online)
                {
                    var paymentResult = await paymentService.OnlinePaymentAsync(payment);
                    if (paymentResult is null)
                    {
                        return TypedResults.Problem("Payment failed.", statusCode: StatusCodes.Status400BadRequest);
                    }
                    return TypedResults.Ok("Payment created successfully.");
                }
                else
                {
                    await repository.CreateAsync(payment);
                    return TypedResults.Ok("Payment created successfully.");
                }
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while creating the payment: {ex.Message}");
            }
        })
        .WithName("CreatePayment")
        .WithSummary("Create a new payment")
        .WithDescription("Create a new payment for a user")
        .Accepts<Payment>("application/json")
        .Produces<string>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

    }

}
