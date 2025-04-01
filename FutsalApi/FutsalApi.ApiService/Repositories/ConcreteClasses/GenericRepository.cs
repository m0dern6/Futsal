using System.Linq.Expressions;
using FutsalApi.ApiService.Data;
using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;

/// <summary>
/// Generic implementation of IGenericrepository for any model.
/// </summary>
/// <typeparam name="T">The type of the entity.</typeparam>
public class GenericRepository<T> : IGenericrepository<T> where T : class
{
    private readonly AppDbContext _dbContext;
    private readonly DbSet<T> _dbSet;

    public GenericRepository(AppDbContext dbContext)
    {
        _dbContext = dbContext;
        _dbSet = _dbContext.Set<T>();
    }

    /// <summary>
    /// Retrieves all records of type T from the database.
    /// </summary>
    public async Task<IEnumerable<T>> GetAllAsync(int page = 1, int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbSet.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
    }


    /// <summary>
    /// Retrieves a record of type T by its ID.
    /// </summary>
    public async Task<T?> GetByIdAsync(int id)
    {
        return await _dbSet.FindAsync(id);
    }

    /// <summary>
    /// Finds records of type T that match the specified predicate.
    /// </summary>
    public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(predicate).ToListAsync();
    }

    /// <summary>
    /// Creates a new record of type T in the database.
    /// </summary>
    public async Task<T> CreateAsync(T entity)
    {
        _dbSet.Add(entity);
        await _dbContext.SaveChangesAsync();
        return entity;
    }

    /// <summary>
    /// Updates an existing record of type T in the database.
    /// </summary>
    public async Task<T> UpdateAsync(int id, T entity)
    {
        var existingEntity = await _dbSet.FindAsync(id);
        if (existingEntity == null)
        {
            throw new KeyNotFoundException($"Entity of type {typeof(T).Name} with ID {id} not found.");
        }

        _dbContext.Entry(existingEntity).CurrentValues.SetValues(entity);
        await _dbContext.SaveChangesAsync();
        return existingEntity;
    }

    /// <summary>
    /// Deletes a record of type T by its ID.
    /// </summary>
    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _dbSet.FindAsync(id);
        if (entity == null)
        {
            return false;
        }

        _dbSet.Remove(entity);
        await _dbContext.SaveChangesAsync();
        return true;
    }
}
