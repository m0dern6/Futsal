using System.Text;
using System.Text.Json;
using FutsalApi.ApiService.Models.PaymentGateway;
using Microsoft.Extensions.Options;

namespace FutsalApi.ApiService.Services.PaymentGateway;

public class KhaltiConfig
{
    public string PublicKey { get; set; } = string.Empty;
    public string SecretKey { get; set; } = string.Empty;
    public string BaseUrl { get; set; } = "https://a.khalti.com"; // Sandbox URL
    public string ProductionBaseUrl { get; set; } = "https://khalti.com";
    public bool IsProduction { get; set; } = false;
}

public interface IKhaltiService
{
    Task<KhaltiInitiateResponse> InitiatePaymentAsync(KhaltiInitiateRequest request);
    Task<KhaltiLookupResponse> LookupPaymentAsync(KhaltiLookupRequest request);
    bool VerifyWebhookSignature(string payload, string signature);
}

public class KhaltiService : IKhaltiService
{
    private readonly HttpClient _httpClient;
    private readonly KhaltiConfig _config;
    private readonly ILogger<KhaltiService> _logger;

    public KhaltiService(HttpClient httpClient, IOptions<KhaltiConfig> config, ILogger<KhaltiService> logger)
    {
        _httpClient = httpClient;
        _config = config.Value;
        _logger = logger;
        
        // Set up HttpClient with authorization header
        _httpClient.DefaultRequestHeaders.Clear();
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"key {_config.SecretKey}");
    }

    public async Task<KhaltiInitiateResponse> InitiatePaymentAsync(KhaltiInitiateRequest request)
    {
        try
        {
            var baseUrl = _config.IsProduction ? _config.ProductionBaseUrl : _config.BaseUrl;
            var initiateUrl = $"{baseUrl}/api/v2/epayment/initiate/";

            var json = JsonSerializer.Serialize(request, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
            });

            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync(initiateUrl, content);
            var responseContent = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                var khaltiResponse = JsonSerializer.Deserialize<KhaltiInitiateResponse>(responseContent, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
                    PropertyNameCaseInsensitive = true
                });

                if (khaltiResponse != null)
                {
                    khaltiResponse.Success = true;
                    khaltiResponse.Message = "Payment initiated successfully";
                    return khaltiResponse;
                }
            }

            _logger.LogError("Khalti initiate payment failed with status: {StatusCode}, Response: {Response}", 
                response.StatusCode, responseContent);

            return new KhaltiInitiateResponse
            {
                Success = false,
                Message = "Failed to initiate payment"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error initiating Khalti payment");
            return new KhaltiInitiateResponse
            {
                Success = false,
                Message = "Payment initiation error"
            };
        }
    }

    public async Task<KhaltiLookupResponse> LookupPaymentAsync(KhaltiLookupRequest request)
    {
        try
        {
            var baseUrl = _config.IsProduction ? _config.ProductionBaseUrl : _config.BaseUrl;
            var lookupUrl = $"{baseUrl}/api/v2/epayment/lookup/";

            var json = JsonSerializer.Serialize(request, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
            });

            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync(lookupUrl, content);
            var responseContent = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                var khaltiResponse = JsonSerializer.Deserialize<KhaltiLookupResponse>(responseContent, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
                    PropertyNameCaseInsensitive = true
                });

                if (khaltiResponse != null)
                {
                    khaltiResponse.Success = true;
                    khaltiResponse.Message = "Payment lookup successful";
                    return khaltiResponse;
                }
            }

            _logger.LogError("Khalti lookup payment failed with status: {StatusCode}, Response: {Response}", 
                response.StatusCode, responseContent);

            return new KhaltiLookupResponse
            {
                Success = false,
                Message = "Failed to lookup payment"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error looking up Khalti payment");
            return new KhaltiLookupResponse
            {
                Success = false,
                Message = "Payment lookup error"
            };
        }
    }

    public bool VerifyWebhookSignature(string payload, string signature)
    {
        try
        {
            using var hmac = new System.Security.Cryptography.HMACSHA256(Encoding.UTF8.GetBytes(_config.SecretKey));
            var computedHash = hmac.ComputeHash(Encoding.UTF8.GetBytes(payload));
            var computedSignature = Convert.ToBase64String(computedHash);
            
            return computedSignature.Equals(signature, StringComparison.OrdinalIgnoreCase);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error verifying Khalti webhook signature");
            return false;
        }
    }
}
