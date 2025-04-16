using System.Linq.Expressions;

namespace FutsalApi.ApiService.Repositories;

public interface IGenericRepository<T> where T : class
{
    Task<IEnumerable<T>> GetAllAsync(int page = 1, int pageSize = 10);
    Task<T?> GetByIdAsync(Expression<Func<T, bool>> predicate);
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T> CreateAsync(T entity);
    Task<T> UpdateAsync(Expression<Func<T, bool>> predicate, T entity);
    Task<bool> DeleteAsync(Expression<Func<T, bool>> predicate);
}