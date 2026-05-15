using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using THN_Converter_Win.Commands;
using THN_Converter_Win.Models;
using THN_Converter_Win.Services;

namespace THN_Converter_Win.ViewModels;

public class MainViewModel : INotifyPropertyChanged
{
    private readonly FfmpegService _ffmpeg;
    private readonly MetadataService _metadata;

    public MainViewModel()
    {
        _ffmpeg = new FfmpegService();
        _metadata = new MetadataService();

        SelectFileCommand = new RelayCommand(_ => SelectFile());
        SelectOutputCommand = new RelayCommand(_ => SelectOutput());
        ConvertCommand = new RelayCommand(async _ => await ConvertAsync(), _ => !IsConverting && DroppedFilePath != null);
        CancelCommand = new RelayCommand(_ => CancelConversion());
    }

    // ── File State ──────────────────────────────────────────────

    private string? _droppedFilePath;
    public string? DroppedFilePath
    {
        get => _droppedFilePath;
        set { _droppedFilePath = value; OnPropertyChanged(); OnPropertyChanged(nameof(DroppedFileName)); }
    }

    public string? DroppedFileName => DroppedFilePath != null ? Path.GetFileName(DroppedFilePath) : null;

    private string? _outputFilePath;
    public string? OutputFilePath
    {
        get => _outputFilePath;
        set { _outputFilePath = value; OnPropertyChanged(); OnPropertyChanged(nameof(OutputFileName)); }
    }

    public string? OutputFileName => OutputFilePath != null ? Path.GetFileName(OutputFilePath) : null;

    // ── Conversion State ────────────────────────────────────────

    private bool _isConverting;
    public bool IsConverting
    {
        get => _isConverting;
        set
        {
            _isConverting = value;
            OnPropertyChanged();
            CommandManager.InvalidateRequerySuggested();
        }
    }

    private double _conversionProgress;
    public double ConversionProgress
    {
        get => _conversionProgress;
        set { _conversionProgress = value; OnPropertyChanged(); OnPropertyChanged(nameof(ProgressPercent)); }
    }

    public string ProgressPercent => $"{ConversionProgress * 100:F1}%";

    private string _statusMessage = "Arraste um arquivo de vídeo aqui";
    public string StatusMessage
    {
        get => _statusMessage;
        set { _statusMessage = value; OnPropertyChanged(); }
    }

    private string _logOutput = "";
    public string LogOutput
    {
        get => _logOutput;
        set { _logOutput = value; OnPropertyChanged(); }
    }

    // ── Metadata State ──────────────────────────────────────────

    private VideoMetadata? _fileMetadata;
    public VideoMetadata? FileMetadata
    {
        get => _fileMetadata;
        set { _fileMetadata = value; OnPropertyChanged(); OnPropertyChanged(nameof(HasMetadata)); }
    }

    public bool HasMetadata => FileMetadata != null;

    private bool _isFetchingMetadata;
    public bool IsFetchingMetadata
    {
        get => _isFetchingMetadata;
        set { _isFetchingMetadata = value; OnPropertyChanged(); }
    }

    // ── Video Settings ──────────────────────────────────────────

    private string _selectedVideoCodec = "H.264";
    public string SelectedVideoCodec
    {
        get => _selectedVideoCodec;
        set { _selectedVideoCodec = value; OnPropertyChanged(); }
    }

    private string _selectedQuality = "23";
    public string SelectedQuality
    {
        get => _selectedQuality;
        set { _selectedQuality = value; OnPropertyChanged(); }
    }

    private string _selectedResolution = "Original";
    public string SelectedResolution
    {
        get => _selectedResolution;
        set { _selectedResolution = value; OnPropertyChanged(); }
    }

    private string _selectedFramerate = "Original";
    public string SelectedFramerate
    {
        get => _selectedFramerate;
        set { _selectedFramerate = value; OnPropertyChanged(); }
    }

    // ── Audio Settings ──────────────────────────────────────────

    private string _selectedAudioCodec = "copy (não converter)";
    public string SelectedAudioCodec
    {
        get => _selectedAudioCodec;
        set { _selectedAudioCodec = value; OnPropertyChanged(); OnPropertyChanged(nameof(ShowAudioSettings)); }
    }

    public bool ShowAudioSettings => !SelectedAudioCodec.StartsWith("copy");

    private string _selectedAudioBitrate = "192k";
    public string SelectedAudioBitrate
    {
        get => _selectedAudioBitrate;
        set { _selectedAudioBitrate = value; OnPropertyChanged(); }
    }

    private string _selectedAudioSampleRate = "48000";
    public string SelectedAudioSampleRate
    {
        get => _selectedAudioSampleRate;
        set { _selectedAudioSampleRate = value; OnPropertyChanged(); }
    }

    // ── Timecode Settings ───────────────────────────────────────

    private bool _showTimecode = true;
    public bool ShowTimecode
    {
        get => _showTimecode;
        set { _showTimecode = value; OnPropertyChanged(); }
    }

