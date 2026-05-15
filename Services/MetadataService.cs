using System.Diagnostics;
using System.Text.RegularExpressions;
using THN_Converter_Win.Models;

namespace THN_Converter_Win.Services;

public partial class MetadataService
{
    public async Task<VideoMetadata> ExtractMetadataAsync(string filePath)
    {
        var tcs = new TaskCompletionSource<VideoMetadata>();

        await Task.Run(() =>
        {
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = new FfmpegService().FindFfmpeg(),
                    Arguments = $"-i \"{filePath}\"",
                    UseShellExecute = false,
                    RedirectStandardError = true,
                    StandardErrorEncoding = System.Text.Encoding.UTF8,
                    CreateNoWindow = true
                }
            };

            var output = new System.Text.StringBuilder();
            process.ErrorDataReceived += (_, e) =>
            {
                if (e.Data != null)
                    output.AppendLine(e.Data);
            };

            process.Start();
            process.BeginErrorReadLine();
            process.WaitForExit();

            var metadata = ParseFfmpegOutput(output.ToString(), Path.GetFileName(filePath));
            tcs.TrySetResult(metadata);
        });

        return await tcs.Task;
    }

    private VideoMetadata ParseFfmpegOutput(string output, string filename)
    {
        var metadata = new VideoMetadata { Filename = filename };
        var lines = output.Split('\n', StringSplitOptions.RemoveEmptyEntries);

        foreach (var line in lines)
        {
            if (line.Contains("Duration:"))
            {
                var durationMatch = DurationRegex().Match(line);
                if (durationMatch.Success)
                {
                    var h = double.Parse(durationMatch.Groups[1].Value);
                    var m = double.Parse(durationMatch.Groups[2].Value);
                    var s = double.Parse(durationMatch.Groups[3].Value);
                    metadata.Duration = TimeSpan.FromSeconds(h * 3600 + m * 60 + s);
                }

                var bitrateMatch = BitrateRegex().Match(line);
                if (bitrateMatch.Success && int.TryParse(bitrateMatch.Groups[1].Value, out var br))
                    metadata.Bitrate = br;
            }

            if (line.Contains("Input #0,"))
            {
                var parts = line.Split("Input #0, ", StringSplitOptions.None);
                if (parts.Length > 1)
                    metadata.Container = parts[1].Split(',')[0].Trim();
            }

            if (line.Contains("Stream #0:"))
            {
                if (line.Contains("Video:"))
                {
                    var info = ParseVideoStream(line);
                    if (info != null) metadata.VideoStreams.Add(info);
                }
                else if (line.Contains("Audio:"))
                {
                    var info = ParseAudioStream(line);
                    if (info != null) metadata.AudioStreams.Add(info);
                }
                else if (line.Contains("Subtitle:"))
                {
                    var info = ParseSubtitleStream(line);
                    if (info != null) metadata.SubtitleStreams.Add(info);
                }
                else if (line.Contains("Data:"))
                {
                    var info = ParseDataStream(line);
                    if (info != null) metadata.DataStreams.Add(info);
                }
            }

            // Check for timecode
            if (TimecodeRegex().IsMatch(line))
            {
                var tcMatch = TimecodeRegex().Match(line);
                if (tcMatch.Success)
                    metadata.Timecode = tcMatch.Value;
            }
        }

        // Color space extraction from video stream lines
        foreach (var line in lines)
        {
            if (line.Contains("Stream #0:") && line.Contains("Video:"))
            {
                var cs = ExtractColorSpace(line);
                if (cs != null)
                {
                    metadata.ColorSpace = cs;
                    break;
                }
            }
        }

        return metadata;
    }

    private VideoStreamInfo? ParseVideoStream(string line)
    {
        var info = new VideoStreamInfo();

        var indexMatch = IndexRegex().Match(line);
        if (indexMatch.Success && int.TryParse(indexMatch.Groups[1].Value, out var idx))
            info.Index = idx;

        var codecMatch = VideoCodecRegex().Match(line);
        if (codecMatch.Success)
            info.Codec = codecMatch.Groups[1].Value;

        var profileMatch = ProfileRegex().Match(line);
        if (profileMatch.Success)
            info.Profile = profileMatch.Groups[1].Value.Trim();

        var resMatch = ResolutionRegex().Match(line);
        if (resMatch.Success)
            info.Resolution = resMatch.Value;

        var pixelMatch = PixelFormatRegex().Match(line);
        if (pixelMatch.Success)
        {
            var pf = pixelMatch.Groups[1].Value.Trim();
            if (!string.IsNullOrEmpty(pf) && pf != ",")
                info.PixelFormat = pf;
        }

        if (line.Contains(" fps"))
        {
            var fpsParts = line.Split(" fps");
            var rateStr = fpsParts[0].Split(' ').LastOrDefault();
            if (rateStr != null)
                info.FrameRate = rateStr.Trim() + " fps";
        }

        var bitrateMatch = BitrateRegex().Match(line);
        if (bitrateMatch.Success && int.TryParse(bitrateMatch.Groups[1].Value, out var br))
            info.Bitrate = br;

        var sarMatch = SarRegex().Match(line);
        info.Sar = sarMatch.Success ? sarMatch.Groups[0].Value.Replace("SAR ", "") : "N/A";

        var darMatch = DarRegex().Match(line);
        info.Dar = darMatch.Success ? darMatch.Groups[0].Value.Replace("DAR ", "") : "N/A";

        var colorMatch = ColorRangeRegex().Match(line);
        if (colorMatch.Success)
        {
            var parts = colorMatch.Groups[0].Value.Split(", ");
            if (parts.Length >= 2)
            {
                info.ColorRange = parts[0];
                info.ColorSpace = parts[1];
            }
        }

        var primariesMatch = PrimariesRegex().Match(line);
        if (primariesMatch.Success)
            info.ColorPrimaries = primariesMatch.Value;

        var transferMatch = TransferRegex().Match(line);
        if (transferMatch.Success)
            info.ColorTransfer = transferMatch.Value;

        info.IsHDR = info.ColorTransfer is "smpte2084" or "hlg" ||
                     info.ColorPrimaries is "smpte431" or "smpte432";

        return info;
    }

    private AudioStreamInfo? ParseAudioStream(string line)
    {
        var info = new AudioStreamInfo();

        var indexMatch = IndexRegex().Match(line);
        if (indexMatch.Success && int.TryParse(indexMatch.Groups[1].Value, out var idx))
            info.Index = idx;

        var codecMatch = AudioCodecRegex().Match(line);
        if (codecMatch.Success)
            info.Codec = codecMatch.Groups[1].Value;

        var sampleMatch = SampleRateRegex().Match(line);
        if (sampleMatch.Success && int.TryParse(sampleMatch.Groups[1].Value, out var sr))
            info.SampleRate = sr;

        var channelsMatch = ChannelsRegex().Match(line);
        info.Channels = channelsMatch.Success ? channelsMatch.Value : "mono";

        var bitrateMatch = BitrateRegex().Match(line);
        if (bitrateMatch.Success && int.TryParse(bitrateMatch.Groups[1].Value, out var br))
            info.Bitrate = br;

        if (line.Contains("und)"))
            info.Language = "und";
        else
        {
            var langMatch = LanguageRegex().Match(line);
            if (langMatch.Success)
                info.Language = langMatch.Groups[1].Value;
        }

        return info;
    }

    private SubtitleStreamInfo? ParseSubtitleStream(string line)
    {
        var info = new SubtitleStreamInfo();

        var indexMatch = IndexRegex().Match(line);
        if (indexMatch.Success && int.TryParse(indexMatch.Groups[1].Value, out var idx))
            info.Index = idx;

        var codecMatch = SubtitleCodecRegex().Match(line);
        if (codecMatch.Success)
            info.Codec = codecMatch.Groups[1].Value;

        if (line.Contains("und)"))
            info.Language = "und";

        return info;
    }

    private DataStreamInfo? ParseDataStream(string line)
    {
        var info = new DataStreamInfo();

        var indexMatch = IndexRegex().Match(line);
        if (indexMatch.Success && int.TryParse(indexMatch.Groups[1].Value, out var idx))
            info.Index = idx;

        var typeMatch = DataTypeRegex().Match(line);
        if (typeMatch.Success)
        {
            info.Type = typeMatch.Groups[1].Value;
            info.Codec = info.Type != "none" ? info.Type : null;
        }

        if (line.Contains("tmcd"))
            info.Type = "tmcd";
        else if (line.Contains("timecode"))
            info.Type = "timecode";

        return info;
    }

    private ColorSpaceInfo? ExtractColorSpace(string line)
    {
        if (!line.Contains("tv,") && !line.Contains("pc,"))
            return null;

        var info = new ColorSpaceInfo();

        var rangeMatch = RangeRegex().Match(line);
        if (rangeMatch.Success)
            info.Range = rangeMatch.Groups[1].Value;

        var spaceMatch = SpaceRegex().Match(line);
        if (spaceMatch.Success)
            info.Space = spaceMatch.Groups[1].Value;

        var primariesMatch = PrimariesRegex().Match(line);
        if (primariesMatch.Success)
            info.Primaries = primariesMatch.Value;

        var transferMatch = TransferRegex().Match(line);
        if (transferMatch.Success)
            info.Transfer = transferMatch.Value;

        if (info.Transfer == "smpte2084")
        {
            info.IsHDR = true;
            info.HdrFormat = "HDR10";
        }
        else if (info.Transfer == "hlg")
        {
            info.IsHDR = true;
            info.HdrFormat = "Hybrid Log-Gamma";
        }
        else if (info.Primaries is "smpte431" or "smpte432")
        {
            info.IsHDR = true;
            info.HdrFormat = "HDR (Unknown Format)";
        }

        return string.IsNullOrEmpty(info.Range) ? null : info;
    }

    [GeneratedRegex(@"Duration: (\d+):(\d+):(\d+\.\d+)")]
    private static partial Regex DurationRegex();
    [GeneratedRegex(@"(\d+) kb/s")]
    private static partial Regex BitrateRegex();
    [GeneratedRegex(@"Stream #0:(\d+)")]
    private static partial Regex IndexRegex();
    [GeneratedRegex(@"Video: ([a-z0-9_]+)")]
    private static partial Regex VideoCodecRegex();
    [GeneratedRegex(@"Audio: ([a-z0-9_]+)")]
    private static partial Regex AudioCodecRegex();
    [GeneratedRegex(@"Subtitle: ([a-z0-9_]+)")]
    private static partial Regex SubtitleCodecRegex();
    [GeneratedRegex(@"Data: ([a-z0-9_]+)")]
    private static partial Regex DataTypeRegex();
    [GeneratedRegex(@"\(([^)]+)\)")]
    private static partial Regex ProfileRegex();
    [GeneratedRegex(@"(\d+)x(\d+)")]
    private static partial Regex ResolutionRegex();
    [GeneratedRegex(@"([a-z0-9]+)(?:\([^)]+\))?")]
    private static partial Regex PixelFormatRegex();
    [GeneratedRegex(@"SAR (\d+:\d+)")]
    private static partial Regex SarRegex();
    [GeneratedRegex(@"DAR (\d+:\d+)")]
    private static partial Regex DarRegex();
    [GeneratedRegex(@"(tv|pc),\s*\w{2,6}")]
    private static partial Regex ColorRangeRegex();
    [GeneratedRegex(@"(tv|pc)")]
    private static partial Regex RangeRegex();
    [GeneratedRegex(@",\s*([a-z]{2,6})/")]
    private static partial Regex SpaceRegex();
    [GeneratedRegex(@"(bt709|bt2020|smpte431|smpte432|bt601)")]
    private static partial Regex PrimariesRegex();
    [GeneratedRegex(@"(bt709|smpte2084|hlg)")]
    private static partial Regex TransferRegex();
    [GeneratedRegex(@"\(([a-z]{3})\)")]
    private static partial Regex LanguageRegex();
    [GeneratedRegex(@"(\d+) Hz")]
    private static partial Regex SampleRateRegex();
    [GeneratedRegex(@"mono|stereo|5\.1|5\.1\(|6 channels|8 channels")]
    private static partial Regex ChannelsRegex();
    [GeneratedRegex(@"timecode\s*:\s*[\d:;]+")]
    private static partial Regex TimecodeRegex();
}
