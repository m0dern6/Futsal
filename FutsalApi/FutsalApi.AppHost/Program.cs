var builder = DistributedApplication.CreateBuilder(args);

var cache = builder.AddRedis("cache");

var db = builder.AddPostgres("db")
    .WithPgAdmin()
    .WithVolume("./pgdata", "/var/lib/postgresql/data"); // Host path first, container path second

var futsaldb = db.AddDatabase("futsaldb");

var apiService = builder.AddProject<Projects.FutsalApi_ApiService>("apiservice")
    .WithHttpEndpoint(port: 8000, name: "Http8000")
    // .WithHttpsEndpoint(port: 8001, name: "Https8001")
    .WithReference(futsaldb)
    .WaitFor(futsaldb)
    .WithReference(cache)
    .WaitFor(cache);

builder.Build().Run();
