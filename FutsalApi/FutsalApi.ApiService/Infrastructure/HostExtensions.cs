using System.Reflection;
using System.Threading.Tasks;

using FutsalApi.Data.DTO;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Internal;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace FutsalApi.ApiService.Extensions
{
    public static class HostExtensions
    {
        public static void EnsureDatabaseCreated<TContext>(this IHost host)
            where TContext : DbContext
        {
            using var scope = host.Services.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<TContext>();
            dbContext.Database.Migrate();
            DbSetInitializer.Initialize(dbContext);
        }
    }
}

public static class DbSetInitializer
{
    public static void Initialize<TContext>(TContext context) where TContext : DbContext
    {
        var generalSettings = new List<GeneralSetting>
        {
            new GeneralSetting { Key = "Email:SmtpServer", Value = "smtp.example.com" },
            new GeneralSetting { Key = "Email:SmtpPort", Value = "587" },
            new GeneralSetting { Key = "Email:SmtpUser", Value = "admin" },
            new GeneralSetting { Key = "Email:SmtpPassword", Value = "password" },
            new GeneralSetting { Key = "Email:FromEmail", Value = "noreply@example.com" }
        };
        if (!context.Set<GeneralSetting>().Any())
        {
            context.Set<GeneralSetting>().AddRange(generalSettings);
        }

        context.SaveChanges();

        // --- Run all SQL scripts from the Scripts folder in the data project ---
        var assembly = Assembly.Load("FutsalApi.Data");
        var resourceNames = assembly.GetManifestResourceNames()
            .Where(name => name.Contains(".Scripts.") && (name.EndsWith(".sql") || name.EndsWith(".psql")))
            .ToList();

        foreach (var resourceName in resourceNames)
        {
            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream != null)
            {
                using var reader = new StreamReader(stream);
                var sql = reader.ReadToEnd();
                if (!string.IsNullOrWhiteSpace(sql))
                {
                    context.Database.ExecuteSqlRaw(sql);
                }
            }
        }
    }
}
