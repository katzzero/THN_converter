using System.Windows;

namespace THN_Converter_Win;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var resources = new ResourceDictionary
        {
            Source = new Uri("pack://application:,,,/Styles/DarkTheme.xaml")
        };
        this.Resources.MergedDictionaries.Add(resources);

        var mainWindow = new MainWindow();
        mainWindow.Show();
    }
}
