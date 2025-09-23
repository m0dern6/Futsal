using System;
using System.Data;
using Dapper;
using FutsalApi.Data.DTO;
using FutsalApi.ApiService.Repositories.Interfaces;

namespace FutsalApi.ApiService.Repositories.ConcreteClasses;

public class GroundClosureRepository : GenericRepository<GroundClosure>, IGroundClosureRepository
{
    private readonly AppDbContext _dbContext;
    private readonly IDbConnection _dbConnection;

    public GroundClosureRepository(AppDbContext dbContext, IDbConnection dbConnection) : base(dbContext)
    {
        _dbContext = dbContext;
        _dbConnection = dbConnection;
    }

    public async Task<bool> IsGroundClosedAsync(int groundId, DateTime date, TimeSpan startTime, TimeSpan endTime)
    {
        var parameters = new
        {
            p_ground_id = groundId,
            p_date = DateOnly.FromDateTime(date.Date),
            p_start_time = TimeOnly.FromTimeSpan(startTime),
            p_end_time = TimeOnly.FromTimeSpan(endTime)
        };
        return await _dbConnection.ExecuteScalarAsync<bool>(
            "SELECT is_ground_closed(@p_ground_id, @p_date, @p_start_time, @p_end_time)",
            parameters,
            commandType: CommandType.Text);
    }
}
