namespace THN_Converter_Win.Models;

public class ColorSpaceInfo
{
    public string Range { get; set; } = "";
    public string Space { get; set; } = "";
    public string Primaries { get; set; } = "";
    public string Transfer { get; set; } = "";
    public bool IsHDR { get; set; }
    public string? HdrFormat { get; set; }
}
