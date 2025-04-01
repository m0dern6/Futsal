using System.Linq.Expressions;

namespace FutsalApi.ApiService.Repositories;

public interface IGenericrepository<T> where T : class
{
    Task<IEnumerable<T>> GetAllAsync(int page = 1, int pageSize = 10);
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T> CreateAsync(T entity);
    Task<T> UpdateAsync(int id, T entity);
    Task<bool> DeleteAsync(int id);
}