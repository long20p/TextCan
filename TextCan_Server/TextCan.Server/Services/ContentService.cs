using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Models;
using TextCan.Server.Repository;
using TextCan.Server.Repository.DbModels;
using Microsoft.Extensions.Logging;

namespace TextCan.Server.Services
{    public class ContentService : IContentService
    {
        private IContentRepository contentRepository;
        private IUniqueKeyService keyService;
        private ILogger<ContentService> logger;

        public ContentService(IContentRepository contentRepository, IUniqueKeyService keyService, ILogger<ContentService> logger)
        {
            this.contentRepository = contentRepository;
            this.keyService = keyService;
            this.logger = logger;
        }

        public async Task<string> CreateContent(ContentModel content)
        {
            var key = await keyService.GetUniqueKey();
            
            // Fallback to GUID-based key if key service is unavailable
            if (key == null)
            {
                key = GenerateFallbackKey();
                logger.LogWarning("Key service unavailable, using fallback key generation: {Key}", key);
            }
            
            var dbItem = new Content
            {
                Id = key,
                Key = key,
                Text = content.Text,
                ExpireAt = content.ExpireAt.HasValue ? content.ExpireAt.Value.ToString("s") : null
            };
            await contentRepository.Add(dbItem);
            return key;
        }

        private string GenerateFallbackKey()
        {
            // Generate a short, URL-friendly key using GUID
            var guid = Guid.NewGuid().ToString("N");
            // Take first 8 characters to keep it short and readable
            return guid.Substring(0, 8);
        }

        public async Task<ContentModel> GetContent(string contentId)
        {
            var dbItem = await contentRepository.GetItem(contentId);
            if (dbItem == null)
            {
                return null;
            }

            DateTime? expireAt = null;
            if (DateTime.TryParse(dbItem.ExpireAt, out var val))
            {
                expireAt = val;
            }
            return new ContentModel
            {
                Text = dbItem.Text,
                ExpireAt = expireAt
            };
        }
    }
}
