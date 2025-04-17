using System;
using System.Linq.Expressions;

using FutsalApi.ApiService.Data;
using FutsalApi.ApiService.Models;

namespace FutsalApi.ApiService.Repositories;

public interface IFutsalGroundRepository : IGenericRepository<FutsalGround>
{
    new Task<IEnumerable<FutsalGroundResponse>> GetAllAsync(int page = 1, int pageSize = 10);
    new Task<FutsalGroundResponse?> GetByIdAsync(Expression<Func<FutsalGround, bool>> predicate);

}