    private string _timecodePosition = "bottom-center";
    public string TimecodePosition
    {
        get => _timecodePosition;
        set { _timecodePosition = value; OnPropertyChanged(); }
    }

    // ── Commands ────────────────────────────────────────────────

    public ICommand SelectFileCommand { get; }
    public ICommand SelectOutputCommand { get; }
    public ICommand ConvertCommand { get; }
    public ICommand CancelCommand { get; }

    // ── Actions ─────────────────────────────────────────────────

    public void SetDroppedFile(string path)
    {
        DroppedFilePath = path;
        StatusMessage = "Arquivo pronto para conversão";
        _ = FetchMetadataAsync(path);
    }

    public void SetOutputFile(string path)
    {
        OutputFilePath = path;
    }

    private void SelectFile()
    {
        var dialog = new Microsoft.Win32.OpenFileDialog
        {
            Title = "Selecionar arquivo de vídeo",
            Filter = "Arquivos de vídeo|*.mp4;*.mov;*.avi;*.mkv;*.wmv;*.flv;*.webm;*.m4v;*.mxf|Todos os arquivos|*.*",
            Multiselect = false
        };

        if (dialog.ShowDialog() == true)
            SetDroppedFile(dialog.FileName);
    }

    private void SelectOutput()
    {
        var dialog = new Microsoft.Win32.SaveFileDialog
        {
            Title = "Selecionar local de salvamento",
            DefaultExt = ".mp4",
            Filter = "MP4|*.mp4|MOV|*.mov|AVI|*.avi|Todos|*.*"
        };

        var defaultName = DroppedFilePath != null
            ? $"{Path.GetFileNameWithoutExtension(DroppedFilePath)}_{MapVideoCodec(SelectedVideoCodec)}_{DateTime.Now:yyyyMMdd_HHmm}.mp4"
            : "video_converted.mp4";
        dialog.FileName = defaultName;

        if (dialog.ShowDialog() == true)
            OutputFilePath = dialog.FileName;
    }

    private async Task ConvertAsync()
    {
        if (DroppedFilePath == null) return;

        IsConverting = true;
        ConversionProgress = 0;
        StatusMessage = "Convertendo...";
        LogOutput = "";

        try
        {
            var outputPath = OutputFilePath;
            if (string.IsNullOrEmpty(outputPath))
            {
                var downloads = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Downloads");
                var codecSuffix = MapVideoCodec(SelectedVideoCodec);
                var timestamp = DateTime.Now.ToString("yyyyMMdd_HHmm");
                outputPath = Path.Combine(downloads, $"{Path.GetFileNameWithoutExtension(DroppedFilePath)}_{codecSuffix}_{timestamp}.mp4");
                OutputFilePath = outputPath;
            }

            var settings = new ConversionSettings
            {
                VideoCodec = MapVideoCodec(SelectedVideoCodec),
                Quality = SelectedQuality,
                Resolution = SelectedResolution == "Original" ? "Original" : SelectedResolution.Split(' ')[0],
                Framerate = SelectedFramerate == "Original" ? "Original" : SelectedFramerate,
                AudioCodec = SelectedAudioCodec.StartsWith("copy") ? "copy" : SelectedAudioCodec.Split(' ')[0].ToLower(),
                AudioBitrate = SelectedAudioBitrate,
                AudioSampleRate = SelectedAudioSampleRate,
                AddTimecode = ShowTimecode,
                TimecodePosition = TimecodePosition,
                OutputPath = outputPath
            };

            var progress = new Progress<double>(p =>
            {
                ConversionProgress = p;
            });

            await _ffmpeg.Convert(DroppedFilePath, settings, progress, msg =>
            {
                LogOutput += msg;
            });

            StatusMessage = "✅ Conversão concluída!";
        }
        catch (Exception ex)
        {
            StatusMessage = $"❌ Erro: {ex.Message}";
        }
        finally
        {
            IsConverting = false;
        }
    }

    private void CancelConversion()
    {
        _ffmpeg.Cancel();
        IsConverting = false;
        ConversionProgress = 0;
        StatusMessage = "Conversão cancelada";
    }

    private async Task FetchMetadataAsync(string filePath)
    {
        IsFetchingMetadata = true;
        FileMetadata = null;

        try
        {
            var metadata = await _metadata.ExtractMetadataAsync(filePath);
            FileMetadata = metadata;
        }
        catch (Exception ex)
        {
            StatusMessage = $"Erro ao obter metadados: {ex.Message}";
        }
        finally
        {
            IsFetchingMetadata = false;
        }
    }

    private static string MapVideoCodec(string displayName) => displayName switch
    {
        "H.264" => "libx264",
        "H.265/HEVC" => "libx265",
        "VP9" => "libvpx-vp9",
        "AV1" => "libaom-av1",
        "ProRes" => "prores_ks",
        "DNxHD" => "dnxhd",
        "MPEG-4" => "mpeg4",
        _ => "libx264"
    };

    // ── INotifyPropertyChanged ──────────────────────────────────

    public event PropertyChangedEventHandler? PropertyChanged;

    protected void OnPropertyChanged([CallerMemberName] string? name = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }
}
