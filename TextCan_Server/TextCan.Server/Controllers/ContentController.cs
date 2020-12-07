using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TextCan.Server.Models;
using TextCan.Server.Services;

namespace TextCan.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ContentController : ControllerBase
    {
        private IContentService contentService;
        public ContentController(IContentService contentService)
        {
            this.contentService = contentService;
        }

        [HttpPost("create")]
        public string CreateContent([FromBody] ContentModel model)
        {
            return contentService.CreateContent(model);
        }

        [HttpGet("get/{uniqueId}")]
        public string GetContent(string uniqueId)
        {
            return contentService.GetContent(uniqueId)?.Text;
        }
    }
}
