import 'dart:io';

String readFile(String path) =>
    File(path).existsSync() ? File(path).readAsStringSync() : '';

bool has(String content, Pattern p) => RegExp(p.toString()).hasMatch(content);

void main() {
  int failures = 0;

  print('🔎 Verifying Firebase & Google Maps integration...');

  // --- Paths
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final buildGradlePath = 'android/app/build.gradle';
  final googleServicesPath = 'android/app/google-services.json';
  final firebaseOptionsPath = 'lib/firebase_options.dart';
  final pubspecPath = 'pubspec.yaml';
  final mainPath = 'lib/main.dart';

  // --- Load files
  final manifest = readFile(manifestPath);
  final buildGradle = readFile(buildGradlePath);
  final googleServices = readFile(googleServicesPath);
  final firebaseOptions = readFile(firebaseOptionsPath);
  final pubspec = readFile(pubspecPath);
  final mainDart = readFile(mainPath);

  // 1) google-services.json exists
  if (googleServices.isEmpty) {
    print('❌ Missing $googleServicesPath');
    failures++;
  } else {
    print('✅ Found $googleServicesPath');
    // quick sanity keys
    if (!has(googleServices, RegExp(r'"project_number"\s*:\s*"\d+"'))) {
      print('❌ google-services.json: project_number missing');
      failures++;
    }
    if (!has(googleServices, RegExp(r'"mobilesdk_app_id"\s*:\s*".+?"'))) {
      print('❌ google-services.json: mobilesdk_app_id missing');
      failures++;
    }
  }

  // 2) firebase_options.dart exists with DefaultFirebaseOptions
  if (firebaseOptions.isEmpty ||
      !firebaseOptions.contains('class DefaultFirebaseOptions')) {
    print(
        '❌ Missing or invalid $firebaseOptionsPath (run: flutterfire configure)');
    failures++;
  } else {
    print('✅ Found $firebaseOptionsPath');
  }

  // 3) main.dart safe init (apps.isEmpty guard)
  final hasEnsureBinding =
      mainDart.contains('WidgetsFlutterBinding.ensureInitialized');
  final hasSafeInit = mainDart.contains('Firebase.apps.isEmpty') &&
      mainDart.contains('Firebase.initializeApp(');
  if (!hasEnsureBinding) {
    print('❌ main.dart: WidgetsFlutterBinding.ensureInitialized() not found');
    failures++;
  } else {
    print('✅ Binding ensured');
  }
  if (!hasSafeInit) {
    print(
        '❌ main.dart: Missing safe Firebase init guard (Firebase.apps.isEmpty)');
    failures++;
  } else {
    print('✅ Safe Firebase init guard present');
  }

  // 4) pubspec has google_maps_flutter (optional but recommended)
  if (pubspec.contains('google_maps_flutter')) {
    print('✅ google_maps_flutter declared');
  } else {
    print(
        '⚠️ google_maps_flutter not found in pubspec.yaml (skip if not needed)');
  }

  // 5) AndroidManifest has Google Maps API key meta-data
  if (manifest.contains('com.google.android.geo.API_KEY')) {
    // ensure non-placeholder
    final apiKeyValueMatch =
        RegExp(r'com\.google\.android\.geo\.API_KEY"\s+android:value="([^"]+)"')
            .firstMatch(manifest);
    final v = apiKeyValueMatch?.group(1) ?? '';
    if (v.isEmpty || v.contains('YOUR_API_KEY') || v.contains('\${')) {
      print('❌ AndroidManifest: API KEY present but looks placeholder');
      failures++;
    } else {
      print('✅ Google Maps API KEY present');
    }
  } else {
    print(
        '❌ AndroidManifest: Missing <meta-data android:name="com.google.android.geo.API_KEY" .../>');
    failures++;
  }

  // 6) Android location permissions for Geolocator
  final hasFine = manifest.contains('android.permission.ACCESS_FINE_LOCATION');
  final hasCoarse =
      manifest.contains('android.permission.ACCESS_COARSE_LOCATION');
  if (hasFine && hasCoarse) {
    print('✅ Location permissions OK');
  } else {
    print(
        '❌ Missing location permissions (ACCESS_FINE/COARSE_LOCATION) in AndroidManifest');
    failures++;
  }

  // 7) build.gradle applicationId sanity
  if (buildGradle.contains('applicationId')) {
    print('✅ applicationId set in build.gradle');
  } else {
    print('❌ applicationId not found in android/app/build.gradle');
    failures++;
  }

  // 8) Quick duplicate-app guard at runtime context (already covered via main)
  // (No runtime here, just structural check.)

  if (failures == 0) {
    print('🎉 All integration checks passed.');
  } else {
    print('🚨 Integration checks failed: $failures issue(s) found.');
    exitCode = 1;
  }
}
