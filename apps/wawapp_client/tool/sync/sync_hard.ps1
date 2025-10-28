#!/usr/bin/env pwsh
# Hard sync script for Windows PowerShell

Write-Host "🔄 Starting hard sync..." -ForegroundColor Green

git fetch --all --prune
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

git switch main
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

git reset --hard origin/main
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

git submodule update --init --recursive
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

git clean -fdx
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

dart run build_runner build --delete-conflicting-outputs
# Ignore build_runner errors

flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "✅ Hard sync completed successfully!" -ForegroundColor Green