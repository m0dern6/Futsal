using System.Linq.Expressions;
using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Routes;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Moq;
using Xunit;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using FutsalApi.Data.DTO;
using FutsalApi.Auth.Routes;
using FutsalApi.Auth.Models;

namespace FutsalApi.Tests;

public class UserRolesApiEndpointsTests
{
    private readonly Mock<RoleManager<Role>> _roleManagerMock;
    private readonly Mock<UserManager<User>> _userManagerMock;
    private readonly UserRolesApiEndpoints _endpoints;

    public UserRolesApiEndpointsTests()
    {
        _roleManagerMock = MockRoleManager();
        _userManagerMock = MockUserManager();
        _endpoints = new UserRolesApiEndpoints();
    }

    [Fact]
    public async Task GetAllUserRoles_ReturnsOk_WhenUserRolesExist()
    {
        // Arrange
        var roles = new List<Role>
        {
            new Role { Id = "1", Name = "Admin" },
            new Role { Id = "2", Name = "User" }
        };
        var users = new List<User>
        {
            new User { Id = "user1", UserName = "User1" },
            new User { Id = "user2", UserName = "User2" }
        };

        _roleManagerMock.Setup(r => r.Roles).Returns(roles.AsQueryable());
        _userManagerMock.Setup(u => u.GetUsersInRoleAsync("Admin")).ReturnsAsync(users);

        // Act
        var result = await _endpoints.GetAllUserRoles(_roleManagerMock.Object, _userManagerMock.Object);

        // Assert
        result.Should().BeOfType<Results<Ok<List<UserRole>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<UserRole>>, ProblemHttpResult> { Result: Ok<List<UserRole>> okResult })
        {
            okResult.Value.Should().HaveCount(2);
        }
    }

    [Fact]
    public async Task GetUserRoles_ReturnsOk_WhenUserHasRoles()
    {
        // Arrange
        var user = new User { Id = "user1", UserName = "User1" };
        var roles = new List<string> { "Admin", "User" };

        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync(user);
        _userManagerMock.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(roles);

        // Act
        var result = await _endpoints.GetUserRoles(_userManagerMock.Object, "user1");

        // Assert
        result.Should().BeOfType<Results<Ok<List<string>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<string>>, ProblemHttpResult> { Result: Ok<List<string>> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(roles);
        }
    }

    [Fact]
    public async Task GetUserRoles_ReturnsProblem_WhenUserNotFound()
    {
        // Arrange
        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync((User?)null);

        // Act
        var result = await _endpoints.GetUserRoles(_userManagerMock.Object, "user1");

        // Assert
        result.Should().BeOfType<Results<Ok<List<string>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<string>>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("User with ID user1 not found.");
        }
    }

    [Fact]
    public async Task GetUsersInRole_ReturnsOk_WhenUsersExistInRole()
    {
        // Arrange
        var role = new Role { Id = "1", Name = "Admin" };
        var users = new List<User>
        {
            new User { Id = "user1", UserName = "User1" },
            new User { Id = "user2", UserName = "User2" }
        };

        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync(role);
        _userManagerMock.Setup(u => u.GetUsersInRoleAsync("Admin")).ReturnsAsync(users);

        // Act
        var result = await _endpoints.GetUsersInRole(_roleManagerMock.Object, _userManagerMock.Object, "1");

        // Assert
        result.Should().BeOfType<Results<Ok<List<string>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<string>>, ProblemHttpResult> { Result: Ok<List<string>> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(users.Select(u => u.UserName));
        }
    }

    [Fact]
    public async Task AssignUserRole_ReturnsOk_WhenRoleAssigned()
    {
        // Arrange
        var user = new User { Id = "user1", UserName = "User1" };
        var role = new Role { Id = "1", Name = "Admin" };

        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync(user);
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync(role);
        _userManagerMock.Setup(u => u.AddToRoleAsync(user, "Admin")).ReturnsAsync(IdentityResult.Success);

        // Act
        var result = await _endpoints.AssignUserRole(_roleManagerMock.Object, _userManagerMock.Object, new UserRole { UserId = "user1", RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("User User1 assigned to role Admin.");
        }
    }

    [Fact]
    public async Task AssignUserRole_ReturnsProblem_WhenUserNotFound()
    {
        // Arrange
        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync((User?)null);

        // Act
        var result = await _endpoints.AssignUserRole(_roleManagerMock.Object, _userManagerMock.Object, new UserRole { UserId = "user1", RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("User with ID user1 not found.");
        }
    }

    [Fact]
    public async Task AssignUserRole_ReturnsProblem_WhenRoleNotFound()
    {
        // Arrange
        var user = new User { Id = "user1", UserName = "User1" };
        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync(user);
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync((Role?)null);

        // Act
        var result = await _endpoints.AssignUserRole(_roleManagerMock.Object, _userManagerMock.Object, new UserRole { UserId = "user1", RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Role with ID 1 not found.");
        }
    }

    [Fact]
    public async Task AssignUserRole_ReturnsProblem_WhenAssignmentFails()
    {
        // Arrange
        var user = new User { Id = "user1", UserName = "User1" };
        var role = new Role { Id = "1", Name = "Admin" };
        var identityError = new IdentityError { Description = "Some error" };
        var failedResult = IdentityResult.Failed(identityError);

        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync(user);
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync(role);
        _userManagerMock.Setup(u => u.AddToRoleAsync(user, "Admin")).ReturnsAsync(failedResult);

        // Act
        var result = await _endpoints.AssignUserRole(_roleManagerMock.Object, _userManagerMock.Object, new UserRole { UserId = "user1", RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Contain("Failed to assign role");
        }
    }

    [Fact]
    public async Task RemoveUserRole_ReturnsOk_WhenRoleRemoved()
    {
        // Arrange
        var user = new User { Id = "user1", UserName = "User1" };
        var role = new Role { Id = "1", Name = "Admin" };

        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync(user);
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync(role);
        _userManagerMock.Setup(u => u.RemoveFromRoleAsync(user, "Admin")).ReturnsAsync(IdentityResult.Success);

        // Act
        var result = await _endpoints.RemoveUserRole(_roleManagerMock.Object, _userManagerMock.Object, "user1", new UserRole { RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("User User1 removed from role Admin.");
        }
    }

    [Fact]
    public async Task RemoveUserRole_ReturnsProblem_WhenUserNotFound()
    {
        // Arrange
        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync((User?)null);

        // Act
        var result = await _endpoints.RemoveUserRole(_roleManagerMock.Object, _userManagerMock.Object, "user1", new UserRole { RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("User with ID user1 not found.");
        }
    }

    [Fact]
    public async Task RemoveUserRole_ReturnsProblem_WhenRoleNotFound()
    {
        // Arrange
        var user = new User { Id = "user1", UserName = "User1" };
        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync(user);
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync((Role?)null);

        // Act
        var result = await _endpoints.RemoveUserRole(_roleManagerMock.Object, _userManagerMock.Object, "user1", new UserRole { RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Role with ID 1 not found.");
        }
    }

    [Fact]
    public async Task RemoveUserRole_ReturnsProblem_WhenRemovalFails()
    {
        // Arrange
        var user = new User { Id = "user1", UserName = "User1" };
        var role = new Role { Id = "1", Name = "Admin" };
        var identityError = new IdentityError { Description = "Remove error" };
        var failedResult = IdentityResult.Failed(identityError);

        _userManagerMock.Setup(u => u.FindByIdAsync("user1")).ReturnsAsync(user);
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync(role);
        _userManagerMock.Setup(u => u.RemoveFromRoleAsync(user, "Admin")).ReturnsAsync(failedResult);

        // Act
        var result = await _endpoints.RemoveUserRole(_roleManagerMock.Object, _userManagerMock.Object, "user1", new UserRole { RoleId = "1" });

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Contain("Failed to remove role");
        }
    }

    [Fact]
    public async Task GetAllUserRoles_ReturnsOk_WhenNoRolesExist()
    {
        // Arrange
        _roleManagerMock.Setup(r => r.Roles).Returns(new List<Role>().AsQueryable());

        // Act
        var result = await _endpoints.GetAllUserRoles(_roleManagerMock.Object, _userManagerMock.Object);

        // Assert
        result.Should().BeOfType<Results<Ok<List<UserRole>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<UserRole>>, ProblemHttpResult> { Result: Ok<List<UserRole>> okResult })
        {
            okResult.Value.Should().BeEmpty();
        }
    }

    [Fact]
    public async Task GetAllUserRoles_ReturnsProblem_OnException()
    {
        // Arrange
        _roleManagerMock.Setup(r => r.Roles).Throws(new Exception("DB error"));

        // Act
        var result = await _endpoints.GetAllUserRoles(_roleManagerMock.Object, _userManagerMock.Object);

        // Assert
        result.Should().BeOfType<Results<Ok<List<UserRole>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<UserRole>>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Contain("An error occurred while retrieving all user roles");
        }
    }

    [Fact]
    public async Task GetUsersInRole_ReturnsProblem_WhenRoleNotFound()
    {
        // Arrange
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync((Role?)null);

        // Act
        var result = await _endpoints.GetUsersInRole(_roleManagerMock.Object, _userManagerMock.Object, "1");

        // Assert
        result.Should().BeOfType<Results<Ok<List<string>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<string>>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Role with ID 1 not found.");
        }
    }

    [Fact]
    public async Task GetUsersInRole_ReturnsProblem_OnException()
    {
        // Arrange
        var role = new Role { Id = "1", Name = "Admin" };
        _roleManagerMock.Setup(r => r.FindByIdAsync("1")).ReturnsAsync(role);
        _userManagerMock.Setup(u => u.GetUsersInRoleAsync("Admin")).ThrowsAsync(new Exception("Some error"));

        // Act
        var result = await _endpoints.GetUsersInRole(_roleManagerMock.Object, _userManagerMock.Object, "1");

        // Assert
        result.Should().BeOfType<Results<Ok<List<string>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<string>>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Contain("An error occurred while retrieving users in the role");
        }
    }

    private static Mock<RoleManager<Role>> MockRoleManager()
    {
        var roleStoreMock = new Mock<IRoleStore<Role>>();
        var roleValidators = new List<IRoleValidator<Role>>(); // Empty list of role validators
        var lookupNormalizerMock = new Mock<ILookupNormalizer>();
        var identityErrorDescriber = new IdentityErrorDescriber();
        var loggerMock = new Mock<ILogger<RoleManager<Role>>>();

        return new Mock<RoleManager<Role>>(
            roleStoreMock.Object,
            roleValidators,
            lookupNormalizerMock.Object,
            identityErrorDescriber,
            loggerMock.Object
        );
    }

    private static Mock<UserManager<User>> MockUserManager()
    {
        var store = new Mock<IUserStore<User>>();
        var options = new Mock<Microsoft.Extensions.Options.IOptions<IdentityOptions>>();
        var passwordHasher = new Mock<IPasswordHasher<User>>();
        var userValidators = new List<IUserValidator<User>>();
        var passwordValidators = new List<IPasswordValidator<User>>();
        var keyNormalizer = new Mock<ILookupNormalizer>();
        var errors = new Mock<IdentityErrorDescriber>();
        var services = new Mock<IServiceProvider>();
        var logger = new Mock<Microsoft.Extensions.Logging.ILogger<UserManager<User>>>();

        return new Mock<UserManager<User>>(
            store.Object,
            options.Object,
            passwordHasher.Object,
            userValidators,
            passwordValidators,
            keyNormalizer.Object,
            errors.Object,
            services.Object,
            logger.Object
        );
    }
}
