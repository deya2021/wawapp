#!/bin/bash
# Hard sync script for Unix/Linux/macOS

set -e

echo "🔄 Starting hard sync..."

git fetch --all --prune
git switch main
git reset --hard origin/main
git submodule update --init --recursive
git clean -fdx
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs || true
flutter analyze

echo "✅ Hard sync completed successfully!"