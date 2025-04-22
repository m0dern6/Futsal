using System;
using System.Security.Claims;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Infrastructure;
using FutsalApi.ApiService.Models;
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

        // GET: /Payment (with pagination)
        routeGroup.MapGet("/", GetPaymentsByUserId)
            .WithName("GetPaymentsByUserId")
            .WithSummary("Get Payments of a user")
            .WithDescription("Get all the Payments for a partucular user using userid")
            .Produces<IEnumerable<PaymentResponse>>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // GET: /Payment/{bookingId}
        routeGroup.MapGet("/{bookingId:int}", GetPaymentByBookingId)
            .WithName("GetPaymentByBookingId")
            .WithSummary("Get Payment by bookingId")
            .WithDescription("Get Payment by bookingId")
            .Produces<PaymentResponse>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // POST: /Payment
        routeGroup.MapPost("/", CreatePayment)
            .WithName("CreatePayment")
            .WithSummary("Create a new payment")
            .WithDescription("Create a new payment for a user")
            .Accepts<PaymentRequest>("application/json")
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);
    }

    internal async Task<Results<Ok<IEnumerable<PaymentResponse>>, ProblemHttpResult, NotFound>> GetPaymentsByUserId(
        [FromServices] IPaymentRepository repository,
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
            var payments = await repository.GetPaymentsByUserIdAsync(user.Id, page, pageSize);
            return TypedResults.Ok(payments);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while retrieving Payments: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<PaymentResponse>, ProblemHttpResult, NotFound>> GetPaymentByBookingId(
        [FromServices] IPaymentRepository repository,
        [FromRoute] int bookingId)
    {
        try
        {
            var payment = await repository.GetPaymentByBookingIdAsync(p => p.BookingId == bookingId);
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
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult>> CreatePayment(
        [FromServices] IPaymentRepository repository,
        [FromServices] IPaymentService paymentService,
        [FromBody] PaymentRequest paymentRequest)
    {
        try
        {
            //check if the payment already exists for the bookingId and status is not partially completed
            var existingPayment = await repository.GetPaymentByBookingIdAsync(p => p.BookingId == paymentRequest.BookingId && p.Status != PaymentStatus.PartiallyCompleted);
            if (existingPayment != null)
            {
                return TypedResults.Problem("Payment already exists for this booking.", statusCode: StatusCodes.Status400BadRequest);
            }

            Payment payment = new Payment
            {
                AmountPaid = paymentRequest.AmountPaid,
                BookingId = paymentRequest.BookingId,
                Method = paymentRequest.Method,
                Status = PaymentStatus.Pending
            };

            if (paymentRequest.Method == PaymentMethod.Online)
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
    }
}
