import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class BuildInfo {
  final String version;
  final String commit;
  final String branch;
  final String flavor;
  final String flutter;

  const BuildInfo({
    required this.version,
    required this.commit,
    required this.branch,
    required this.flavor,
    required this.flutter,
  });

  String get shortCommit => commit.length > 7 ? commit.substring(0, 7) : commit;

  String get bannerText => '$branch@$shortCommit | $version | $flavor';
}

class BuildInfoProvider {
  static BuildInfo? _instance;

  static BuildInfo get instance =>
      _instance ??
      const BuildInfo(
        version: 'unknown',
        commit: 'unknown',
        branch: 'unknown',
        flavor: 'default',
        flutter: 'unknown',
      );

  static Future<void> initialize() async {
    try {
      final version = await _getVersion();
      final commit = await _getGitCommit();
      final branch = await _getGitBranch();
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'default');
      const flutter = String.fromEnvironment('FLUTTER_VER', defaultValue: '');

      _instance = BuildInfo(
        version: version,
        commit: commit,
        branch: branch,
        flavor: flavor,
        flutter: flutter.isEmpty ? await _getFlutterVersion() : flutter,
      );
    } catch (e) {
      if (kDebugMode) print('BuildInfo init failed: $e');
    }
  }

  static Future<String> _getVersion() async {
    try {
      final pubspec = await rootBundle.loadString('pubspec.yaml');
      final yaml = loadYaml(pubspec);
      return yaml['version']?.toString().split('+').first ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  static Future<String> _getGitCommit() async {
    try {
      final result = await Process.run('git', ['rev-parse', 'HEAD']);
      return result.exitCode == 0 ? result.stdout.toString().trim() : 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  static Future<String> _getGitBranch() async {
    try {
      final result =
          await Process.run('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
      return result.exitCode == 0 ? result.stdout.toString().trim() : 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  static Future<String> _getFlutterVersion() async {
    try {
      final result = await Process.run('flutter', ['--version', '--machine']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match =
            RegExp(r'"frameworkVersion":"([^"]+)"').firstMatch(output);
        return match?.group(1) ?? 'unknown';
      }
    } catch (e) {
      // Ignore
    }
    return 'unknown';
  }
}
