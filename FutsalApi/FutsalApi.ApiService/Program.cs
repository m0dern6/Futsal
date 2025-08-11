using FluentValidation;
using FluentValidation.AspNetCore;

using FutsalApi.ApiService.Extensions;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Services;
using FutsalApi.ApiService.Services.PaymentGateway;
using FutsalApi.Auth.Infrastructure;
using FutsalApi.Auth.Services;
using FutsalApi.Data.DTO;

using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using FutsalApi.ApiService.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add service defaults & Aspire client integrations.
builder.AddServiceDefaults();

builder.AddRedisOutputCache("cache");

builder.AddNpgsqlDbContext<AppDbContext>("futsaldb");

builder.Services.AddAuthConfig(builder.Configuration);

// Add CORS and allow all
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Add services to the container.
builder.Services.AddProblemDetails();

//Add Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
        {
            options
            .AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                In = ParameterLocation.Header,
                Description = "Please enter Bearer token",
                Name = "Authorization",
                Type = SecuritySchemeType.Http,
                BearerFormat = "IdentityAuth",
                Scheme = "bearer"
            });
            options
            .AddSecurityRequirement(new OpenApiSecurityRequirement
            {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] { }
        }
            });
        });

builder.Services.AddLogging(builder => builder.AddConsole());

builder.Services.AddEndpoints(typeof(Program).Assembly); // Register all endpoints in the assembly

builder.Services.AddFluentValidationAutoValidation() // Enables automatic validation
                .AddFluentValidationClientsideAdapters(); // Enables client-side validation for MVC

builder.Services.AddValidatorsFromAssembly(typeof(Program).Assembly); // Scans & registers all validators

builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
builder.Services.AddRepositories(typeof(Program).Assembly, builder.Configuration); // Registers all repositories in the assembly

builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IGeneralSettingsService, GeneralSettingsService>();
builder.Services.AddScoped<ISmtpService, SmtpService>();

// Payment Gateway Services
builder.Services.Configure<ESewaConfig>(builder.Configuration.GetSection("ESewa"));
builder.Services.Configure<KhaltiConfig>(builder.Configuration.GetSection("Khalti"));
builder.Services.AddHttpClient<IESewaService, ESewaService>();
builder.Services.AddHttpClient<IKhaltiService, KhaltiService>();

builder.Services.AddScoped<ImageService>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

app.UseOutputCache();
// Configure the HTTP request pipeline.
app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseStaticFiles();

// Enable CORS for all origins, headers, and methods
app.UseCors();

if (app.Environment.IsDevelopment())
{
}
app.UseSwagger();
app.UseSwaggerUI();
app.MapOpenApi();
app.MapGet("/", context =>
{
    context.Response.Redirect("/swagger");
    return Task.CompletedTask;
});

app.UseAuthConfig(app);
app.MapEndpoints(); // Maps all endpoints registered in the assembly

app.MapDefaultEndpoints();
app.EnsureDatabaseCreated<AppDbContext>();

app.Run();

//To create a migration use the following command:
// dotnet ef migrations add InitialCreate --project FutsalApi.Data/FutsalApi.Data.csproj --startup-project FutsalApi.ApiService/FutsalApi.ApiService.csproj --context AppDbContext
