cd "$PSScriptRoot\.."
git fetch --all --prune
git checkout -B main origin/main
Write-Host "✅ Updated to latest origin/main"