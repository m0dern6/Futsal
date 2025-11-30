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
                user,
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


public class KhaltiPaymentInitiateRequest
{
    public int BookingId { get; set; }
    public string ReturnUrl { get; set; } = string.Empty;
    public string WebsiteUrl { get; set; } = string.Empty;
}
