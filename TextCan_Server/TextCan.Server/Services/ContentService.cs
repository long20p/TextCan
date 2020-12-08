using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Models;
using TextCan.Server.Repository;
using TextCan.Server.Repository.DbModels;

namespace TextCan.Server.Services
{
    public class ContentService : IContentService
    {
        private IContentRepository contentRepository;
        private IUniqueKeyService keyService;

        public ContentService(IContentRepository contentRepository, IUniqueKeyService keyService)
        {
            this.contentRepository = contentRepository;
            this.keyService = keyService;
        }

        public async Task<string> CreateContent(ContentModel content)
        {
            var key = keyService.GetUniqueKey();
            var dbItem = new Content
            {
                Key = key,
                Text = content.Text,
                ExpireAt = content.ExpireAt.HasValue ? content.ExpireAt.Value.ToString("s") : null
            };
            await contentRepository.Add(dbItem);
            return key;
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
