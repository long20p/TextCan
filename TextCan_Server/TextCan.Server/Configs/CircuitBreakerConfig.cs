using System;

namespace TextCan.Server.Configs
{
    public class CircuitBreakerConfig
    {
        public int HandledEventsAllowedBeforeBreaking { get; set; } = 3;
        public TimeSpan DurationOfBreak { get; set; } = TimeSpan.FromMinutes(1);
        public TimeSpan Timeout { get; set; } = TimeSpan.FromSeconds(30);
    }
}
