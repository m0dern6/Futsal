using System.Reflection;

using FluentValidation;
using FluentValidation.AspNetCore;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories;
using FutsalApi.ApiService.Routes;

using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add service defaults & Aspire client integrations.
builder.AddServiceDefaults();

// Get connection string from appsettings.json
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// Add DbContext with PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));


builder.Services.AddAuthentication().AddBearerToken(IdentityConstants.BearerScheme);
builder.Services.AddAuthorizationBuilder();

builder.Services.AddIdentity<User, Role>()
    .AddEntityFrameworkStores<AppDbContext>()
    .AddDefaultTokenProviders();

// Add services to the container.
builder.Services.AddProblemDetails();

builder.Services.AddFluentValidationAutoValidation() // Enables automatic validation
                .AddFluentValidationClientsideAdapters(); // Enables client-side validation for MVC

builder.Services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly()); // Scans & registers all validators

builder.Services.AddScoped(typeof(IGenericrepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseExceptionHandler();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
app.MapAuthApi<User>();
app.MapFutsalGroundApi();
app.MapReviewApi();

app.MapDefaultEndpoints();

app.Run();
