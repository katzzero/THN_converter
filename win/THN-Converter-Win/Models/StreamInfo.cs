namespace THN_Converter_Win.Models;

public class VideoStreamInfo
{
    public int Index { get; set; }
    public string Codec { get; set; } = "";
    public string Profile { get; set; } = "";
    public string Resolution { get; set; } = "";
    public string PixelFormat { get; set; } = "";
    public string FrameRate { get; set; } = "";
    public int? Bitrate { get; set; }
    public string Sar { get; set; } = "N/A";
    public string Dar { get; set; } = "N/A";
    public string? ColorRange { get; set; }
    public string? ColorSpace { get; set; }
    public string? ColorPrimaries { get; set; }
    public string? ColorTransfer { get; set; }
    public bool IsHDR { get; set; }
}

public class AudioStreamInfo
{
    public int Index { get; set; }
    public string Codec { get; set; } = "";
    public int SampleRate { get; set; }
    public string Channels { get; set; } = "";
    public int? Bitrate { get; set; }
    public string? Language { get; set; }
}

public class SubtitleStreamInfo
{
    public int Index { get; set; }
    public string Codec { get; set; } = "";
    public string? Language { get; set; }
}

public class DataStreamInfo
{
    public int Index { get; set; }
    public string Type { get; set; } = "";
    public string? Codec { get; set; }
}
