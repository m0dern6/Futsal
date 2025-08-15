using System.Security.Claims;
using FutsalApi.ApiService.Infrastructure;
using PaymentGateway;
using FutsalApi.ApiService.Services;
using FutsalApi.Data.DTO;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using FutsalApi.ApiService.Infrastructure;

namespace FutsalApi.ApiService.Routes;

public class PaymentGatewayApiEndpoints : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/PaymentGateway")
            .WithTags("PaymentGateway")
            .RequireAuthorization();

        // eSewa endpoints
        routeGroup.MapPost("/esewa/initiate", InitiateESewaPayment)
            .WithName("InitiateESewaPayment")
            .WithSummary("Initiate eSewa payment")
            .WithDescription("Initiate a new eSewa payment for a booking")
            .Produces<ESewaInitiateResponse>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPost("/esewa/callback", ProcessESewaCallback)
            .WithName("ProcessESewaCallback")
            .WithSummary("Process eSewa callback")
            .WithDescription("Process eSewa payment callback")
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        // Khalti endpoints
        routeGroup.MapPost("/khalti/initiate", InitiateKhaltiPayment)
            .WithName("InitiateKhaltiPayment")
            .WithSummary("Initiate Khalti payment")
            .WithDescription("Initiate a new Khalti payment for a booking")
            .Produces<KhaltiInitiateResponse>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPost("/khalti/callback", ProcessKhaltiCallback)
            .WithName("ProcessKhaltiCallback")
            .WithSummary("Process Khalti callback")
            .WithDescription("Process Khalti payment callback")
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);

        routeGroup.MapPost("/khalti/webhook", ProcessKhaltiWebhook)
            .WithName("ProcessKhaltiWebhook")
            .WithSummary("Process Khalti webhook")
            .WithDescription("Process Khalti payment webhook")
            .AllowAnonymous()
            .Produces<string>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError);
    }

    internal async Task<Results<Ok<ESewaInitiateResponse>, ProblemHttpResult>> InitiateESewaPayment(
        [FromServices] IPaymentService paymentService,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        [FromBody] ESewaPaymentInitiateRequest request)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("User not found.", statusCode: StatusCodes.Status401Unauthorized);
            }

            var response = await paymentService.InitiateESewaPaymentAsync(
                request.BookingId,
                request.SuccessUrl,
                request.FailureUrl);

            if (response.Success)
            {
                return TypedResults.Ok(response);
            }

            return TypedResults.Problem(response.Message, statusCode: StatusCodes.Status400BadRequest);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while initiating eSewa payment: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult>> ProcessESewaCallback(
        [FromServices] IPaymentService paymentService,
        [FromBody] ESewaCallbackResponse callback)
    {
        try
        {
            var payment = await paymentService.ProcessESewaCallbackAsync(callback);

            if (payment != null)
            {
                return TypedResults.Ok("Payment processed successfully");
            }

            return TypedResults.Problem("Failed to process payment", statusCode: StatusCodes.Status400BadRequest);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while processing eSewa callback: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<KhaltiInitiateResponse>, ProblemHttpResult>> InitiateKhaltiPayment(
        [FromServices] IPaymentService paymentService,
        [FromServices] UserManager<User> userManager,
        ClaimsPrincipal claimsPrincipal,
        [FromBody] KhaltiPaymentInitiateRequest request)
    {
        try
        {
            if (await userManager.GetUserAsync(claimsPrincipal) is not { } user)
            {
                return TypedResults.Problem("User not found.", statusCode: StatusCodes.Status401Unauthorized);
            }

            var response = await paymentService.InitiateKhaltiPaymentAsync(
                request.BookingId,
                request.ReturnUrl,
                request.WebsiteUrl);

            if (response.Success)
            {
                return TypedResults.Ok(response);
            }

            return TypedResults.Problem(response.Message, statusCode: StatusCodes.Status400BadRequest);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while initiating Khalti payment: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult>> ProcessKhaltiCallback(
        [FromServices] IPaymentService paymentService,
        [FromQuery] string pidx)
    {
        try
        {
            if (string.IsNullOrEmpty(pidx))
            {
                return TypedResults.Problem("PIDX is required", statusCode: StatusCodes.Status400BadRequest);
            }

            var payment = await paymentService.ProcessKhaltiCallbackAsync(pidx);

            if (payment != null)
            {
                return TypedResults.Ok("Payment processed successfully");
            }

            return TypedResults.Problem("Failed to process payment", statusCode: StatusCodes.Status400BadRequest);
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while processing Khalti callback: {ex.Message}");
        }
    }

    internal async Task<Results<Ok<string>, ProblemHttpResult>> ProcessKhaltiWebhook(
        [FromServices] IPaymentService paymentService,
        [FromBody] KhaltiWebhookPayload webhookPayload,
        [FromHeader(Name = "authorization")] string? authHeader)
    {
        try
        {
            // Process webhook payload
            if (webhookPayload.Status == "Completed")
            {
                var payment = await paymentService.ProcessKhaltiCallbackAsync(webhookPayload.Pidx);

                if (payment != null)
                {
                    return TypedResults.Ok("Webhook processed successfully");
                }
            }

            return TypedResults.Ok("Webhook received");
        }
        catch (Exception ex)
        {
            return TypedResults.Problem($"An error occurred while processing Khalti webhook: {ex.Message}");
        }
    }
}

// Request models for the endpoints
public class ESewaPaymentInitiateRequest
{
    public int BookingId { get; set; }
    public string SuccessUrl { get; set; } = string.Empty;
    public string FailureUrl { get; set; } = string.Empty;
}

public class KhaltiPaymentInitiateRequest
{
    public int BookingId { get; set; }
    public string ReturnUrl { get; set; } = string.Empty;
    public string WebsiteUrl { get; set; } = string.Empty;
}
