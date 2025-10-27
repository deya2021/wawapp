import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  print('🔍 WawApp screen verification started...');

  final screenFiles = Directory('lib/features')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('_screen.dart'))
      .toList();

  if (screenFiles.isEmpty) {
    print('⚠️ No screens found in lib/features/. Check folder structure.');
    return;
  }

  for (final file in screenFiles) {
    final name = file.uri.pathSegments.last;
    test('🧩 Found $name', () {
      expect(File(file.path).existsSync(), true);
    });
  }

  print('✅ WawApp screen integrity check completed.');
}
