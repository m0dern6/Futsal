using System.Reflection;

using FluentValidation;
using FluentValidation.AspNetCore;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Infrastructure;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Routes;
using FutsalApi.ApiService.Services;

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add service defaults & Aspire client integrations.
builder.AddServiceDefaults();

// Get connection string from appsettings.json
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// Add DbContext with PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

builder.Services.AddScoped<IGeneralSettingsService, GeneralSettingsService>();


builder.Services.AddAuthentication().AddBearerToken(IdentityConstants.BearerScheme,
   options =>
   {
       options.BearerTokenExpiration = TimeSpan.FromDays(1);
       options.RefreshTokenExpiration = TimeSpan.FromDays(30);
   })
   .AddGoogleAuthentication();
builder.Services.AddAuthorization(options =>
{
    options.DefaultPolicy = new AuthorizationPolicyBuilder(IdentityConstants.BearerScheme)
        .RequireAuthenticatedUser()
        .Build();
});
builder.Services.AddIdentity<User, Role>()
    .AddEntityFrameworkStores<AppDbContext>()
    .AddDefaultTokenProviders();

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

builder.Services.AddTransient<IEmailSender<User>, EmailSender>();

builder.Services.AddFluentValidationAutoValidation() // Enables automatic validation
                .AddFluentValidationClientsideAdapters(); // Enables client-side validation for MVC

builder.Services.AddValidatorsFromAssembly(typeof(Program).Assembly); // Scans & registers all validators

builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
builder.Services.AddRepositories(typeof(Program).Assembly); // Registers all repositories in the assembly
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<ISmtpService, SmtpService>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();


// Configure the HTTP request pipeline.
app.UseExceptionHandler();

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

app.UseAuthentication();
app.UseAuthorization();

app.MapEndpoints(); // Maps all endpoints registered in the assembly

app.MapDefaultEndpoints();

app.Run();
