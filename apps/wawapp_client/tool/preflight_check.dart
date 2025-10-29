import 'dart:io';
import 'dart:convert';

void main() async {
  final checker = PreflightChecker();
  await checker.runChecks();
}

class PreflightChecker {
  final List<CheckResult> results = [];
  bool hasErrors = false;

  Future<void> runChecks() async {
    print('🚀 WawApp Client - Environment Preflight Check\n');

    await _checkFlutterSDK();
    await _checkDartSDK();
    await _checkJavaJDK();
    await _checkAndroidSDK();
    await _checkGradleVersion();
    await _checkFirebaseConfig();
    await _checkFirebaseOptions();
    await _checkAndroidManifest();
    await _checkPubspecDependencies();
    await _checkFirebaseConnectivity();

    _printResults();

    if (hasErrors) {
      print(
          '\n❌ Preflight check failed. Please fix the issues above before building.');
      exit(1);
    } else {
      print('\n✅ All checks passed! Ready to build.');
      exit(0);
    }
  }

  Future<void> _checkFlutterSDK() async {
    try {
      // Check local.properties for Flutter SDK path first
      String? flutterPath;
      final localPropsFile = File('android/local.properties');
      if (await localPropsFile.exists()) {
        final content = await localPropsFile.readAsString();
        final flutterMatch = RegExp(r'flutter\.sdk=(.+)').firstMatch(content);
        if (flutterMatch != null) {
          flutterPath = flutterMatch.group(1)!.replaceAll('\\\\', '\\');
        }
      }

      ProcessResult? result;

      // Try Flutter from local.properties path first
      if (flutterPath != null) {
        final flutterCmd = Platform.isWindows
            ? '$flutterPath\\bin\\flutter.bat'
            : '$flutterPath/bin/flutter';
        try {
          result = await Process.run(flutterCmd, ['--version']);
        } catch (_) {}
      }

      // Fallback to PATH
      if (result == null || result.exitCode != 0) {
        try {
          result = await Process.run('flutter', ['--version']);
        } catch (_) {}
      }

      if (result != null && result.exitCode == 0) {
        final output = result.stdout.toString();
        final versionMatch =
            RegExp(r'Flutter (\d+\.\d+\.\d+)').firstMatch(output);
        if (versionMatch != null) {
          final version = versionMatch.group(1)!;
          final versionParts = version.split('.').map(int.parse).toList();
          if (versionParts[0] > 3 ||
              (versionParts[0] == 3 && versionParts[1] >= 22)) {
            _addResult('Flutter SDK', '✅', 'Version $version (>= 3.22.0)');
          } else {
            _addResult(
                'Flutter SDK', '❌', 'Version $version < 3.22.0 required');
            hasErrors = true;
          }
        } else {
          _addResult('Flutter SDK', '⚠️', 'Version parsing failed');
        }
      } else {
        _addResult('Flutter SDK', '❌',
            'Flutter not found in PATH or local.properties');
        hasErrors = true;
      }
    } catch (e) {
      _addResult('Flutter SDK', '❌', 'Error: $e');
      hasErrors = true;
    }
  }

  Future<void> _checkDartSDK() async {
    try {
      final result = await Process.run('dart', ['--version']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final versionMatch =
            RegExp(r'Dart SDK version: (\d+\.\d+\.\d+)').firstMatch(output);
        if (versionMatch != null) {
          final version = versionMatch.group(1)!;
          _addResult('Dart SDK', '✅', 'Version $version');
        } else {
          _addResult('Dart SDK', '⚠️', 'Version parsing failed');
        }
      } else {
        _addResult('Dart SDK', '❌', 'Dart command not found');
        hasErrors = true;
      }
    } catch (e) {
      _addResult('Dart SDK', '❌', 'Error: $e');
      hasErrors = true;
    }
  }

  Future<void> _checkJavaJDK() async {
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('cmd', ['/c', 'java', '-version']);
      } else {
        result = await Process.run('java', ['-version']);
      }

