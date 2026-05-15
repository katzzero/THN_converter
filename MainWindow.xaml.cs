using System.Windows;
using THN_Converter_Win.ViewModels;

namespace THN_Converter_Win;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
    }

    private void Window_PreviewDragOver(object sender, DragEventArgs e)
    {
        e.Effects = e.Data.GetDataPresent(DataFormats.FileDrop)
            ? DragDropEffects.Copy
            : DragDropEffects.None;
        e.Handled = true;
    }

    private void Window_Drop(object sender, DragEventArgs e)
    {
        if (e.Data.GetDataPresent(DataFormats.FileDrop) &&
            e.Data.GetData(DataFormats.FileDrop) is string[] files &&
            files.Length > 0)
        {
            var vm = DataContext as MainViewModel;
            vm?.SetDroppedFile(files[0]);
        }
    }

    private void DropZone_MouseDown(object sender, System.Windows.Input.MouseButtonEventArgs e)
    {
        var vm = DataContext as MainViewModel;
        vm?.SelectFileCommand.Execute(null);
    }

    private void OutputZone_MouseDown(object sender, System.Windows.Input.MouseButtonEventArgs e)
    {
        var vm = DataContext as MainViewModel;
        vm?.SelectOutputCommand.Execute(null);
    }
}
