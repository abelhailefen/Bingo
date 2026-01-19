using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Context;
using Bingo.Infrastructure.Repository;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

using Npgsql.NameTranslation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Infrastructure.Dependency
{
    public static class Configuration
    {
        public static IServiceCollection AddBingoInfrastructure(this IServiceCollection services, IConfiguration config)
        {
            var connectionString = config.GetConnectionString("DefaultConnection");
            var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);

  

            var dataSource = dataSourceBuilder.Build();
            services.AddSingleton(dataSource);

            services.AddDbContext<BingoDbContext>((sp, options) =>
            {
                var ds = sp.GetRequiredService<NpgsqlDataSource>();
                options.UseNpgsql(ds);

                
            });

            services.AddScoped<IBingoRepository, BingoRepository>();
            return services;
        }

    }
}
