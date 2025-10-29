# WawApp Client

Flutter client application for the WawApp ride-hailing platform.

## Prerequisites

- Flutter 3.22.0+
- Dart SDK (bundled with Flutter)
- Java JDK 17+
- Android SDK with API level 34+
- Firebase project configuration

## Environment Verification

Before building, run the preflight check to verify all dependencies:

```bash
dart run tool/preflight_check.dart
```

This validates:
- ✅ Flutter/Dart SDK versions
- ✅ Java JDK 17+ installation
- ✅ Android SDK configuration
- ✅ Gradle compatibility
- ✅ Firebase setup (google-services.json, firebase_options.dart)
- ✅ Required permissions in AndroidManifest.xml
- ✅ Firebase dependencies in pubspec.yaml
- ✅ Network connectivity to Firebase

## Development

```bash
# Install dependencies
flutter pub get

# Run preflight check
dart run tool/preflight_check.dart

# Run in debug mode
flutter run

# Build APK
flutter build apk --debug
```

## CI/CD

The preflight check runs automatically:
- Before Gradle assembly tasks
- In GitHub Actions workflow
- Blocks build if critical issues found

## Troubleshooting

If preflight check fails:
1. Check Flutter/Java versions
2. Verify Android SDK path in `android/local.properties`
3. Ensure `google-services.json` matches package name
4. Run `flutter doctor` for additional diagnostics
