using System.Security.Cryptography;
using System.Text;
using System.Threading.RateLimiting;
using Touchline.Endpoints;
using Touchline.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<LocalOcrService>();
builder.Services.AddSingleton<PlayerTrackingService>();
builder.Services.AddSingleton<AiReviewService>();
builder.Services.AddAntiforgery(options => {
    options.HeaderName = "X-CSRF-TOKEN";
    options.Cookie.SameSite = SameSiteMode.Strict;
});
// Frames are bounded in size; the original video remains in the browser.
builder.WebHost.ConfigureKestrel(options => options.Limits.MaxRequestBodySize = 8_000_000);
builder.Services.AddRateLimiter(options => {
    options.RejectionStatusCode = 429;
    options.AddPolicy("ai", context => RateLimitPartition.GetFixedWindowLimiter("shared-ai", _ =>
        new FixedWindowRateLimiterOptions { PermitLimit = 5, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
var hosted = builder.Configuration.GetValue<bool>("HOSTED_MODE");
var accessPassword = builder.Configuration["APP_ACCESS_PASSWORD"] ?? "";
if (hosted && accessPassword.Length < 16)
    throw new InvalidOperationException("Hosted mode needs APP_ACCESS_PASSWORD with at least 16 characters.");
var app = builder.Build();
// Shared-key hosting is an invitation-only workspace. Visitors cannot change its key.
app.Use(async (context, next) => {
    if (hosted && context.Request.Path != "/api/health") {
        var valid = false;
        var header = context.Request.Headers.Authorization.ToString();
        if (header.StartsWith("Basic ", StringComparison.OrdinalIgnoreCase)) {
            try {
                var actual = SHA256.HashData(Convert.FromBase64String(header[6..]));
                var expected = SHA256.HashData(Encoding.UTF8.GetBytes("touchline:" + accessPassword));
                valid = CryptographicOperations.FixedTimeEquals(actual, expected);
            } catch (FormatException) { }
        }
        if (!valid) {
            context.Response.StatusCode = 401;
            context.Response.Headers.WWWAuthenticate = "Basic realm=\"Touchline\", charset=\"UTF-8\"";
            return;
        }
    }
    await next(context);
});
app.UseRateLimiter();
// This personal app accepts AI access only from loopback and trusted localhost hosts.
// Same-origin checks on mutations block cross-site forms and DNS-rebinding key access.
app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/api/ai"))
    {
        var address = context.Connection.RemoteIpAddress;
        var host = context.Request.Host.Host;
        if (!hosted && (address is null || !System.Net.IPAddress.IsLoopback(address) ||
            !(host.Equals("localhost", StringComparison.OrdinalIgnoreCase) || host == "127.0.0.1" || host == "::1" || host == "[::1]")))
        { context.Response.StatusCode = 403; return; }
        context.Response.Headers.CacheControl = "no-store";
        if (context.Request.Method != "GET")
        {
            var expected = $"{(hosted ? "https" : context.Request.Scheme)}://{context.Request.Host}";
            var origin = context.Request.Headers.Origin.ToString();
            if (origin.Length > 0 && !string.Equals(origin, expected, StringComparison.OrdinalIgnoreCase))
            { context.Response.StatusCode = 403; return; }
            try { await context.RequestServices.GetRequiredService<Microsoft.AspNetCore.Antiforgery.IAntiforgery>().ValidateRequestAsync(context); }
            catch (Microsoft.AspNetCore.Antiforgery.AntiforgeryValidationException) {
                context.Response.StatusCode = 403;
                await context.Response.WriteAsJsonAsync(new { error = "Session verification failed. Refresh and try again." }); return;
            }
        }
    }
    await next(context);
});
app.UseDefaultFiles();
app.UseStaticFiles();
app.MapExperimentEndpoints();
app.Run();
