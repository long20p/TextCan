using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Models;

namespace TextCan.Server.Services
{
    public class ContentService : IContentService
    {
        private Dictionary<string, ContentModel> contents;
        private IUniqueKeyService keyService;

        public ContentService(IUniqueKeyService keyService)
        {
            contents = new Dictionary<string, ContentModel>();
            this.keyService = keyService;
        }

        public string CreateContent(ContentModel content)
        {
            var key = keyService.GetUniqueKey();
            contents[key] = content;
            return key;
        }

        public ContentModel GetContent(string contentId)
        {
            if (!contents.ContainsKey(contentId))
            {
                return null;
            }
            return contents[contentId];
        }
    }
}
