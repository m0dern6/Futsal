using System;
using FutsalApi.ApiService.Data;

namespace FutsalApi.ApiService.Repositories;

public interface IFutsalGroundRepository
{
    Task<IEnumerable<FutsalGround>> GetAllAsync();
    Task<FutsalGround?> GetByIdAsync(int id);
    Task<FutsalGround> CreateAsync(FutsalGround futsalGround);
    Task<FutsalGround> UpdateAsync(int id, FutsalGround futsalGround);
    Task<bool> DeleteAsync(int id);
}
