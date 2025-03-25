var builder = DistributedApplication.CreateBuilder(args);

var cache = builder.AddRedis("cache");

var apiService = builder.AddProject<Projects.FutsalApi_ApiService>("apiservice");


builder.Build().Run();
