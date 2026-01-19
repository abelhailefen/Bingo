using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class MasterCard
    {
        public long MasterCardId { get; set; }
        public ICollection<MasterCardNumber> Numbers { get; set; } = new List<MasterCardNumber>();
    }
}
