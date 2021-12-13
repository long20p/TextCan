using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using TextCan.Server.Models;
using TextCan.Server.Services;

namespace TextCan.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ContentController : ControllerBase
    {
        private ILogger<ContentController> logger;
        private IContentService contentService;
        private TelemetryClient telemetryClient;

        public ContentController(IContentService contentService, ILogger<ContentController> logger, TelemetryClient telemetryClient)
        {
            this.contentService = contentService;
            this.logger = logger;
            this.telemetryClient = telemetryClient;
        }

        [HttpPost("create")]
        public async Task<string> CreateContent([FromBody] ContentModel model)
        {
            try
            {
                var key = await contentService.CreateContent(model);
                telemetryClient.TrackEvent("Content created", new Dictionary<string, string> { { "contentKey", key } });
                return key;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Cannot set content");
                telemetryClient.TrackException(ex);
                throw;
            }
        }

        [HttpGet("get/{uniqueId}")]
        public async Task<string> GetContent(string uniqueId)
        {
            try
            {
                var content = await contentService.GetContent(uniqueId);
                return content?.Text;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, $"Cannot get content for Id: {uniqueId}"); 
                throw;
            }
        }
    }
}
