using System;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Repositories.Interfaces;

public interface IGroundClosureRepository : IGenericRepository<GroundClosure>
{
    Task<bool> IsGroundClosedAsync(int groundId, DateTime date, TimeSpan startTime, TimeSpan endTime);
}
