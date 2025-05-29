using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using TextCan.Server.Configs;
using Newtonsoft.Json.Linq;
using Microsoft.Extensions.Logging;
using Polly;
using Polly.CircuitBreaker;

namespace TextCan.Server.Services
{    public class UniqueKeyService : IUniqueKeyService
    {
        private ILogger<UniqueKeyService> logger;
        private HttpClient httpClient;
        private string keyServiceUrl;
        private readonly IAsyncPolicy<HttpResponseMessage> circuitBreakerPolicy;

        public UniqueKeyService(IOptions<KeyServiceConfig> config, IOptions<CircuitBreakerConfig> circuitBreakerConfig, ILogger<UniqueKeyService> logger)
        {
            this.logger = logger;
            httpClient = new HttpClient();
            httpClient.Timeout = circuitBreakerConfig.Value.Timeout;
            keyServiceUrl = config.Value.GetKeyUrl;
            logger.LogInformation($"Key service address: {keyServiceUrl}");

            // Configure circuit breaker policy
            circuitBreakerPolicy = Policy
                .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
                .Or<HttpRequestException>()
                .Or<TaskCanceledException>()
                .CircuitBreakerAsync(
                    handledEventsAllowedBeforeBreaking: circuitBreakerConfig.Value.HandledEventsAllowedBeforeBreaking,
                    durationOfBreak: circuitBreakerConfig.Value.DurationOfBreak,
                    onBreak: (exception, duration) =>
                    {
                        logger.LogWarning("Key service circuit breaker opened. Duration: {Duration}ms. Exception: {Exception}",
                            duration.TotalMilliseconds, exception?.Exception?.Message ?? exception?.Result?.StatusCode.ToString());
                    },
                    onReset: () =>
                    {
                        logger.LogInformation("Key service circuit breaker reset - service is available again");
                    },
                    onHalfOpen: () =>
                    {
                        logger.LogInformation("Key service circuit breaker half-open - testing service availability");
                    });
        }

        public async Task<string> GetUniqueKey()
        {
            try
            {
                var response = await circuitBreakerPolicy.ExecuteAsync(async () =>
                {
                    return await httpClient.GetAsync(keyServiceUrl);
                });

                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync();
                    var token = JObject.Parse(content)["key"];
                    return token?.ToString();
                }
                else
                {
                    logger.LogError("Key service returned unsuccessful status code: {StatusCode}", response.StatusCode);
                    return null;
                }
            }
            catch (BrokenCircuitException)
            {
                logger.LogError("Key service is currently unavailable (circuit breaker open). Cannot generate unique key.");
                return null;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error occurred while calling key service");
                return null;
            }
        }
    }
}
