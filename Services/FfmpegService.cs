using System.Diagnostics;
using THN_Converter_Win.Models;

namespace THN_Converter_Win.Services;

public class FfmpegService
{
    private Process? _process;
    private double _duration;

    public string FindFfmpeg()
    {
        string[] searchPaths =
        [
            Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ffmpeg", "ffmpeg.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "ffmpeg", "ffmpeg.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "ffmpeg", "bin", "ffmpeg.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "ffmpeg", "bin", "ffmpeg.exe"),
            "ffmpeg.exe"
        ];

        foreach (var path in searchPaths)
        {
            if (File.Exists(path))
                return Path.GetFullPath(path);
        }

        return "ffmpeg.exe";
    }

    public async Task ConvertAsync(
        string inputPath,
        ConversionSettings settings,
        IProgress<double>? onProgress,
        Action<string>? onOutput)
    {
        var args = BuildArguments(inputPath, settings);

        onOutput?.Invoke($"Iniciando conversão...\n");
        onOutput?.Invoke($"Entrada: {inputPath}\n");
        onOutput?.Invoke($"Saída: {settings.OutputPath}\n");
        onOutput?.Invoke($"Codec: {settings.VideoCodec} | Qualidade: {settings.Quality}\n");
        onOutput?.Invoke($"Áudio: {settings.AudioCodec}\n\n");
        onOutput?.Invoke($"Comando FFmpeg: {string.Join(" ", args)}\n");

        _process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = FindFfmpeg(),
                Arguments = string.Join(" ", args.Select(a => a.Contains(' ') ? $"\"{a}\"" : a)),
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                StandardOutputEncoding = System.Text.Encoding.UTF8,
                StandardErrorEncoding = System.Text.Encoding.UTF8,
                CreateNoWindow = true
            }
        };

        _duration = 0;

        _process.ErrorDataReceived += (_, e) =>
        {
            if (e.Data == null) return;
            onOutput?.Invoke("[ERROR] " + e.Data + "\n");
        };

        _process.OutputDataReceived += (_, e) =>
        {
            if (e.Data == null) return;
            onOutput?.Invoke(e.Data + "\n");
            ParseProgress(e.Data, onProgress);
        };

        _process.Start();
        _process.BeginOutputReadLine();
        _process.BeginErrorReadLine();
        await _process.WaitForExitAsync();

        if (_process.ExitCode == 0)
        {
            onProgress?.Report(1.0);
            onOutput?.Invoke($"\n✅ Conversão concluída! Arquivo salvo em: {settings.OutputPath}\n");
        }
        else
        {
            var errorMsg = $"FFmpeg falhou com código {_process.ExitCode}. Verifique se o caminho de saída é válido e tem permissões de escrita.";
            onOutput?.Invoke($"\n❌ Erro: {errorMsg}\n");
            throw new Exception(errorMsg);
        }
    }

    private string[] BuildArguments(string inputPath, ConversionSettings settings)
    {
        var args = new List<string>
        {
            "-y",
            "-i", inputPath,
            "-c:v", settings.VideoCodec
        };

        if (settings.VideoCodec is "libx264" or "libx265")
        {
            args.AddRange(["-preset", "medium", "-crf", settings.Quality]);
        }
        else if (settings.VideoCodec == "prores_ks")
        {
            args.AddRange(["-profile:v", "3"]);
        }

        var vfFilters = new List<string>();

        if (settings.Resolution != "Original")
        {
            var res = settings.Resolution.Split(' ')[0];
            vfFilters.Add($"scale={res}");
        }

        if (settings.AddTimecode)
        {
            vfFilters.Add(GetTimecodeFilter(settings.TimecodePosition));
        }

        if (vfFilters.Count > 0)
        {
            args.AddRange(["-vf", string.Join(",", vfFilters)]);
        }

        if (settings.Framerate != "Original")
        {
            args.AddRange(["-r", settings.Framerate]);
        }

        args.AddRange(["-c:a", settings.AudioCodec]);

        if (settings.AudioCodec != "copy")
        {
            args.AddRange(["-b:a", settings.AudioBitrate, "-ar", settings.AudioSampleRate]);
        }

        args.Add(settings.OutputPath);
        return [.. args];
    }

    private void ParseProgress(string line, IProgress<double>? onProgress)
    {
        if (_duration == 0 && line.Contains("Duration:"))
        {
            var match = System.Text.RegularExpressions.Regex.Match(line,
                @"Duration: (\d+):(\d+):(\d+\.\d+)");
            if (match.Success)
            {
                var h = double.Parse(match.Groups[1].Value);
                var m = double.Parse(match.Groups[2].Value);
                var s = double.Parse(match.Groups[3].Value);
                _duration = h * 3600 + m * 60 + s;
            }
        }

        if (_duration > 0 && line.Contains("time="))
        {
            var match = System.Text.RegularExpressions.Regex.Match(line,
                @"time=(\d+):(\d+):(\d+\.\d+)");
            if (match.Success)
            {
                var h = double.Parse(match.Groups[1].Value);
                var m = double.Parse(match.Groups[2].Value);
                var s = double.Parse(match.Groups[3].Value);
                var currentTime = h * 3600 + m * 60 + s;
                onProgress?.Report(Math.Min(currentTime / _duration, 1.0));
            }
        }
    }

    private string GetTimecodeFilter(string position)
    {
        string fontColor = "white";
        string fontSize = "24";
        string boxColor = "black@0.7";
        string fontPath = FindAvailableFont();

        string fontfile = string.IsNullOrEmpty(fontPath) ? "" : $"fontfile={fontPath}:";

        string coords = position switch
        {
            "top-left" => "x=10:y=10",
            "top-center" => "x=(w-tw)/2:y=10",
            "top-right" => "x=w-tw-10:y=10",
            "bottom-left" => "x=10:y=h-th-10",
            "bottom-center" => "x=(w-tw)/2:y=h-th-10",
            "bottom-right" => "x=w-tw-10:y=h-th-10",
            _ => "x=(w-tw)/2:y=h-th-10"
        };

        return $"drawtext=text='%{{gmtime\\:%H:%M:%S}}':{fontfile}fontsize={fontSize}:fontcolor={fontColor}:box=1:boxcolor={boxColor}:{coords}";
    }

    private string FindAvailableFont()
    {
        string[] fontPaths =
        [
            @"C:\Windows\Fonts\arial.ttf",
            @"C:\Windows\Fonts\segoeui.ttf",
            @"C:\Windows\Fonts\tahoma.ttf",
            @"C:\Windows\Fonts\verdana.ttf",
            @"C:\Windows\Fonts\trebuc.ttf"
        ];

        return fontPaths.FirstOrDefault(File.Exists) ?? "";
    }

    public void Cancel()
    {
        _process?.Kill(entireProcessTree: true);
    }
}
