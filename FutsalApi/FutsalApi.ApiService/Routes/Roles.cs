using System;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Routes;

public static class RolesApiEndpointRouteBuilderExtensions
{
    /// <summary>
    /// Maps API endpoints for Roles management.
    /// </summary>
    /// <param name="endpoints">The <see cref="IEndpointRouteBuilder"/> to add the endpoints to.</param>
    /// <returns>An <see cref="IEndpointConventionBuilder"/> to further customize the added endpoints.</returns>

    public static IEndpointConventionBuilder MapRolesApi(this IEndpointRouteBuilder endpoints)
    {
        var routeGroup = endpoints.MapGroup("/Roles").RequireAuthorization();

        var repository = endpoints.ServiceProvider.GetRequiredService<IGenericrepository<Role>>();
        var logger = endpoints.ServiceProvider.GetRequiredService<ILogger>();

        // GET: /Roles (with pagination)
        routeGroup.MapGet("/", async Task<Results<Ok<IEnumerable<Role>>, ProblemHttpResult>>
            ([FromQuery] int page = 1, [FromQuery] int pageSize = 10) =>
        {
            if (page <= 0 || pageSize <= 0)
            {
                return TypedResults.Problem(detail: "Page and pageSize must be greater than 0.", statusCode: 400);
            }

            try
            {
                var roles = await repository.GetAllAsync(page, pageSize);
                return TypedResults.Ok(roles);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving roles.");
                return TypedResults.Problem($"An error occurred while retrieving roles: {ex.Message}");
            }
        })
        .WithName("GetAllRoles")
        .WithSummary("Retrieves all roles with pagination.")
        .WithDescription("Returns a paginated list of all roles available in the system.")
        .Produces<IEnumerable<Role>>(200)
        .ProducesProblem(400)
        .ProducesProblem(500);

        // GET: /Roles/{id}
        routeGroup.MapGet("/{id}", async Task<Results<Ok<Role>, NotFound, ProblemHttpResult>>
            ([FromRoute] string id) =>
        {
            try
            {
                var role = await repository.GetByIdAsync(e => e.Id == id);
                if (role == null)
                {
                    return TypedResults.NotFound();
                }
                return TypedResults.Ok(role);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while retrieving the role.");
                return TypedResults.Problem($"An error occurred while retrieving the role: {ex.Message}");
            }
        })
        .WithName("GetRoleById")
        .WithSummary("Retrieves a role by its ID.")
        .WithDescription("Returns the details of a specific role based on its ID.")
        .Produces<Role>(200)
        .ProducesProblem(404)
        .ProducesProblem(500);

        // POST: /Roles
        routeGroup.MapPost("/", async Task<Results<Ok<Role>, ProblemHttpResult>>
            ([FromBody] Role role) =>
        {
            try
            {
                var createdRole = await repository.CreateAsync(role);
                return TypedResults.Ok(createdRole);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while creating the role.");
                return TypedResults.Problem($"An error occurred while creating the role: {ex.Message}");
            }
        })
        .WithName("CreateRole")
        .WithSummary("Creates a new role.")
        .WithDescription("Creates a new role in the system.")
        .Produces<Role>(200)
        .ProducesProblem(400)
        .ProducesProblem(500);

        // PUT: /Roles/{id}
        routeGroup.MapPut("/{id}", async Task<Results<Ok<Role>, NotFound, ProblemHttpResult>>
            ([FromRoute] string id, [FromBody] Role role) =>
        {
            try
            {
                var updatedRole = await repository.UpdateAsync(e => e.Id == id, role);
                if (updatedRole == null)
                {
                    return TypedResults.NotFound();
                }
                return TypedResults.Ok(updatedRole);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while updating the role.");
                return TypedResults.Problem($"An error occurred while updating the role: {ex.Message}");
            }
        })
        .WithName("UpdateRole")
        .WithSummary("Updates an existing role.")
        .WithDescription("Updates the details of an existing role.")
        .Produces<Role>(200)
        .ProducesProblem(404)
        .ProducesProblem(500);

        // DELETE: /Roles/{id}
        routeGroup.MapDelete("/{id}", async Task<Results<NoContent, NotFound, ProblemHttpResult>>
            ([FromRoute] string id) =>
        {
            try
            {
                var deleted = await repository.DeleteAsync(e => e.Id == id);
                if (!deleted)
                {
                    return TypedResults.NotFound();
                }
                return TypedResults.NoContent();
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while deleting the role.");
                return TypedResults.Problem($"An error occurred while deleting the role: {ex.Message}");
            }
        })
        .WithName("DeleteRole")
        .WithSummary("Deletes a role.")
        .WithDescription("Deletes a specific role based on its ID.")
        .Produces(204)
        .ProducesProblem(404)
        .ProducesProblem(500);

        return routeGroup;
    }
}