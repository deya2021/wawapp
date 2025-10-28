# Sync Tools

## Hard Sync Scripts

### Windows (PowerShell)
```bash
powershell -ExecutionPolicy Bypass -File tool/sync/sync_hard.ps1
```

### Unix/Linux/macOS (Bash)
```bash
chmod +x tool/sync/sync_hard.sh && ./tool/sync/sync_hard.sh
```

## Makefile Targets (Unix/Linux/macOS)

### Cross-platform sync
```bash
make sync-hard
```

### Development commands
```bash
make analyze    # Run flutter analyze
make debug      # Run app in debug mode  
make release    # Build release APK
make help       # Show available targets
```

## Windows Batch Scripts

### Alternative for Windows (when make unavailable)
```cmd
scripts sync-hard   # Hard sync with origin/main
scripts analyze     # Run flutter analyze
scripts debug       # Run app in debug mode
scripts release     # Build release APK
```

## What Hard Sync Does

1. Fetch all remote changes with pruning
2. Switch to main branch
3. Reset local main to match origin/main (destructive)
4. Update git submodules recursively
5. Clean untracked files and directories
6. Clean Flutter build cache
7. Get Flutter dependencies
8. Run build_runner (ignores errors)
9. Analyze code for issues

⚠️ **Warning**: Hard sync is destructive and will lose local uncommitted changes.