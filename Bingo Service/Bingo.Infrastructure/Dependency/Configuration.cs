using Bingo.Core.Contract.Repository;
using Bingo.Infrastructure.Context;
using Bingo.Infrastructure.Repository;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
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
            services.AddDbContext<BingoDbContext>(options =>
               options.UseNpgsql(config.GetConnectionString("DefaultConnection")));
            services.AddScoped<IBingoRepository, BingoRepository>();

            return services;
        }

    }
}
