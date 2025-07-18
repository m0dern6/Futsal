using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Internal;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Threading.Tasks;

namespace FutsalApi.ApiService.Extensions
{
    public static class HostExtensions
    {
        public static  void EnsureDatabaseCreated<TContext>(this IHost host)
            where TContext : DbContext
        {
            using var scope = host.Services.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<TContext>();
             dbContext.Database.EnsureCreatedAsync();
        }
    }
}
