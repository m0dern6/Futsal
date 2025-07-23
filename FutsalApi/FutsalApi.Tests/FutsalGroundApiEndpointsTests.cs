using System.Linq.Expressions;
using System.Security.Claims;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Routes;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Moq;
using FluentAssertions;
using FutsalApi.Data.DTO;
using FutsalApi.Auth.Models;

namespace FutsalApi.Tests;

public class FutsalGroundApiEndpointsTests
{
    private readonly Mock<IFutsalGroundRepository> _repositoryMock;
    private readonly Mock<UserManager<User>> _userManagerMock;
    private readonly FutsalGroundApiEndpoints _endpoints;

    public FutsalGroundApiEndpointsTests()
    {
        _repositoryMock = new Mock<IFutsalGroundRepository>();
        _userManagerMock = MockUserManager();
        _endpoints = new FutsalGroundApiEndpoints();
    }

    [Fact]
    public async Task GetAllFutsalGrounds_ReturnsOk_WhenValid()
    {
        // Arrange
        var futsalGrounds = new List<FutsalGroundResponse>
        {
            new FutsalGroundResponse { Id = 1, Name = "Ground 1", Location = "Location 1", OwnerId = "Owner1" }
        };
        _repositoryMock.Setup(r => r.GetAllAsync(1, 10)).ReturnsAsync(futsalGrounds);

        // Act
        var result = await _endpoints.GetAllFutsalGrounds(_repositoryMock.Object, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<FutsalGroundResponse>>, ProblemHttpResult>>();
        if (result is Results<Ok<IEnumerable<FutsalGroundResponse>>, ProblemHttpResult> { Result: Ok<IEnumerable<FutsalGroundResponse>> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(futsalGrounds);
        }
    }

    [Fact]
    public async Task GetAllFutsalGrounds_ReturnsProblem_WhenInvalidPage()
    {
        // Act
        var result = await _endpoints.GetAllFutsalGrounds(_repositoryMock.Object, 0, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<FutsalGroundResponse>>, ProblemHttpResult>>();
        if (result is Results<Ok<IEnumerable<FutsalGroundResponse>>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Page and pageSize must be greater than 0.");
        }
    }

    [Fact]
    public async Task GetFutsalGroundById_ReturnsOk_WhenFound()
    {
        // Arrange
        var futsalGround = new FutsalGroundResponse { Id = 1, Name = "Ground 1", Location = "Location 1", OwnerId = "Owner1" };
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(futsalGround);

        // Act
        var result = await _endpoints.GetFutsalGroundById(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<FutsalGroundResponse>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<FutsalGroundResponse>, NotFound, ProblemHttpResult> { Result: Ok<FutsalGroundResponse> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(futsalGround);
        }
    }

    [Fact]
    public async Task GetFutsalGroundById_ReturnsNotFound_WhenNotFound()
    {
        // Arrange
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync((FutsalGroundResponse?)null);

        // Act
        var result = await _endpoints.GetFutsalGroundById(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<FutsalGroundResponse>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<FutsalGroundResponse>, NotFound, ProblemHttpResult> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task CreateFutsalGround_ReturnsOk_WhenCreated()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var futsalGroundRequest = new FutsalGroundRequest
        {
            Name = "Ground 1",
            Location = "Location 1",
            OwnerId = "Owner1",
            PricePerHour = 100,
            OpenTime = TimeSpan.FromHours(8),
            CloseTime = TimeSpan.FromHours(22)
        };
        var futsalGround = new FutsalGround
        {
            Id = 1,
            Name = "Ground 1",
            Location = "Location 1",
            OwnerId = "user1",
            PricePerHour = 100,
            OpenTime = TimeSpan.FromHours(8),
            CloseTime = TimeSpan.FromHours(22)
        };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.CreateAsync(It.IsAny<FutsalGround>())).ReturnsAsync(futsalGround);

        // Act
        var result = await _endpoints.CreateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, futsalGroundRequest);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("Futsal ground created successfully.");
        }
    }

    [Fact]
    public async Task CreateFutsalGround_ReturnsProblem_WhenUserNotFound()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal();
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync((User?)null);
        var request = new FutsalGroundRequest();

        // Act
        var result = await _endpoints.CreateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, request);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("User not found.");
        }
    }

    [Fact]
    public async Task CreateFutsalGround_ReturnsProblem_WhenDuplicateGround()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var request = new FutsalGroundRequest
        {
            Name = "Ground 1",
            OpenTime = TimeSpan.FromHours(8),
            CloseTime = TimeSpan.FromHours(22)
        };
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(new FutsalGroundResponse());

        // Act
        var result = await _endpoints.CreateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, request);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("Futsal ground with the same name already exists.");
        }
    }

    [Fact]
    public async Task CreateFutsalGround_ReturnsProblem_WhenInvalidOpenCloseTime()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var request = new FutsalGroundRequest
        {
            Name = "Ground 1",
            OpenTime = TimeSpan.FromHours(10),
            CloseTime = TimeSpan.FromHours(8)
        };
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);

        // Act
        var result = await _endpoints.CreateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, request);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("Open time must be less than close time.");
        }
    }

    [Fact]
    public async Task UpdateFutsalGround_ReturnsOk_WhenUpdated()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var futsalGroundRequest = new FutsalGroundRequest
        {
            Name = "Updated Ground",
            OwnerId = "Owner1",
            Location = "Updated Location",
            PricePerHour = 150,
            OpenTime = TimeSpan.FromHours(9),
            CloseTime = TimeSpan.FromHours(21)
        };
        var existingGround = new FutsalGroundResponse
        {
            Id = 1,
            Name = "Ground 1",
            Location = "Location 1",
            OwnerId = "user1"
        };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(existingGround);
        _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>(), It.IsAny<FutsalGround>())).ReturnsAsync(new FutsalGround());

        // Act
        var result = await _endpoints.UpdateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, futsalGroundRequest);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<string>, NotFound, ProblemHttpResult> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("Futsal ground updated successfully.");
        }
    }

    [Fact]
    public async Task UpdateFutsalGround_ReturnsProblem_WhenUserNotFound()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal();
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync((User?)null);
        var request = new FutsalGroundRequest();

        // Act
        var result = await _endpoints.UpdateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, request);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<string>, NotFound, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("You are not authorized to update this futsalground");
        }
    }

    [Fact]
    public async Task UpdateFutsalGround_ReturnsNotFound_WhenGroundNotFound()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var request = new FutsalGroundRequest();
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync((FutsalGroundResponse?)null);

        // Act
        var result = await _endpoints.UpdateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, request);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<string>, NotFound, ProblemHttpResult> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task UpdateFutsalGround_ReturnsProblem_WhenInvalidOpenCloseTime()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var request = new FutsalGroundRequest
        {
            OpenTime = TimeSpan.FromHours(10),
            CloseTime = TimeSpan.FromHours(8)
        };
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(new FutsalGroundResponse());

        // Act
        var result = await _endpoints.UpdateFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, request);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<string>, NotFound, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("Open time must be less than close time.");
        }
    }

    [Fact]
    public async Task DeleteFutsalGround_ReturnsNoContent_WhenDeleted()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var existingGround = new FutsalGroundResponse
        {
            Id = 1,
            Name = "Ground 1",
            Location = "Location 1",
            OwnerId = "user1"
        };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(existingGround);
        _repositoryMock.Setup(r => r.DeleteAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(true);

        // Act
        var result = await _endpoints.DeleteFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1);

        // Assert
        result.Should().BeOfType<Results<NoContent, NotFound, ProblemHttpResult>>();
        if (result is Results<NoContent, NotFound, ProblemHttpResult> { Result: NoContent })
        {
            result.Result.Should().BeOfType<NoContent>();
        }
    }

    [Fact]
    public async Task DeleteFutsalGround_ReturnsProblem_WhenUserNotFound()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal();
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync((User?)null);

        // Act
        var result = await _endpoints.DeleteFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1);

        // Assert
        result.Should().BeOfType<Results<NoContent, NotFound, ProblemHttpResult>>();
        if (result is Results<NoContent, NotFound, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("You are not authorized to delete this futsal ground.");
        }
    }

    [Fact]
    public async Task DeleteFutsalGround_ReturnsProblem_WhenHasActiveBookings()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.HasActiveBookingsAsync(It.IsAny<int>())).ReturnsAsync(true);

        // Act
        var result = await _endpoints.DeleteFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1);

        // Assert
        result.Should().BeOfType<Results<NoContent, NotFound, ProblemHttpResult>>();
        if (result is Results<NoContent, NotFound, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("Cannot delete the futsal ground because it has active bookings.");
        }
    }

    [Fact]
    public async Task DeleteFutsalGround_ReturnsNotFound_WhenGroundNotFound()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.HasActiveBookingsAsync(It.IsAny<int>())).ReturnsAsync(false);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync((FutsalGroundResponse?)null);

        // Act
        var result = await _endpoints.DeleteFutsalGround(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1);

        // Assert
        result.Should().BeOfType<Results<NoContent, NotFound, ProblemHttpResult>>();
        if (result is Results<NoContent, NotFound, ProblemHttpResult> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task SearchFutsalGrounds_ReturnsOk_WhenValid()
    {
        // Arrange
        var futsalGrounds = new List<FutsalGround>
        {
            new FutsalGround { Id = 1, Name = "Ground 1", Location = "Location 1" }
        };
        var queryable = futsalGrounds.AsQueryable();
        _repositoryMock.Setup(r => r.Query()).Returns(queryable);

        // Act
        var result = await _endpoints.SearchFutsalGrounds(_repositoryMock.Object, "Ground", null, null, null, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<List<FutsalGroundResponse>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<FutsalGroundResponse>>, ProblemHttpResult> { Result: Ok<List<FutsalGroundResponse>> ok })
        {
            ok.Value.Should().NotBeNull();
        }
    }

    [Fact]
    public async Task SearchFutsalGrounds_ReturnsProblem_WhenInvalidPage()
    {
        // Act
        var result = await _endpoints.SearchFutsalGrounds(_repositoryMock.Object, null, null, null, null, 0, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<List<FutsalGroundResponse>>, ProblemHttpResult>>();
        if (result is Results<Ok<List<FutsalGroundResponse>>, ProblemHttpResult> { Result: ProblemHttpResult problem })
        {
            problem.ProblemDetails.Detail.Should().Be("Page and pageSize must be greater than 0.");
        }
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