      if (result.exitCode == 0) {
        final output = result.stderr.toString();
        final versionMatch = RegExp(r'version "(\d+)').firstMatch(output);
        if (versionMatch != null) {
          final majorVersion = int.parse(versionMatch.group(1)!);
          if (majorVersion >= 17) {
            _addResult('Java JDK', '✅', 'Version $majorVersion (>= 17)');
          } else {
            _addResult('Java JDK', '❌', 'Version $majorVersion < 17 required');
            hasErrors = true;
          }
        } else {
          _addResult('Java JDK', '⚠️', 'Version parsing failed');
        }
      } else {
        _addResult('Java JDK', '❌', 'Java command not found');
        hasErrors = true;
      }
    } catch (e) {
      _addResult('Java JDK', '❌', 'Error: $e');
      hasErrors = true;
    }
  }

  Future<void> _checkAndroidSDK() async {
    final localPropsFile = File('android/local.properties');
    if (await localPropsFile.exists()) {
      final content = await localPropsFile.readAsString();
      final sdkDirMatch = RegExp(r'sdk\.dir=(.+)').firstMatch(content);
      if (sdkDirMatch != null) {
        final sdkPath = sdkDirMatch.group(1)!.replaceAll('\\\\', '\\');
        final sdkDir = Directory(sdkPath);
        if (await sdkDir.exists()) {
          _addResult('Android SDK', '✅', 'Found at $sdkPath');
        } else {
          _addResult('Android SDK', '❌', 'Path not found: $sdkPath');
          hasErrors = true;
        }
      } else {
        _addResult('Android SDK', '❌', 'sdk.dir not found in local.properties');
        hasErrors = true;
      }
    } else {
      _addResult('Android SDK', '❌', 'local.properties file missing');
      hasErrors = true;
    }
  }

  Future<void> _checkGradleVersion() async {
    try {
      final androidDir = Directory('android');
      if (await androidDir.exists()) {
        final gradlewFile = File(
            Platform.isWindows ? 'android/gradlew.bat' : 'android/gradlew');
        if (await gradlewFile.exists()) {
          ProcessResult result;
          if (Platform.isWindows) {
            result = await Process.run(
                'cmd', ['/c', 'gradlew.bat', '--version'],
                workingDirectory: 'android');
          } else {
            result = await Process.run('./gradlew', ['--version'],
                workingDirectory: 'android');
          }

          if (result.exitCode == 0) {
            final output = result.stdout.toString();
            final versionMatch =
                RegExp(r'Gradle (\d+\.\d+)').firstMatch(output);
            if (versionMatch != null) {
              final version = versionMatch.group(1)!;
              _addResult('Gradle', '✅', 'Version $version');
            } else {
              _addResult('Gradle', '⚠️', 'Version parsing failed');
            }
          } else {
            _addResult('Gradle', '❌', 'Gradle execution failed');
            hasErrors = true;
          }
        } else {
          _addResult('Gradle', '❌', 'Gradle wrapper not found');
          hasErrors = true;
        }
      } else {
        _addResult('Gradle', '❌', 'Android directory not found');
        hasErrors = true;
      }
    } catch (e) {
      _addResult('Gradle', '❌', 'Error: $e');
      hasErrors = true;
    }
  }

  Future<void> _checkFirebaseConfig() async {
    final googleServicesFile = File('android/app/google-services.json');
    if (await googleServicesFile.exists()) {
      try {
        final content = await googleServicesFile.readAsString();
        final config = jsonDecode(content);
        final packageName = config['client']?[0]?['client_info']
            ?['android_client_info']?['package_name'];
        if (packageName == 'com.wawapp.client') {
          _addResult('Firebase Config', '✅', 'google-services.json valid');
        } else {
          _addResult(
              'Firebase Config', '⚠️', 'Package name mismatch: $packageName');
        }
      } catch (e) {
        _addResult('Firebase Config', '❌', 'Invalid JSON: $e');
        hasErrors = true;
      }
    } else {
      _addResult('Firebase Config', '❌', 'google-services.json missing');
      hasErrors = true;
    }
  }

  Future<void> _checkFirebaseOptions() async {
    final firebaseOptionsFile = File('lib/firebase_options.dart');
    if (await firebaseOptionsFile.exists()) {
      final content = await firebaseOptionsFile.readAsString();
      if (content.contains('DefaultFirebaseOptions') &&
          content.contains('android') &&
          content.contains('projectId')) {
        _addResult('Firebase Options', '✅', 'firebase_options.dart configured');
      } else {
        _addResult('Firebase Options', '❌', 'firebase_options.dart incomplete');
        hasErrors = true;
      }
    } else {
      _addResult('Firebase Options', '❌', 'firebase_options.dart missing');
      hasErrors = true;
    }
  }

  Future<void> _checkAndroidManifest() async {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (await manifestFile.exists()) {
      final content = await manifestFile.readAsString();
      final hasInternet = content.contains('android.permission.INTERNET');
      final hasNetworkState =
          content.contains('android.permission.ACCESS_NETWORK_STATE');

      if (hasInternet && hasNetworkState) {
        _addResult('Android Permissions', '✅', 'Required permissions present');
      } else {
        final missing = <String>[];
        if (!hasInternet) missing.add('INTERNET');
        if (!hasNetworkState) missing.add('ACCESS_NETWORK_STATE');
        _addResult(
            'Android Permissions', '❌', 'Missing: ${missing.join(', ')}');
        hasErrors = true;
      }
    } else {
      _addResult('Android Permissions', '❌', 'AndroidManifest.xml missing');
      hasErrors = true;
    }
  }

  Future<void> _checkPubspecDependencies() async {
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      final requiredDeps = [
        'firebase_core',
        'firebase_auth',
        'cloud_firestore',
        'firebase_messaging'
      ];

      final missing =
          requiredDeps.where((dep) => !content.contains('$dep:')).toList();

      if (missing.isEmpty) {
        _addResult(
            'Firebase Dependencies', '✅', 'All required dependencies present');
      } else {
        _addResult(
            'Firebase Dependencies', '❌', 'Missing: ${missing.join(', ')}');
        hasErrors = true;
      }
    } else {
      _addResult('Firebase Dependencies', '❌', 'pubspec.yaml missing');
      hasErrors = true;
    }
  }

  Future<void> _checkFirebaseConnectivity() async {
    try {
      // Simple network connectivity test
      final pingArgs = Platform.isWindows
          ? ['-n', '1', 'firebase.google.com']
          : ['-c', '1', 'firebase.google.com'];
      final result = await Process.run('ping', pingArgs);
      if (result.exitCode == 0) {
        _addResult('Network Connectivity', '✅', 'Firebase reachable');
      } else {
        _addResult(
            'Network Connectivity', '⚠️', 'Firebase unreachable (offline?)');
      }
    } catch (e) {
      _addResult('Network Connectivity', '⚠️', 'Network test failed');
    }
  }

  void _addResult(String check, String status, String message) {
    results.add(CheckResult(check, status, message));
  }

  void _printResults() {
    print('📋 Check Results:');
    print('=' * 60);

    for (final result in results) {
      final padding = ' ' * (25 - result.check.length);
      print('${result.check}$padding ${result.status} ${result.message}');
    }

    final passed = results.where((r) => r.status == '✅').length;
    final warnings = results.where((r) => r.status == '⚠️').length;
    final errors = results.where((r) => r.status == '❌').length;

    print('=' * 60);
    print('Summary: $passed passed, $warnings warnings, $errors errors');
  }
}

class CheckResult {
  final String check;
  final String status;
  final String message;

  CheckResult(this.check, this.status, this.message);
}
