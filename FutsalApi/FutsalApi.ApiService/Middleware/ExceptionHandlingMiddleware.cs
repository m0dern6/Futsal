using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace FutsalApi.ApiService.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext httpContext)
    {
        try
        {
            await _next(httpContext);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred.");
            await HandleExceptionAsync(httpContext, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/problem+json";
        context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

        var problemDetails = new ProblemDetails();
        problemDetails.Instance = context.Request.Path;
        problemDetails.Title = "An error occurred while processing your request.";
        problemDetails.Status = context.Response.StatusCode;
        problemDetails.Extensions.Add("traceId", context.TraceIdentifier);


        // In development, you might want to include more details
        // if (context.RequestServices.GetRequiredService<IWebHostEnvironment>().IsDevelopment())
        // {
        //     problemDetails.Detail = exception.Message;
        //     problemDetails.Extensions.Add("stackTrace", exception.StackTrace);
        // }

        await context.Response.WriteAsync(JsonSerializer.Serialize(problemDetails));
    }
}
