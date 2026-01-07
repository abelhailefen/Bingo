using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Bingo.Core.Models
{
    public enum ResponseStatus
    {
        Error,
        Success,
        Warning,
        Info,
        NotFound
    }
    public class Response<T>
    {
        public ResponseStatus ResponseStatus { get; set; } = ResponseStatus.Success;
        public bool IsFailed { get { return this.ResponseStatus == ResponseStatus.Error || this.Data == null; } }
        public string? Message { get; set; } = String.Empty;
        public string? MessageCode { get; set; }

        [JsonIgnore]
        public Exception? Ex { get; set; }
        public T? Data { get; set; }

        public Response()
        {

        }
        public Response(T data)
        {
            this.Data = data;
        }

        public Response(ResponseStatus status, T? data, string message = "", Exception? ex = null, string? messageCode = null)
        {
            this.ResponseStatus = status;
            this.Message = message;
            this.Ex = ex;
            this.Data = data;
            this.MessageCode = messageCode;
        }

        public static Response<T> Success(T data)
        {
            return new Response<T>
            {
                Data = data,
                ResponseStatus = ResponseStatus.Success
            };
        }

        public static Response<T> Error(string message, Exception? ex = null, string? messageCode = null)
        {
            return new Response<T>
            {
                Ex = ex,
                ResponseStatus = ResponseStatus.Error,
                Message = message,
                MessageCode = messageCode
            };
        }

        public static Response<T> NotFound(string message, string? messageCode = null)
        {
            return new Response<T>
            {
                ResponseStatus = ResponseStatus.NotFound,
                Message = message,
                Data = default,
                MessageCode = messageCode
            };
        }

    }
}
