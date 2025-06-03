using System;

namespace TextCan.Server.Configs
{
    public class ResilienceConfig
    {
        // Circuit Breaker configuration
        public int HandledEventsAllowedBeforeBreaking { get; set; } = 3;
        public TimeSpan DurationOfBreak { get; set; } = TimeSpan.FromMinutes(1);
        public TimeSpan Timeout { get; set; } = TimeSpan.FromSeconds(30);
        
        // Retry configuration
        public int RetryCount { get; set; } = 3;
        public TimeSpan RetryBaseDelay { get; set; } = TimeSpan.FromMilliseconds(500);
        public TimeSpan RetryMaxDelay { get; set; } = TimeSpan.FromSeconds(5);
    }
}
