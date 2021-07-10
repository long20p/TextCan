using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using TextCan.Server.Configs;
using TextCan.Server.Repository;
using TextCan.Server.Repository.AWS;
using TextCan.Server.Repository.Azure;
using TextCan.Server.Services;

namespace TextCan.Server
{
    public class Startup
    {
        private string CorsPolicy = "TextCanCorsPolicy";

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
            var hostProvider = Configuration.GetValue<string>("HostProvider");
            //var dbConfig = Configuration.GetSection("Database").Get<DbConfig>();
            //dbConfig.EndpointUrl = File.ReadAllText("db.cfg");
            //var keySvcConfig = Configuration.GetSection("KeyService").Get<KeyServiceConfig>();
            //keySvcConfig.GetKeyUrl = File.ReadAllText("key_svc.cfg");

            services.AddCors(options =>
            {
                //var allowedOrigins = Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>();
                options.AddPolicy(CorsPolicy, builder =>
                    builder
                    //.WithOrigins(allowedOrigins)
                    .AllowAnyOrigin()
                    .AllowAnyMethod()
                    .AllowAnyHeader());
            });

            services.AddControllers();

            //services.AddSingleton<DbConfig>(dbConfig);
            //services.AddSingleton<KeyServiceConfig>(keySvcConfig);

            if (hostProvider == "AWS")
            {
                services.AddSingleton<DynamoDbContext>();
                services.AddSingleton<IDynamoDbContext, DynamoDbContext>();
                services.AddSingleton<IContentRepository, DynamoContentRepository>();
            }
            else if (hostProvider == "Azure")
            {
                services.AddSingleton<ICosmosDbContext, CosmosDbContext>();
                services.AddSingleton<IContentRepository, CosmosContentRepository>();
            }
            else
            {
                throw new ApplicationException($"Unknown host provider: {hostProvider}");
            }
            
            services.AddSingleton<IUniqueKeyService, UniqueKeyService>();
            services.AddSingleton<IContentService, ContentService>();
            services.AddSingleton<DbInitializer>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });

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

            app.UseRouting();
            app.UseCors(CorsPolicy);

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}
