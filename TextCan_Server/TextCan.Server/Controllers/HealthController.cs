using System;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace TextCan.Server.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class HealthController : ControllerBase
    {
        private readonly ILogger<HealthController> _logger;

        public HealthController(ILogger<HealthController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public IActionResult Check()
        {
            try
            {
                // You can add additional health checks here, such as database connectivity
                return Ok(new
                {
                    status = "healthy",
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check failed");
                return StatusCode(StatusCodes.Status500InternalServerError, new
                {
                    status = "unhealthy",
                    message = "Health check failed",
                    timestamp = DateTime.UtcNow
                });
            }
        }
    }
}
