using System;

using FutsalApi.ApiService.Data;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

public class FutsalGroundRepository : GenericRepository<FutsalGround>, IFutsalGroundRepository
{
    private readonly AppDbContext _dbContext;
    public FutsalGroundRepository(AppDbContext dbContext) : base(dbContext)
    {
        _dbContext = dbContext;
    }
    public override async Task<IEnumerable<FutsalGround>> GetAllAsync(int page = 1, int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbContext.FutsalGrounds
            .OrderByDescending(g => g.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

}
