using Microsoft.AspNetCore.Mvc;
using Touchline.Models;
using Touchline.Services;

namespace Touchline.Endpoints;

public static class ExperimentEndpoints
{
    public static void MapExperimentEndpoints(this WebApplication app)
    {
        app.MapGet("/api/ai/session", (HttpContext context, Microsoft.AspNetCore.Antiforgery.IAntiforgery antiforgery) =>
            Results.Ok(new { token = antiforgery.GetAndStoreTokens(context).RequestToken }));
        app.MapPost("/api/ai/key", (AiKeyRequest request, AiReviewService service, HttpContext context) =>
        {
            context.Response.Headers.CacheControl = "no-store";
            if (app.Configuration.GetValue<bool>("HOSTED_MODE"))
                return Results.Json(new { error = "The workspace owner manages the shared AI connection." }, statusCode: 403);
            var key = request.Key?.Trim();
            if (key is null || key.Length > 512 || (key.Length > 0 &&
                (!key.StartsWith("sk-or-", StringComparison.Ordinal) || key.Any(char.IsWhiteSpace) || key.Any(char.IsControl))))
                return Results.BadRequest(new { error = "Enter a valid API key, or clear it." });
            service.SetSessionKey(key);
            return Results.Ok(new { configured = service.Configured, model = service.Model });
        }).WithMetadata(new RequestSizeLimitAttribute(2048));
        app.MapGet("/api/ai/status", (AiReviewService service) => Results.Ok(new { configured = service.Configured, model = service.Model, managed = app.Configuration.GetValue<bool>("HOSTED_MODE") }));
        app.MapPost("/api/ai/review", async (AiReviewRequest request, AiReviewService service, CancellationToken token) =>
        {
            if (request.Sport is not ("soccer" or "american-football"))
                return Results.BadRequest(new { error = "Choose soccer or American football." });
            if (request.Crops is null || request.Crops.Count is < 1 or > 5 ||
                request.Crops.Select(crop => crop.TrackId).Distinct().Count() != request.Crops.Count)
                return Results.BadRequest(new { error = "Send 1–5 distinct track crops." });
            foreach (var crop in request.Crops) {
                if (crop.TrackId < 1 || !double.IsFinite(crop.Timestamp) || crop.Timestamp < 0 ||
                    crop.Trigger is not ("conflicting-readings" or "unreadable" or "single-reading") ||
                    string.IsNullOrWhiteSpace(crop.ImageBase64) || crop.ImageBase64.Length > 1_500_000)
                    return Results.BadRequest(new { error = "Invalid crop evidence." });
                try {
                    var bytes = Convert.FromBase64String(crop.ImageBase64);
                    if (bytes.Length < 4 || bytes[0] != 0xff || bytes[1] != 0xd8)
                        return Results.BadRequest(new { error = "Supply JPEG crops." });
                } catch (FormatException) { return Results.BadRequest(new { error = "Invalid image encoding." }); }
            }
            try { return Results.Ok(await service.ReviewAsync(request, token)); }
            catch (InvalidOperationException error) { return Results.Json(new { error = error.Message }, statusCode: 503); }
        }).RequireRateLimiting("ai");
        app.MapGet("/api/runtime", () => Results.Ok(new { hosted = app.Configuration.GetValue<bool>("HOSTED_MODE"), engine = app.Configuration["VISION_ENGINE"] ?? (OperatingSystem.IsMacOS() ? "apple-vision" : "linux") }));
        app.MapGet("/api/health", () => Results.Ok(new { status = "ready", mode = app.Configuration["VISION_ENGINE"] ?? "apple-vision" }));
        app.MapPost("/api/tracks/link", (TrackingRequest request, PlayerTrackingService service) =>
        {
            if (request.Frames is null || request.Frames.Count is < 1 or > 80)
                return Results.BadRequest(new { error = "Provide 1–80 chronological frames." });
            var timestamps = new HashSet<double>();
            foreach (var frame in request.Frames)
            {
                if (!double.IsFinite(frame.Timestamp) || frame.Timestamp < 0 || !timestamps.Add(frame.Timestamp) ||
                    frame.People is null || frame.People.Count > 40 || frame.People.Select(person => person.Id).Distinct().Count() != frame.People.Count)
                    return Results.BadRequest(new { error = "Invalid timestamps or person detections." });
                foreach (var person in frame.People)
                    if (person.Readings is null || person.Readings.Count > 100 || person.Readings.Any(reading => reading.Text is null) ||
                        !double.IsFinite(person.X + person.Y + person.Width + person.Height) ||
                        person.X < 0 || person.Y < 0 || person.Width <= 0 || person.Height <= 0 ||
                        person.X + person.Width > 1.01 || person.Y + person.Height > 1.01)
                        return Results.BadRequest(new { error = "Person boxes must be normalized image coordinates." });
            }
            return Results.Ok(service.Link(request));
        });
        app.MapPost("/api/frames/read", async (FrameRequest request, LocalOcrService service, CancellationToken token) =>
        {
            if (string.IsNullOrWhiteSpace(request.ImageBase64) || request.ImageBase64.Length > 7_000_000)
                return Results.BadRequest(new { error = "Supply an image smaller than 5 MB." });
            byte[] image;
            try { image = Convert.FromBase64String(request.ImageBase64); }
            catch (FormatException) { return Results.BadRequest(new { error = "Invalid image encoding." }); }
            try { return Results.Ok(await service.ReadAsync(image, token)); }
            catch (OperationCanceledException) { return Results.Json(new { error = "Frame processing timed out or was canceled." }, statusCode: 408); }
            catch (InvalidOperationException error) { return Results.Json(new { error = error.Message }, statusCode: 503); }
        });
    }
}
