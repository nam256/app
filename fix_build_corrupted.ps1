# Script to fix "Not a directory" build errors on Windows
# This fixes the bundleLibRuntimeToDirDebug error where files exist instead of directories

Write-Host "Fixing corrupted build directories..." -ForegroundColor Yellow

# Stop all Flutter/Dart/Java processes
Write-Host "Stopping processes..." -ForegroundColor Cyan
$processes = @("dart", "java", "gradle", "flutter", "adb")
foreach ($proc in $processes) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 3

# Kill processes that might be locking files (VS Code, File Explorer handles)
Write-Host "Closing file handles..." -ForegroundColor Cyan
try {
    # Try to close any handles to the project directory
    $projectPath = (Get-Location).Path
    Write-Host "  Project path: $projectPath" -ForegroundColor Gray
} catch {
    # Ignore if we can't get the path
}

# Stop Gradle daemon
Write-Host "Stopping Gradle daemon..." -ForegroundColor Cyan
if (Test-Path "android\gradlew.bat") {
    Set-Location android
    .\gradlew.bat --stop 2>&1 | Out-Null
    Set-Location ..
}

# Remove corrupted files that should be directories
Write-Host "Removing corrupted build files..." -ForegroundColor Cyan
function Remove-CorruptedBuildFiles {
    param([string]$SearchPath)
    
    if (Test-Path $SearchPath) {
        Get-ChildItem -Path $SearchPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $item = $_
            # Check if this is a file that should be a directory (based on error pattern)
            if (-not $item.PSIsContainer) {
                $name = $item.Name
                if ($name -eq "bundleLibRuntimeToDirDebug" -or $name -eq "bundleLibRuntimeToDirRelease") {
                    Write-Host "  Removing corrupted file: $($item.FullName)" -ForegroundColor Red
                    Remove-Item -Path $item.FullName -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}

# Clean up corrupted files in build directories
$buildPath = "build"
if (Test-Path $buildPath) {
    Remove-CorruptedBuildFiles -SearchPath $buildPath
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
                Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Gray
                return $false
            }
        }
    }
    return $false
}

# Remove all build directories to start fresh
Write-Host "Removing build directories..." -ForegroundColor Cyan
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

# Remove specific locked files/directories
Write-Host "Removing locked plugin symlinks..." -ForegroundColor Cyan
$lockedPaths = @(
    "windows\flutter\ephemeral\.plugin_symlinks"
)

foreach ($path in $lockedPaths) {
    Remove-DirectoryWithRetry -Path $path -MaxRetries 5 -DelayMs 2000
    Start-Sleep -Milliseconds 300
}

Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host "You can now run: flutter clean && flutter pub get && flutter run" -ForegroundColor Cyan

