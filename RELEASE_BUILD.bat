@echo off
echo ========================================
echo  THN Converter - Windows Build Script
echo ========================================
echo.

:: Check for .NET 8 SDK
dotnet --list-sdks | find "8." >nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] .NET 8 SDK not found. Install from:
    echo   https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)

echo [1/3] Building Release...
dotnet publish THN-Converter-Win.csproj -c Release -r win-x64 --self-contained -p:PublishSingleFile=true

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo [2/3] Creating zip...
powershell -Command "Compress-Archive -Force -Path 'bin\Release\net8.0-windows\win-x64\publish\THN-Converter-Win.exe' -DestinationPath 'THN-Converter-Windows.zip'"

echo.
echo [3/3] Done! Artifact: THN-Converter-Windows.zip
echo   Location: bin\Release\net8.0-windows\win-x64\publish\THN-Converter-Win.exe
pause
