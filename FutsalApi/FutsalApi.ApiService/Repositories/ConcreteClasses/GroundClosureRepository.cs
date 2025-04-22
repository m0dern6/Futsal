using System;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Repositories.Interfaces;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories.ConcreteClasses;

public class GroundClosureRepository : GenericRepository<GroundClosure>, IGroundClosureRepository
{
    private readonly AppDbContext _dbContext;

    public GroundClosureRepository(AppDbContext dbContext) : base(dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<bool> IsGroundClosedAsync(int groundId, DateTime date, TimeSpan startTime, TimeSpan endTime)
    {
        return await _dbContext.GroundClosures
            .AnyAsync(gc => gc.GroundId == groundId &&
                            gc.StartDate.Date <= date.Date &&
                            gc.EndDate.Date >= date.Date &&
                            ((gc.StartDate.TimeOfDay <= startTime && gc.EndDate.TimeOfDay >= startTime) ||
                             (gc.StartDate.TimeOfDay <= endTime && gc.EndDate.TimeOfDay >= endTime) ||
                             (gc.StartDate.TimeOfDay >= startTime && gc.EndDate.TimeOfDay <= endTime)));
    }

}
