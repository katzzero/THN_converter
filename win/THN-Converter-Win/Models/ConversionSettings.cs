namespace THN_Converter_Win.Models;

public class ConversionSettings
{
    public string VideoCodec { get; set; } = "libx264";
    public string Quality { get; set; } = "23";
    public string Resolution { get; set; } = "Original";
    public string Framerate { get; set; } = "Original";
    public string AudioCodec { get; set; } = "copy";
    public string AudioBitrate { get; set; } = "192k";
    public string AudioSampleRate { get; set; } = "48000";
    public bool AddTimecode { get; set; } = true;
    public string TimecodePosition { get; set; } = "bottom-center";
    public string OutputPath { get; set; } = "";
}
