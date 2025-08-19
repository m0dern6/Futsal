using System.Security.Claims;
using FutsalApi.ApiService.Routes;
using FutsalApi.ApiService.Services;
using FutsalApi.Data.Models;
using FutsalApi.Data.DTO;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Moq;
using FluentAssertions;
using PaymentGateway;

namespace FutsalApi.Tests;

public class PaymentGatewayApiEndpointsTests
{
    private readonly Mock<IPaymentService> _paymentServiceMock;
    private readonly Mock<UserManager<User>> _userManagerMock;
    private readonly PaymentGatewayApiEndpoints _endpoints;

    public PaymentGatewayApiEndpointsTests()
    {
        _paymentServiceMock = new Mock<IPaymentService>();
        _userManagerMock = MockUserManager();
        _endpoints = new PaymentGatewayApiEndpoints();
    }


    [Fact]
    public async Task InitiateKhaltiPayment_ReturnsOk_WhenSuccess()
    {
        var user = new User { Id = "user1" };
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, user.Id) }));
        var request = new KhaltiPaymentInitiateRequest { BookingId = 1, ReturnUrl = "return", WebsiteUrl = "web" };
        var response = new KhaltiInitiateResponse { Success = true, PaymentUrl = "url", Pidx = "pidx" };
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _paymentServiceMock.Setup(s => s.InitiateKhaltiPaymentAsync(user, 1, "return", "web")).ReturnsAsync(response);

        var result = await _endpoints.InitiateKhaltiPayment(_paymentServiceMock.Object, _userManagerMock.Object, claimsPrincipal, request);

        result.Result.Should().BeOfType<Ok<KhaltiInitiateResponse>>();
        ((Ok<KhaltiInitiateResponse>)result.Result).Value.Should().BeEquivalentTo(response);
    }

    [Fact]
    public async Task InitiateKhaltiPayment_ReturnsProblem_WhenUserNotFound()
    {
        var claimsPrincipal = new ClaimsPrincipal();
        var request = new KhaltiPaymentInitiateRequest();
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync((User?)null);

        var result = await _endpoints.InitiateKhaltiPayment(_paymentServiceMock.Object, _userManagerMock.Object, claimsPrincipal, request);

        result.Result.Should().BeOfType<ProblemHttpResult>();
        ((ProblemHttpResult)result.Result).ProblemDetails.Detail.Should().Contain("User not found");
    }

    [Fact]
    public async Task InitiateKhaltiPayment_ReturnsProblem_WhenFailure()
    {
        var user = new User { Id = "user1" };
        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, user.Id) }));
        var request = new KhaltiPaymentInitiateRequest { BookingId = 1, ReturnUrl = "return", WebsiteUrl = "web" };
        var response = new KhaltiInitiateResponse { Success = false, Message = "Failed" };
        _userManagerMock.Setup(um => um.GetUserAsync(claimsPrincipal)).ReturnsAsync(user);
        _paymentServiceMock.Setup(s => s.InitiateKhaltiPaymentAsync(user, 1, "return", "web")).ReturnsAsync(response);

        var result = await _endpoints.InitiateKhaltiPayment(_paymentServiceMock.Object, _userManagerMock.Object, claimsPrincipal, request);

        result.Result.Should().BeOfType<ProblemHttpResult>();
        ((ProblemHttpResult)result.Result).ProblemDetails.Detail.Should().Contain("Failed");
    }

    [Fact]
    public async Task ProcessKhaltiCallback_ReturnsOk_WhenSuccess()
    {
        var pidx = "pidx123";
        _paymentServiceMock.Setup(s => s.ProcessKhaltiCallbackAsync(pidx)).ReturnsAsync(new Payment());

        var result = await _endpoints.ProcessKhaltiCallback(_paymentServiceMock.Object, pidx);

        result.Result.Should().BeOfType<Ok<string>>();
        ((Ok<string>)result.Result).Value.Should().Be("Payment processed successfully");
    }

    [Fact]
    public async Task ProcessKhaltiCallback_ReturnsProblem_WhenMissingPidx()
    {
        var result = await _endpoints.ProcessKhaltiCallback(_paymentServiceMock.Object, "");
        result.Result.Should().BeOfType<ProblemHttpResult>();
        ((ProblemHttpResult)result.Result).ProblemDetails.Detail.Should().Contain("PIDX is required");
    }

    [Fact]
    public async Task ProcessKhaltiCallback_ReturnsProblem_WhenFailure()
    {
        var pidx = "pidx123";
        _paymentServiceMock.Setup(s => s.ProcessKhaltiCallbackAsync(pidx)).ReturnsAsync((Payment?)null);

        var result = await _endpoints.ProcessKhaltiCallback(_paymentServiceMock.Object, pidx);

        result.Result.Should().BeOfType<ProblemHttpResult>();
        ((ProblemHttpResult)result.Result).ProblemDetails.Detail.Should().Contain("Failed to process payment");
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
