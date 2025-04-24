using System.Linq.Expressions;
using System.Security.Claims;
using FutsalApi.ApiService.Models;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Routes;
using FutsalApi.ApiService.Services;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Moq;
using FluentAssertions;
using FutsalApi.Data.DTO;

namespace FutsalApi.Tests;

public class PaymentApiEndpointsTests
{
    private readonly Mock<IPaymentRepository> _repositoryMock;
    private readonly Mock<IPaymentService> _paymentServiceMock;
    private readonly Mock<UserManager<User>> _userManagerMock;
    private readonly PaymentApiEndpoints _endpoints;

    public PaymentApiEndpointsTests()
    {
        _repositoryMock = new Mock<IPaymentRepository>();
        _paymentServiceMock = new Mock<IPaymentService>();
        _userManagerMock = MockUserManager();
        _endpoints = new PaymentApiEndpoints();
    }

    [Fact]
    public async Task GetPaymentsByUserId_ReturnsOk_WhenPaymentsExist()
    {
        // Arrange
        var user = new User { Id = "user1" };
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new Claim[] { new Claim(ClaimTypes.NameIdentifier, user.Id) }));
        var payments = new List<PaymentResponse>
        {
            new PaymentResponse { Id = 1, BookingId = 1, AmountPaid = 100, Method = PaymentMethod.Cash, Status = PaymentStatus.Completed }
        };

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _repositoryMock.Setup(r => r.GetPaymentsByUserIdAsync(user.Id, 1, 10)).ReturnsAsync(payments);

        // Act
        var result = await _endpoints.GetPaymentsByUserId(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<PaymentResponse>>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<IEnumerable<PaymentResponse>>, ProblemHttpResult, NotFound> { Result: Ok<IEnumerable<PaymentResponse>> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(payments);
        }
    }

    [Fact]
    public async Task GetPaymentsByUserId_ReturnsNotFound_WhenUserNotFound()
    {
        // Arrange
        var claimsPrincipal = new ClaimsPrincipal();

        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync((User?)null);

        // Act
        var result = await _endpoints.GetPaymentsByUserId(_repositoryMock.Object, _userManagerMock.Object, claimsPrincipal, 1, 10);

        // Assert
        result.Should().BeOfType<Results<Ok<IEnumerable<PaymentResponse>>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<IEnumerable<PaymentResponse>>, ProblemHttpResult, NotFound> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task GetPaymentByBookingId_ReturnsOk_WhenPaymentExists()
    {
        // Arrange
        var payment = new PaymentResponse
        {
            Id = 1,
            BookingId = 1,
            AmountPaid = 100,
            Method = PaymentMethod.Cash,
            Status = PaymentStatus.Completed
        };

        _repositoryMock.Setup(r => r.GetPaymentByBookingIdAsync(It.IsAny<Expression<Func<Payment, bool>>>())).ReturnsAsync(payment);

        // Act
        var result = await _endpoints.GetPaymentByBookingId(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<PaymentResponse>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<PaymentResponse>, ProblemHttpResult, NotFound> { Result: Ok<PaymentResponse> okResult })
        {
            okResult.Value.Should().BeEquivalentTo(payment);
        }
    }

    [Fact]
    public async Task GetPaymentByBookingId_ReturnsNotFound_WhenPaymentDoesNotExist()
    {
        // Arrange
        _repositoryMock.Setup(r => r.GetPaymentByBookingIdAsync(It.IsAny<Expression<Func<Payment, bool>>>())).ReturnsAsync((PaymentResponse?)null);

        // Act
        var result = await _endpoints.GetPaymentByBookingId(_repositoryMock.Object, 1);

        // Assert
        result.Should().BeOfType<Results<Ok<PaymentResponse>, ProblemHttpResult, NotFound>>();
        if (result is Results<Ok<PaymentResponse>, ProblemHttpResult, NotFound> { Result: NotFound })
        {
            result.Result.Should().BeOfType<NotFound>();
        }
    }

    [Fact]
    public async Task CreatePayment_ReturnsOk_WhenPaymentIsCreated()
    {
        // Arrange
        var paymentRequest = new PaymentRequest
        {
            BookingId = 1,
            AmountPaid = 100,
            Method = PaymentMethod.Cash
        };
        var payment = new Payment
        {
            Id = 1,
            BookingId = 1,
            AmountPaid = 100,
            Method = PaymentMethod.Cash,
            Status = PaymentStatus.Completed
        };

        _repositoryMock.Setup(r => r.CreateAsync(It.IsAny<Payment>())).ReturnsAsync(payment);

        // Act
        var result = await _endpoints.CreatePayment(_repositoryMock.Object, _paymentServiceMock.Object, paymentRequest);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: Ok<string> okResult })
        {
            okResult.Value.Should().Be("Payment created successfully.");
        }
    }

    [Fact]
    public async Task CreatePayment_ReturnsProblem_WhenOnlinePaymentFails()
    {
        // Arrange
        var paymentRequest = new PaymentRequest
        {
            BookingId = 1,
            AmountPaid = 100,
            Method = PaymentMethod.Online
        };

        _paymentServiceMock.Setup(ps => ps.OnlinePaymentAsync(It.IsAny<Payment>())).ReturnsAsync((Payment?)null);

        // Act
        var result = await _endpoints.CreatePayment(_repositoryMock.Object, _paymentServiceMock.Object, paymentRequest);

        // Assert
        result.Should().BeOfType<Results<Ok<string>, ProblemHttpResult>>();
        if (result is Results<Ok<string>, ProblemHttpResult> { Result: ProblemHttpResult problemResult })
        {
            problemResult.ProblemDetails.Detail.Should().Be("Payment failed.");
        }
    }

    private static Mock<UserManager<User>> MockUserManager()
    {
        var store = new Mock<IUserStore<User>>();
        return new Mock<UserManager<User>>(store.Object, null, null, null, null, null, null, null, null);
    }
}
