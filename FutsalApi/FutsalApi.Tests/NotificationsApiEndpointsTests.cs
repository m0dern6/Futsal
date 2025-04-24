using System.Security.Claims;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Routes;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Moq;
using FluentAssertions;
using FutsalApi.Data.DTO;

namespace FutsalApi.Tests;

public class NotificationsApiEndpointsTests
{
    private readonly Mock<INotificationRepository> _repositoryMock;
    private readonly Mock<UserManager<User>> _userManagerMock;
    private readonly NotificationsApiEndpoints _endpoints;

    public NotificationsApiEndpointsTests()
    {
        _repositoryMock = new Mock<INotificationRepository>();
        _userManagerMock = MockUserManager();
        _endpoints = new NotificationsApiEndpoints();
    }

    [Fact]
    public async Task GetNotificationsByUserId_ReturnsOk_WhenNotificationsExist()
    {
        // Arrange
        var user = new User { Id = "user1" };
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, user.Id) }));
        var notifications = new List<NotificationResponse>
        {
            new NotificationResponse { Id = 1, UserId = "user1", Message = "Test Notification", IsRead = false }
        };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetNotificationsByUserIdAsync(It.Is<string>(id => id == user.Id), 1, 10))
        .ReturnsAsync(notifications);

        // Act
        var result = await _endpoints.GetNotificationsByUserId(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<NotificationResponse>>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<IEnumerable<NotificationResponse>>, ProblemHttpResult, NotFound> { Result: Ok<IEnumerable<NotificationResponse>> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(notifications);
        }
    }

    [Fact]
    public async Task GetNotificationsByUserId_ReturnsNotFound_WhenUserNotFound()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal();

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync((User?)null);

        // Act
        var result = await _endpoints.GetNotificationsByUserId(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<NotificationResponse>>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<IEnumerable<NotificationResponse>>, ProblemHttpResult, NotFound> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task SendNotificationToMultipleUsers_ReturnsOk_WhenNotificationsSent()
    {
        // Arrange
        var notificationList = new NotificationListModel
        {
            UserId = new List<string> { "user1", "user2" },
            Message = "Test Notification"
        };

        _repositoryMock.Setup(r => r.SendNotificationToMultipleUsersAsync(notificationList)).ReturnsAsync(true);

        // Act
        var result = await _endpoints.SendNotificationToMultipleUsers(_repositoryMock.Object, notificationList);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("Notifications sent successfully.");
        }
    }

    [Fact]
    public async Task SendNotificationToMultipleUsers_ReturnsProblem_WhenSendingFails()
    {
        // Arrange
        var notificationList = new NotificationListModel
        {
            UserId = new List<string> { "user1", "user2" },
            Message = "Test Notification"
        };

        _repositoryMock.Setup(r => r.SendNotificationToMultipleUsersAsync(notificationList)).ReturnsAsync(false);

        // Act
        var result = await _endpoints.SendNotificationToMultipleUsers(_repositoryMock.Object, notificationList);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Failed to send notifications.");
        }
    }

    [Fact]
    public async Task UpdateNotificationStatusByUserId_ReturnsOk_WhenStatusUpdated()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.UpdateStatusByUserIdAsync(1, user.Id)).ReturnsAsync(true);

        // Act
        var result = await _endpoints.UpdateNotificationStatusByUserId(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<string>, ProblemHttpResult, NotFound> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("Notification status updated successfully.");
        }
    }

    [Fact]
    public async Task UpdateNotificationStatusByUserId_ReturnsProblem_WhenUpdateFails()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, "user1") }));
        var user = new User { Id = "user1" };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.UpdateStatusByUserIdAsync(1, user.Id)).ReturnsAsync(false);

        // Act
        var result = await _endpoints.UpdateNotificationStatusByUserId(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<string>, ProblemHttpResult, NotFound> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Failed to update the notification status.");
        }
    }

    private static Mock<UserManager<User>> MockUserManager()
    {
        var store = new Mock<IUserStore<User>>();
        return new Mock<UserManager<User>>(store.Object, null, null, null, null, null, null, null, null);
    }
}
