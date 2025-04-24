using System;

using Microsoft.AspNetCore.Routing;

namespace FutsalApi.Auth.Infrastructure;

public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}
