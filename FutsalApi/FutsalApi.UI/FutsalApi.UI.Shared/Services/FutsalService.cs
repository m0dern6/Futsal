using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using FutsalApi.UI.Shared.Models;

namespace FutsalApi.UI.Shared.Services
{
    public class FutsalService
    {
        private readonly HttpClient _httpClient;

        public FutsalService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<IEnumerable<FutsalGroundResponse>> SearchFutsalGrounds(string searchTerm)
        {
            return await _httpClient.GetFromJsonAsync<IEnumerable<FutsalGroundResponse>>($"api/futsalgrounds/search?searchTerm={searchTerm}");
        }

        public async Task<FutsalGroundResponse> GetFutsalGroundById(int id)
        {
            return await _httpClient.GetFromJsonAsync<FutsalGroundResponse>($"api/futsalgrounds/{id}");
        }
    }
}
