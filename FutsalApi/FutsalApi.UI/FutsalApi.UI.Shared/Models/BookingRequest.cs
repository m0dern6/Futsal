using System;
using System.Collections.Generic;

namespace FutsalApi.UI.Shared.Models
{
    public class BookingRequest
    {
        public int FutsalGroundId { get; set; }
        public DateTime BookingDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
    }
}
