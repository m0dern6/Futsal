var builder = DistributedApplication.CreateBuilder(args);

var cache = builder.AddRedis("cache");

var db = builder.AddPostgres("db").WithPgAdmin();

var futsaldb = db.AddDatabase("futsaldb");

var apiService = builder.AddProject<Projects.FutsalApi_ApiService>("apiservice")
    .WithHttpEndpoint(port:5000,name:"Http5000")
    .WithHttpsEndpoint(port:5001,name:"Https5001")
    .WithReference(db)
    .WithReference(cache)
    .WaitFor(cache);


builder.Build().Run();
