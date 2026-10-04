# Script to fix file lock issues on Windows
Write-Host "Fixing file lock issues..." -ForegroundColor Yellow

# Stop all Flutter/Dart/Java processes
Write-Host "Stopping processes..." -ForegroundColor Cyan
$processes = @("dart", "java", "gradle", "flutter", "adb")
foreach ($proc in $processes) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 3

# Stop Gradle daemon
Write-Host "Stopping Gradle daemon..." -ForegroundColor Cyan
if (Test-Path "android\gradlew.bat") {
    Set-Location android
    .\gradlew.bat --stop 2>&1 | Out-Null
    Set-Location ..
}

# Function to remove directory with retry
function Remove-DirectoryWithRetry {
    param(
        [string]$Path,
        [int]$MaxRetries = 3,
        [int]$DelayMs = 1000
    )
    
    if (-not (Test-Path $Path)) {
        return $true
    }
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            # Try to remove read-only attributes first
            Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
            }
            
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            return $true
        } catch {
            if ($i -lt $MaxRetries) {
                Write-Host "  Retry $i/$MaxRetries for $Path..." -ForegroundColor Yellow
                Start-Sleep -Milliseconds $DelayMs
            } else {
                Write-Host "  Warning: Could not remove $Path after $MaxRetries attempts" -ForegroundColor Red
                return $false
            }
        }
    }
    return $false
}

# Remove locked build directories
Write-Host "Removing locked build directories..." -ForegroundColor Cyan
$buildDirs = @(
    "build",
    ".dart_tool",
    "android\build",
    "android\.gradle"
)

foreach ($dir in $buildDirs) {
    Remove-DirectoryWithRetry -Path $dir
    Start-Sleep -Milliseconds 300
}

# Remove Flutter ephemeral directories (often locked)
Write-Host "Removing Flutter ephemeral directories..." -ForegroundColor Cyan
$ephemeralDirs = @(
    "ios\Flutter\ephemeral",
    "linux\flutter\ephemeral",
    "macos\Flutter\ephemeral",
    "windows\flutter\ephemeral"
)

foreach ($dir in $ephemeralDirs) {
    Remove-DirectoryWithRetry -Path $dir -MaxRetries 5 -DelayMs 2000
    Start-Sleep -Milliseconds 300
}

# Remove corrupted intermediate directories for all plugins
Write-Host "Cleaning plugin build directories..." -ForegroundColor Cyan
$pluginDirs = @(
    "build\app_links",
    "build\share_plus",
    "build\shared_preferences_android",
    "build\image_picker_android",
    "build\path_provider_android",
    "build\sqflite_android",
    "build\url_launcher_android",
    "build\flutter_plugin_android_lifecycle"
)

foreach ($dir in $pluginDirs) {
    Remove-DirectoryWithRetry -Path $dir
    Start-Sleep -Milliseconds 300
}

Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host "You can now run: flutter run" -ForegroundColor Cyan

