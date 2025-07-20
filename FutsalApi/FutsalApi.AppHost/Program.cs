var builder = DistributedApplication.CreateBuilder(args);

var cache = builder.AddRedis("cache");

var db = builder.AddPostgres("db")
    .WithPgAdmin(pgAdmin => pgAdmin.WithHostPort(5050)) // Example: Use port 5050
    .WithVolume("./pgdata", "/var/lib/postgresql/data")
    .WithEnvironment("POSTGRES_DB", "futsaldb");

var futsaldb = db.AddDatabase("futsaldb");

var apiService = builder.AddProject<Projects.FutsalApi_ApiService>("apiservice")
   .WithExternalHttpEndpoints()
    .WithReference(futsaldb)
    .WaitFor(db)
    .WithReference(cache)
    .WaitFor(cache);

builder.Build().Run();
