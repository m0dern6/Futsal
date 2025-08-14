using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using PaymentGateway;
using Microsoft.Extensions.Options;

namespace FutsalApi.ApiService.Services.PaymentGateway;

public class ESewaConfig
{
    public string MerchantId { get; set; } = string.Empty;
    public string SecretKey { get; set; } = string.Empty;
    public string BaseUrl { get; set; } = "https://rc-epay.esewa.com.np"; // Sandbox URL
    public string ProductionBaseUrl { get; set; } = "https://epay.esewa.com.np";
    public bool IsProduction { get; set; } = false;
}

public interface IESewaService
{
    Task<ESewaInitiateResponse> InitiatePaymentAsync(ESewaInitiateRequest request);
    Task<ESewaVerificationResponse> VerifyPaymentAsync(ESewaVerificationRequest request);
    string GenerateSignature(string message);
    bool VerifySignature(string message, string signature);
}

public class ESewaService : IESewaService
{
    private readonly HttpClient _httpClient;
    private readonly ESewaConfig _config;
    private readonly ILogger<ESewaService> _logger;

    public ESewaService(HttpClient httpClient, IOptions<ESewaConfig> config, ILogger<ESewaService> logger)
    {
        _httpClient = httpClient;
        _config = config.Value;
        _logger = logger;
    }

    public async Task<ESewaInitiateResponse> InitiatePaymentAsync(ESewaInitiateRequest request)
    {
        try
        {
            var baseUrl = _config.IsProduction ? _config.ProductionBaseUrl : _config.BaseUrl;
            var paymentUrl = $"{baseUrl}/api/epay/main/v2/form";

            // Create form data for eSewa
            var formData = new Dictionary<string, string>
            {
                ["amount"] = request.Amount.ToString("F2"),
                ["failure_url"] = request.FailureUrl,
                ["product_delivery_charge"] = request.ProductDeliveryCharge,
                ["product_service_charge"] = request.ProductServiceCharge,
                ["product_code"] = request.ProductCode,
                ["signature"] = GenerateSignature(CreateSignatureMessage(request)),
                ["signed_field_names"] = "total_amount,transaction_uuid,product_code",
                ["success_url"] = request.SuccessUrl,
                ["tax_amount"] = request.TaxAmount,
                ["total_amount"] = request.TotalAmount.ToString("F2"),
                ["transaction_uuid"] = request.TransactionUuid
            };

            return new ESewaInitiateResponse
            {
                PaymentUrl = paymentUrl,
                TransactionUuid = request.TransactionUuid,
                Success = true,
                Message = "Payment initiated successfully"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error initiating eSewa payment");
            return new ESewaInitiateResponse
            {
                Success = false,
                Message = "Failed to initiate payment"
            };
        }
    }

    public async Task<ESewaVerificationResponse> VerifyPaymentAsync(ESewaVerificationRequest request)
    {
        try
        {
            var baseUrl = _config.IsProduction ? _config.ProductionBaseUrl : _config.BaseUrl;
            var verificationUrl = $"{baseUrl}/api/epay/transaction/status/";

            var verificationData = new
            {
                product_code = request.ProductCode,
                total_amount = request.TotalAmount.ToString("F2"),
                transaction_uuid = request.TransactionUuid
            };

            var json = JsonSerializer.Serialize(verificationData);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            // Add merchant ID to headers
            _httpClient.DefaultRequestHeaders.Clear();
            _httpClient.DefaultRequestHeaders.Add("merchant-id", _config.MerchantId);

            var response = await _httpClient.PostAsync(verificationUrl, content);

            if (response.IsSuccessStatusCode)
            {
                var responseContent = await response.Content.ReadAsStringAsync();
                var verificationResponse = JsonSerializer.Deserialize<ESewaVerificationResponse>(responseContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                return verificationResponse ?? new ESewaVerificationResponse
                {
                    HasData = false,
                    Message = "Invalid response from eSewa"
                };
            }
            else
            {
                _logger.LogError("eSewa verification failed with status: {StatusCode}", response.StatusCode);
                return new ESewaVerificationResponse
                {
                    HasData = false,
                    Message = "Payment verification failed"
                };
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error verifying eSewa payment");
            return new ESewaVerificationResponse
            {
                HasData = false,
                Message = "Payment verification error"
            };
        }
    }

    public string GenerateSignature(string message)
    {
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(_config.SecretKey));
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(message));
        return Convert.ToBase64String(hash);
    }

    public bool VerifySignature(string message, string signature)
    {
        var computedSignature = GenerateSignature(message);
        return computedSignature.Equals(signature, StringComparison.OrdinalIgnoreCase);
    }

    private string CreateSignatureMessage(ESewaInitiateRequest request)
    {
        return $"total_amount={request.TotalAmount:F2},transaction_uuid={request.TransactionUuid},product_code={request.ProductCode}";
    }
}
