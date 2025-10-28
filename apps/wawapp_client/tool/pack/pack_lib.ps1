#!/usr/bin/env pwsh
# Pack lib folder for distribution

# Get git info
try {
    $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
    $sha = (git rev-parse --short=7 HEAD 2>$null).Trim()
} catch {
    $branch = "unknown"
    $sha = "unknown"
}

if ([string]::IsNullOrEmpty($branch)) { $branch = "unknown" }
if ([string]::IsNullOrEmpty($sha)) { $sha = "unknown" }

# Generate timestamp
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"

# Create artifacts directory
if (!(Test-Path "artifacts")) {
    New-Item -ItemType Directory -Path "artifacts" | Out-Null
}

# Generate ZIP filename (sanitize branch name)
$safeBranch = $branch -replace '[^a-zA-Z0-9_-]', '_'
$zipName = "lib-$safeBranch-$sha-$timestamp.zip"
$zipPath = "artifacts\$zipName"

# Remove existing ZIP if present
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Create ZIP
Compress-Archive -Path "lib\*" -DestinationPath $zipPath

# Output absolute path
$absolutePath = (Resolve-Path $zipPath).Path
Write-Host $absolutePath