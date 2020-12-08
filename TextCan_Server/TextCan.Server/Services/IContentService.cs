using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Models;

namespace TextCan.Server.Services
{
    public interface IContentService
    {
        Task<string> CreateContent(ContentModel content);
        Task<ContentModel> GetContent(string contentId);
    }
}
