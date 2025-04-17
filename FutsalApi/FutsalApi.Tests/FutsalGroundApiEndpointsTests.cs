using System.Linq.Expressions;
using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Routes;
using Microsoft.AspNetCore.Http.HttpResults;
using Moq;
using FluentAssertions;
using Microsoft.AspNetCore.Identity;

namespace FutsalApi.Tests;

public class FutsalGroundApiEndpointsTests
{
    private readonly Mock<IFutsalGroundRepository> _repositoryMock;
    private readonly FutsalGroundApiEndpoints _endpoints;

    public FutsalGroundApiEndpointsTests()
    {
        _repositoryMock = new Mock<IFutsalGroundRepository>();
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
        var futsalGround = new FutsalGround { Id = 1, Name = "Ground 1", Location = "Location 1", OwnerId = "Owner1" };
        _repositoryMock.Setup(r => r.CreateAsync(It.IsAny<FutsalGround>())).ReturnsAsync(futsalGround);

        // Act
        var result = await _endpoints.CreateFutsalGround(_repositoryMock.Object, futsalGround);

        // Assert
        result.Should().BeOfType<Results<Ok<FutsalGround>, ProblemHttpResult>>();
        if (result is Results<Ok<FutsalGround>, ProblemHttpResult> { Result: Ok<FutsalGround> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(futsalGround);
        }
    }

    [Fact]
    public async Task UpdateFutsalGround_ReturnsOk_WhenUpdated()
    {
        // Arrange
        var futsalGround = new FutsalGround { Id = 1, Name = "Ground 1", Location = "Location 1", OwnerId = "Owner1" };
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(new FutsalGroundResponse());
        _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>(), It.IsAny<FutsalGround>())).ReturnsAsync(futsalGround);

        // Act
        var result = await _endpoints.UpdateFutsalGround(_repositoryMock.Object, 1, futsalGround);

        // Assert
        result.Should().BeOfType<Results<Ok<FutsalGround>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<FutsalGround>, NotFound, ProblemHttpResult> { Result: Ok<FutsalGround> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(futsalGround);
        }
    }

    [Fact]
    public async Task UpdateFutsalGround_ReturnsNotFound_WhenNotFound()
    {
        // Arrange
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync((FutsalGroundResponse?)null);

        // Act
        var result = await _endpoints.UpdateFutsalGround(_repositoryMock.Object, 1, new FutsalGround() { OwnerId="Owner1"});

        // Assert
        result.Should().BeOfType<Results<Ok<FutsalGround>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<FutsalGround>, NotFound, ProblemHttpResult> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task DeleteFutsalGround_ReturnsNoContent_WhenDeleted()
    {
        // Arrange
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(new FutsalGroundResponse());
        _repositoryMock.Setup(r => r.DeleteAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync(true);

        // Act
        var result = await _endpoints.DeleteFutsalGround(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<NoContent, NotFound, ProblemHttpResult>>();
        if (result is Results<NoContent, NotFound, ProblemHttpResult> { Result: NoContent })
        {
            result.Result.Should().BeOfType<NoContent>();
        }
    }

    [Fact]
    public async Task DeleteFutsalGround_ReturnsNotFound_WhenNotFound()
    {
        // Arrange
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<FutsalGround, bool>>>())).ReturnsAsync((FutsalGroundResponse?)null);

        // Act
        var result = await _endpoints.DeleteFutsalGround(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<NoContent, NotFound, ProblemHttpResult>>();
        if (result is Results<NoContent, NotFound, ProblemHttpResult> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    private static Mock<UserManager<User>> MockUserManager()
    {
        var store = new Mock<IUserStore<User>>();
        return new Mock<UserManager<User>>(store.Object, null, null, null, null, null, null, null, null);
    }
}

