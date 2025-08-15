using System;

using Microsoft.AspNetCore.Routing;

namespace FutsalApi.ApiService.Infrastructure;

public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}
