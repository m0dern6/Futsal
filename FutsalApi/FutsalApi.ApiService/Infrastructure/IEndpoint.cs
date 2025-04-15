using System;

namespace FutsalApi.ApiService.Infrastructure;

public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}
