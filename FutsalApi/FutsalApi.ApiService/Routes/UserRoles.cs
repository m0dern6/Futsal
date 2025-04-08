using System;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Routes;

public static class UserRolesApiEndpointRouteBuilderExtensions
{
    /// <summary>
    /// Maps API endpoints for User Role management.
    /// </summary>
    /// <param name="endpoints">The <see cref="IEndpointRouteBuilder"/> to add the endpoints to.</param>
    /// <returns>An <see cref="IEndpointConventionBuilder"/> to further customize the added endpoints.</returns>

    public static IEndpointConventionBuilder MapUserRolesApi(this IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/UserRoles").RequireAuthorization();

        var repository = endpoints.ServiceProvider.GetRequiredService<IGenericrepository<UserRole>>();
        var logger = endpoints.ServiceProvider.GetRequiredService<ILogger>();

        // GET: /UserRoles (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<UserRole>>, ProblemHttpResult>>
            ([FromQuery] int page = 1, [FromQuery] int pageSize = 10) =>
        {
            if (page <= 0 || pageSize <= 0)
            {
                return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: 400);
            }

            try
            {
                var userRoles = await repository.GetAllAsync(page, pageSize);
                return TypedResults.Ok(userRoles);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving user roles.");
                return TypedResults.Problem($"An error occurred while retrieving user roles: {ex.Message}");
            }

        })
        .WithName("GetUserRoles")
        .WithSummary("Get all user roles")
        .WithDescription("Retrieves a paginated list of users along with their roles.")
        .Produces<IEnumerable<UserRole>>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status500InternalServerError)
        .WithTags("UserRoles");

        // GET: /UserRoles/{id}
        routeGroup.MapGet("/{id}", async Task<Results<Ok<UserRole>, NotFound, ProblemHttpResult>>
            ([FromRoute] string id) =>
        {
            try
            {
                var userRole = await repository.GetByIdAsync(e => e.UserId == id);
                if (userRole == null)
                {
                    return TypedResults.NotFound();
                }
                return TypedResults.Ok(userRole);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving the user role with ID {Id}.", id);
                return TypedResults.Problem($"An error occurred while retrieving the user role: {ex.Message}");
            }
        })
        .WithName("GetUserRoleById")
        .WithSummary("Get a user role by ID")
        .WithDescription("Retrieves a user role by its ID.")
        .Produces<UserRole>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        return routeGroup;
    }

}
