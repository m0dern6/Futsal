using System;
using System.Linq.Expressions;

using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Repositories.Interfaces;

public interface IGroundClosureRepository : IGenericRepository<GroundClosure>
{
    Task<bool> IsGroundClosedAsync(int groundId, DateTime date, TimeSpan startTime, TimeSpan endTime);
}
