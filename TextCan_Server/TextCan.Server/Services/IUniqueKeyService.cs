﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TextCan.Server.Services
{
    public interface IUniqueKeyService
    {
        Task<string> GetUniqueKey();
    }
}
