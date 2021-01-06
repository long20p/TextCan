using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using TextCan.Server.Configs;
using TextCan.Server.Repository;
using TextCan.Server.Services;

namespace TextCan.Server
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<DbConfig>(Configuration.GetSection("Database"));
            services.Configure<KeyServiceConfig>(Configuration.GetSection("KeyService"));

            services.AddCors(options =>
            {
                var allowedOrigins = Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>();
                options.AddDefaultPolicy(builder =>
                    builder
                    .WithOrigins(allowedOrigins)
                    .AllowAnyMethod()
                    .AllowAnyHeader());
            });

            services.AddControllers();

            var keyLength = Configuration.GetValue<int>("UniqueKeyLength");
            services.AddSingleton<IDbContext, DbContext>();
            services.AddSingleton<IContentRepository, ContentRepository>();
            services.AddSingleton<IUniqueKeyService, UniqueKeyService>();
            services.AddSingleton<IContentService, ContentService>();
            services.AddSingleton<DbInitializer>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                //app.UseHsts();
            }
            
            // Init DB
            app.ApplicationServices.GetService(typeof(DbInitializer));

            //app.UseHttpsRedirection();
            app.UseCors();

            app.UseRouting();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}
