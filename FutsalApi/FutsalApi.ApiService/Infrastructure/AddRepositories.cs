using System;
using System.Data;
using System.Reflection;

using Dapper;

using FutsalApi.ApiService.Repositories;

using Npgsql;

namespace FutsalApi.ApiService.Infrastructure;

// Custom type handlers for DateOnly and TimeOnly
public class DateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly value)
    {
        parameter.Value = value.ToDateTime(TimeOnly.MinValue);
        parameter.DbType = DbType.Date;
    }

    public override DateOnly Parse(object value)
    {
        return DateOnly.FromDateTime((DateTime)value);
    }
}

public class DateOnlyNullableTypeHandler : SqlMapper.TypeHandler<DateOnly?>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly? value)
    {
        if (value.HasValue)
        {
            parameter.Value = value.Value.ToDateTime(TimeOnly.MinValue);
            parameter.DbType = DbType.Date;
        }
        else
        {
            parameter.Value = DBNull.Value;
        }
    }

    public override DateOnly? Parse(object value)
    {
        if (value == null || value is DBNull)
            return null;
        return DateOnly.FromDateTime((DateTime)value);
    }
}

public class TimeOnlyTypeHandler : SqlMapper.TypeHandler<TimeOnly>
{
    public override void SetValue(IDbDataParameter parameter, TimeOnly value)
    {
        parameter.Value = value.ToTimeSpan();
        parameter.DbType = DbType.Time;
    }

    public override TimeOnly Parse(object value)
    {
        return TimeOnly.FromTimeSpan((TimeSpan)value);
    }
}

public class TimeOnlyNullableTypeHandler : SqlMapper.TypeHandler<TimeOnly?>
{
    public override void SetValue(IDbDataParameter parameter, TimeOnly? value)
    {
        if (value.HasValue)
        {
            parameter.Value = value.Value.ToTimeSpan();
            parameter.DbType = DbType.Time;
        }
        else
        {
            parameter.Value = DBNull.Value;
        }
    }

    public override TimeOnly? Parse(object value)
    {
        if (value == null || value is DBNull)
            return null;
        return TimeOnly.FromTimeSpan((TimeSpan)value);
    }
}

public static class RepositoryExtension
{
    public static IServiceCollection AddRepositories(this IServiceCollection services, Assembly assembly, IConfiguration configuration)
    {
        // Register all repositories in the assembly that inherits from GenericRepository
        var repositoryTypes = assembly.GetTypes()
            .Where(t => t.IsClass && !t.IsAbstract && t.BaseType != null && t.BaseType.IsGenericType && t.BaseType.GetGenericTypeDefinition() == typeof(GenericRepository<>));

        // Register each repository type with its corresponding interface
        foreach (var repositoryType in repositoryTypes)
        {
            var interfaceType = repositoryType.GetInterfaces().FirstOrDefault(i => !i.IsGenericType);
            if (interfaceType != null)
            {
                // Console.WriteLine($"Registering {interfaceType.Name} with {repositoryType.Name}");
                services.AddScoped(interfaceType, repositoryType);
            }
        }

        services.AddScoped<IDbConnection>(sp => new NpgsqlConnection(sp.GetRequiredService<IConfiguration>().GetConnectionString("futsaldb")));

        // Configure Dapper type handlers for proper PostgreSQL date/time handling
        SqlMapper.AddTypeHandler(new DateOnlyTypeHandler());
        SqlMapper.AddTypeHandler(new DateOnlyNullableTypeHandler());
        SqlMapper.AddTypeHandler(new TimeOnlyTypeHandler());
        SqlMapper.AddTypeHandler(new TimeOnlyNullableTypeHandler());

        return services;
    }

}
