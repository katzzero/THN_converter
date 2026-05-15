namespace THN_Converter_Win.Models;

public class VideoMetadata
{
    public string Filename { get; set; } = "";
    public TimeSpan Duration { get; set; }
    public int? Bitrate { get; set; }
    public string? Container { get; set; }
    public List<VideoStreamInfo> VideoStreams { get; set; } = [];
    public List<AudioStreamInfo> AudioStreams { get; set; } = [];
    public List<SubtitleStreamInfo> SubtitleStreams { get; set; } = [];
    public List<DataStreamInfo> DataStreams { get; set; } = [];
    public string? Timecode { get; set; }
    public ColorSpaceInfo? ColorSpace { get; set; }
    public string? Error { get; set; }
}
