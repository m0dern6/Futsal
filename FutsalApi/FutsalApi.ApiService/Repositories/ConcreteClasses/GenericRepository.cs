using System.Linq.Expressions;

using FutsalApi.ApiService.Data;

using Microsoft.EntityFrameworkCore;

namespace FutsalApi.ApiService.Repositories;
public class GenericRepository<T> : IGenericRepository<T> where T : class
{
    private readonly AppDbContext _dbContext;
    private readonly DbSet<T> _dbSet;

    public GenericRepository(AppDbContext dbContext)
    {
        _dbContext = dbContext;
        _dbSet = _dbContext.Set<T>();
    }

    public virtual async Task<IEnumerable<T>> GetAllAsync(int page = 1, int pageSize = 10)
    {
        if (page <= 0 || pageSize <= 0)
        {
            throw new ArgumentOutOfRangeException("Page and pageSize must be greater than 0.");
        }

        return await _dbSet.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
    }

    public virtual async Task<T?> GetByIdAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.FirstOrDefaultAsync(predicate);
    }

    public virtual async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(predicate).ToListAsync();
    }

    public virtual async Task<T> CreateAsync(T entity)
    {
        _dbSet.Add(entity);
        await _dbContext.SaveChangesAsync();
        return entity;
    }

    public virtual async Task<T> UpdateAsync(Expression<Func<T, bool>> predicate, T entity)
    {
        var existingEntity = await _dbSet.FirstOrDefaultAsync(predicate);
        if (existingEntity == null)
        {
            throw new KeyNotFoundException($"Entity of type {typeof(T).Name} not found.");
        }

        _dbContext.Entry(existingEntity).CurrentValues.SetValues(entity);
        await _dbContext.SaveChangesAsync();
        return existingEntity;
    }

    public virtual async Task<bool> DeleteAsync(Expression<Func<T, bool>> predicate)
    {
        var entity = await _dbSet.FirstOrDefaultAsync(predicate);
        if (entity == null)
        {
            return false;
        }

        _dbSet.Remove(entity);
        await _dbContext.SaveChangesAsync();
        return true;
    }
    public virtual IQueryable<T> Query() // Implemented Query method
    {
        return _dbSet.AsQueryable();
    }
}
