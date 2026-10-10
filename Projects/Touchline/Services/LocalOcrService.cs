using System.Diagnostics;
using System.Text.Json;
using Touchline.Models;

namespace Touchline.Services;

/// <summary>Runs the configured CPU vision engine; model review is a separate service.</summary>
public sealed class LocalOcrService(IWebHostEnvironment environment, IConfiguration configuration)
{
    private readonly SemaphoreSlim gate = new(1, 1);

    public async Task<FrameResult> ReadAsync(byte[] image, CancellationToken cancellationToken)
    {
        // Bound concurrency and execution time so repeated runs cannot overwhelm the host.
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        timeout.CancelAfter(TimeSpan.FromSeconds(120));
        await gate.WaitAsync(timeout.Token);
        try
        {
            var linux = configuration["VISION_ENGINE"] == "linux" || !OperatingSystem.IsMacOS();
            var executable = linux ? configuration["VISION_PYTHON"] ?? "/usr/bin/python3"
                : Path.Combine(environment.ContentRootPath, "Tools", "vision-reader");
            if (!File.Exists(executable))
                throw new InvalidOperationException("Vision engine is unavailable. Check the server installation.");
            using var process = new Process
            {
                StartInfo = new ProcessStartInfo(executable)
                {
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false
                }
            };
            if (linux) process.StartInfo.ArgumentList.Add(Path.Combine(environment.ContentRootPath, "Tools", "linux_reader.py"));
            process.Start();
            using var registration = timeout.Token.Register(() =>
            {
                try { if (!process.HasExited) process.Kill(entireProcessTree: true); }
                catch (InvalidOperationException) { }
            });
            var outputTask = process.StandardOutput.ReadToEndAsync(timeout.Token);
            var errorTask = process.StandardError.ReadToEndAsync(timeout.Token);
            await process.StandardInput.BaseStream.WriteAsync(image, timeout.Token);
            process.StandardInput.Close();
            await process.WaitForExitAsync(timeout.Token);
            var output = await outputTask;
            var error = await errorTask;
            if (process.ExitCode != 0)
                throw new InvalidOperationException("OCR could not decode this frame. " + error);
            var evidence = JsonSerializer.Deserialize<FrameResult>(output,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? new FrameResult([], []);
            return evidence;
        }
        finally { gate.Release(); }
    }
}
