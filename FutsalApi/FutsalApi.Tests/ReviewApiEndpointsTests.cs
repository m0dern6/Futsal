using System.Linq.Expressions;
using System.Security.Claims;
using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Moq;
using FluentAssertions;
using FutsalApi.Data.DTO;

namespace FutsalApi.Tests;

public class ReviewApiEndpointsTests
{
    private readonly Mock<IReviewRepository> _repositoryMock;
    private readonly Mock<UserManager<User>> _userManagerMock;
    private readonly Mock<IFutsalGroundRepository> _groundRepositoryMock;
    private readonly ReviewApiEndpoints _endpoints;

    public ReviewApiEndpointsTests()
    {
        _repositoryMock = new Mock<IReviewRepository>();
        _groundRepositoryMock = new Mock<IFutsalGroundRepository>();
        _userManagerMock = MockUserManager();
        _endpoints = new ReviewApiEndpoints();
    }

    [Fact]
    public async Task GetAllReviews_ReturnsOk_WhenValid()
    {
        // Arrange
        var reviews = new List<ReviewResponse>
        {
            new ReviewResponse { Id = 1, UserId = "user1", GroundId = 1, Rating = 5, Comment = "Great!" }
        };
        _repositoryMock.Setup(r => r.GetAllAsync(1, 10)).ReturnsAsync(reviews);

        // Act
        var result = await _endpoints.GetAllReviews(_repositoryMock.Object, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult>>();
        if (result is Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult> { Result: Ok<IEnumerable<ReviewResponse>> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(reviews);
        }
    }

    [Fact]
    public async Task GetAllReviews_ReturnsProblem_WhenInvalidPage()
    {
        // Act
        var result = await _endpoints.GetAllReviews(_repositoryMock.Object, 0, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult>>();
        if (result is Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Page and pageSize must be greater than 0.");
        }
    }

    [Fact]
    public async Task GetReviewsByGroundId_ReturnsOk_WhenValid()
    {
        // Arrange
        var reviews = new List<ReviewResponse>
        {
            new ReviewResponse { Id = 1, UserId = "user1", GroundId = 1, Rating = 5, Comment = "Great!" }
        };
        _repositoryMock.Setup(r => r.GetReviewsByGroundIdAsync(1, 1, 10)).ReturnsAsync(reviews);

        // Act
        var result = await _endpoints.GetReviewsByGroundId(_repositoryMock.Object, 1, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult>>();
        if (result is Results<Ok<IEnumerable<ReviewResponse>>, ProblemHttpResult> { Result: Ok<IEnumerable<ReviewResponse>> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(reviews);
        }
    }

    [Fact]
    public async Task GetReviewById_ReturnsOk_WhenFound()
    {
        // Arrange
        var review = new ReviewResponse { Id = 1, UserId = "user1", GroundId = 1, Rating = 5, Comment = "Great!" };
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<Review, bool>>>())).ReturnsAsync(review);

        // Act
        var result = await _endpoints.GetReviewById(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<ReviewResponse>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<ReviewResponse>, NotFound, ProblemHttpResult> { Result: Ok<ReviewResponse> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(review);
        }
    }

    [Fact]
    public async Task GetReviewById_ReturnsNotFound_WhenNotFound()
    {
        // Arrange
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<Review, bool>>>())).ReturnsAsync((ReviewResponse?)null);

        // Act
        var result = await _endpoints.GetReviewById(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<ReviewResponse>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<ReviewResponse>, NotFound, ProblemHttpResult> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task CreateReview_ReturnsOk_WhenCreated()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var reviewRequest = new ReviewRequest { GroundId = 1, Rating = 5, Comment = "Great!" };
        var review = new Review { Id = 1, UserId = "user1", GroundId = 1, Rating = 5, Comment = "Great!" };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.CreateAsync(It.IsAny<Review>())).ReturnsAsync(review);
        // Act
        var result = await _endpoints.CreateReview(_repositoryMock.Object, _groundRepositoryMock.Object, _userManagerMock.Object, claimsPrincipal, reviewRequest);

        // Assert
        result.Should().BeOfType<Results<Ok<Review>, ProblemHttpResult>>();
        if (result is Results<Ok<Review>, ProblemHttpResult> { Result: Ok<Review> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(review);
        }
    }

    [Fact]
    public async Task UpdateReview_ReturnsOk_WhenUpdated()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var reviewRequest = new ReviewRequest { GroundId = 1, Rating = 4, Comment = "Good!" };
        var existingReview = new ReviewResponse { Id = 1, UserId = "user1", GroundId = 1, Rating = 5, Comment = "Great!" };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<Review, bool>>>())).ReturnsAsync(existingReview);
        _repositoryMock.Setup(r => r.UpdateAsync(It.IsAny<Expression<Func<Review, bool>>>(), It.IsAny<Review>())).ReturnsAsync(new Review());

        // Act
        var result = await _endpoints.UpdateReview(_repositoryMock.Object, _groundRepositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, reviewRequest);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, NotFound, ProblemHttpResult>>();
        if (result is Results<Ok<string>, NotFound, ProblemHttpResult> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("Review updated successfully.");
        }
    }

    [Fact]
    public async Task DeleteReview_ReturnsNoContent_WhenDeleted()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };
        var existingReview = new ReviewResponse { Id = 1, UserId = "user1", GroundId = 1, Rating = 5, Comment = "Great!" };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetByIdAsync(It.IsAny<Expression<Func<Review, bool>>>())).ReturnsAsync(existingReview);
        _repositoryMock.Setup(r => r.DeleteReviewByUserAsync(1, user.Id)).ReturnsAsync(true);

        // Act
        var result = await _endpoints.DeleteReview(_repositoryMock.Object, _groundRepositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1);

        // Assert
        result.Should().BeOfType<Results<NoContent, NotFound, ProblemHttpResult>>();
        if (result is Results<NoContent, NotFound, ProblemHttpResult> { Result: NoContent noContentResult })
        {
            noContentResult.Should().BeOfType<NoContent>();
        }
    }

    private static Mock<UserManager<User>> MockUserManager()
    {
        var store = new Mock<IUserStore<User>>();
        return new Mock<UserManager<User>>(store.Object, null, null, null, null, null, null, null, null);
    }
}
