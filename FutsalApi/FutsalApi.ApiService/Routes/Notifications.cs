using System;
using System.Security.Claims;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Routes;

public static class NotificationsApiEndpointRouteBuilderExtensions
{
    public static IEndpointConventionBuilder MapNotificationApi(this IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/Notification").RequireAuthorization();

        // GET: /UserRoles
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<Notification>>, ProblemHttpResult, NotFound>>
            ([FromServices] INotificationRepository repository,
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
                var notifications = await repository.GetNotificationsByUserIdAsync(user.Id);
                return TypedResults.Ok(notifications);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving notifications: {ex.Message}");
            }
        })
        .WithName("GetNotificationsByUserId")
        .WithSummary("Get Notifications of a user")
        .WithDescription("Get all the Notifications for a partucular user using userid")
        .Accepts<ClaimsPrincipal>("User")
        .Accepts<int>("page")
        .Accepts<int>("pageSize")
        .Produces<IEnumerable<Notification>>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        return routeGroup;
    }

}
