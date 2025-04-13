using System;
using System.Security.Claims;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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
        var userManager = endpoints.ServiceProvider.GetRequiredService<UserManager<User>>();
        var roleManager = endpoints.ServiceProvider.GetRequiredService<RoleManager<Role>>();

        // GET: /UserRoles
        routeGroup.MapGet("/", async Task<Results<Ok<List<UserRole>>, ProblemHttpResult>>
            () =>
        {
            try
            {
                var roles = await roleManager.Roles.ToListAsync();
                var userRoles = new List<UserRole>();

                foreach (var role in roles)
                {
                    var usersInRole = await userManager.GetUsersInRoleAsync(role.Name);
                    foreach (var user in usersInRole)
                    {
                        userRoles.Add(new UserRole { UserId = user.Id, RoleId = role.Id });
                    }
                }
                return TypedResults.Ok(userRoles);
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving all user roles: {ex.Message}");
            }
        })
        .WithName("GetAllUserRoles")
        .WithSummary("Retrieves all user roles.")
        .WithDescription("Returns a list of all user roles in the system.")
        .Produces<List<UserRole>>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // GET: /UserRoles/{userId}
        routeGroup.MapGet("/{userId}", async Task<Results<Ok<List<string>>, ProblemHttpResult>>
            (string userId) =>
        {
            try
            {
                var user = await userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    return TypedResults.Problem($"User with ID {userId} not found.", statusCode: StatusCodes.Status404NotFound);
                }

                var roles = await userManager.GetRolesAsync(user);
                return TypedResults.Ok(roles.ToList());
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving user roles: {ex.Message}");
            }
        })
        .WithName("GetUserRoles")
        .WithSummary("Retrieves roles for a specific user.")
        .WithDescription("Returns a list of roles assigned to the specified user.")
        .Produces<List<string>>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // GET: /UserRoles/Role/{roleId}
        routeGroup.MapGet("/Role/{roleId}", async Task<Results<Ok<List<string>>, ProblemHttpResult>>
            (string roleId) =>
        {
            try
            {
                var role = await roleManager.FindByIdAsync(roleId);
                if (role == null)
                {
                    return TypedResults.Problem($"Role with ID {roleId} not found.", statusCode: StatusCodes.Status404NotFound);
                }

                var usersInRole = await userManager.GetUsersInRoleAsync(role.Name);
                return TypedResults.Ok(usersInRole.Select(u => u.UserName).Where(userName => userName != null).Cast<string>().ToList());
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while retrieving users in the role: {ex.Message}");
            }
        })
        .WithName("GetUsersInRole")
        .WithSummary("Retrieves users in a specific role.")
        .WithDescription("Returns a list of users associated with the specified role.")
        .Produces<List<string>>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);


        // POST: /UserRoles
        routeGroup.MapPost("/", async Task<Results<Ok<string>, ProblemHttpResult>>
            ([FromBody] UserRole userRoleDto) =>
        {
            try
            {
                var user = await userManager.FindByIdAsync(userRoleDto.UserId);
                if (user == null)
                {
                    return TypedResults.Problem($"User with ID {userRoleDto.UserId} not found.", statusCode: 404);
                }

                var role = await roleManager.FindByIdAsync(userRoleDto.RoleId);
                if (role == null)
                {
                    return TypedResults.Problem($"Role with ID {userRoleDto.RoleId} not found.", statusCode: StatusCodes.Status404NotFound);
                }

                var result = await userManager.AddToRoleAsync(user, role.Name);
                if (!result.Succeeded)
                {
                    return TypedResults.Problem($"Failed to assign role: {string.Join(", ", result.Errors.Select(e => e.Description))}", statusCode: StatusCodes.Status400BadRequest);
                }

                return TypedResults.Ok($"User {user.UserName} assigned to role {role.Name}.");
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while assigning user roles: {ex.Message}");
            }
        })
        .WithName("AssignUserRole")
        .WithSummary("Assigns a role to a user.")
        .WithDescription("Assigns the specified role to the user.")
        .Accepts<UserRole>("application/json")
        .Produces<string>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);

        // DELETE: /UserRoles/{userId}
        routeGroup.MapDelete("/{userId}", async Task<Results<Ok<string>, ProblemHttpResult>>
            (string userId, [FromBody] UserRole userRoleDto) =>
        {
            try
            {
                var user = await userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    return TypedResults.Problem($"User with ID {userId} not found.", statusCode: StatusCodes.Status404NotFound);
                }

                var role = await roleManager.FindByIdAsync(userRoleDto.RoleId);
                if (role is null || string.IsNullOrEmpty(role.Name))

                {
                    return TypedResults.Problem($"Role with ID {userRoleDto.RoleId} not found.", statusCode: StatusCodes.Status404NotFound);
                }

                var result = await userManager.RemoveFromRoleAsync(user, role.Name);
                if (!result.Succeeded)
                {
                    return TypedResults.Problem($"Failed to remove role: {string.Join(", ", result.Errors.Select(e => e.Description))}", statusCode: StatusCodes.Status400BadRequest);
                }

                return TypedResults.Ok($"User {user.UserName} removed from role {role.Name}.");
            }
            catch (Exception ex)
            {
                return TypedResults.Problem($"An error occurred while removing user roles: {ex.Message}");
            }
        })
        .WithName("RemoveUserRole")
        .WithSummary("Removes a role from a user.")
        .WithDescription("Removes the specified role from the user.")
        .Accepts<UserRole>("application/json")
        .Produces<string>(StatusCodes.Status200OK)
        .ProducesProblem(StatusCodes.Status400BadRequest)
        .ProducesProblem(StatusCodes.Status404NotFound)
        .ProducesProblem(StatusCodes.Status500InternalServerError);


        return routeGroup;
    }

}
