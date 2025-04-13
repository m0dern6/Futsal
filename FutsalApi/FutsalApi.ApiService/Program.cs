using System.Reflection;

using FluentValidation;
using FluentValidation.AspNetCore;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Routes;
using FutsalApi.ApiService.Services;

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


builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = IdentityConstants.BearerScheme;
    options.DefaultChallengeScheme = IdentityConstants.BearerScheme;
    options.DefaultScheme = IdentityConstants.BearerScheme;
}).AddBearerToken(IdentityConstants.BearerScheme,
   options =>
   {
       options.BearerTokenExpiration = TimeSpan.FromDays(1);
       options.RefreshTokenExpiration = TimeSpan.FromDays(30);
   });
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

builder.Services.AddTransient<IEmailSender<User>, EmailSender>();

builder.Services.AddFluentValidationAutoValidation() // Enables automatic validation
                .AddFluentValidationClientsideAdapters(); // Enables client-side validation for MVC

builder.Services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly()); // Scans & registers all validators

builder.Services.AddScoped(typeof(IGenericrepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();
builder.Services.AddScoped<IBookingRepository, BookingRepository>();
builder.Services.AddScoped<IPaymentRepository, PaymentRepository>();
builder.Services.AddScoped<IPaymentService, PaymentService>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseExceptionHandler();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.MapOpenApi();
    app.MapGet("/", context =>
    {
        context.Response.Redirect("/swagger");
        return Task.CompletedTask;
    });
}

app.UseAuthentication();
app.UseAuthorization();

app.MapAuthApi<User>().WithTags("User");
app.MapFutsalGroundApi().WithTags("Futsal Grounds");
app.MapReviewApi().WithTags("Reviews");
app.MapNotificationApi().WithTags("Notifications");
app.MapBookingApi().WithTags("Bookings");
app.MapPaymentApi().WithTags("Payments");

app.MapDefaultEndpoints();

app.Run();
