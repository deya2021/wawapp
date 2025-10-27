import 'dart:io';

/// أسماء الشاشات المتوقعة في التطبيق.
/// يمكن تحديثها مع إضافة أي شاشة جديدة لاحقاً.
final expectedScreens = [
  'splash_screen.dart',
  'home_screen.dart',
  'quote_screen.dart',
  'track_screen.dart',
  'profile_screen.dart',
  'login_screen.dart',
  'register_screen.dart',
  'settings_screen.dart',
];

void main() async {
  print('🔍 Checking screen files integrity...');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('❌ lib directory not found!');
    exit(1);
  }

  final allFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path)
      .toList();

  final missing = <String>[];
  for (final screen in expectedScreens) {
    final exists = allFiles.any((path) => path.endsWith(screen));
    if (!exists) missing.add(screen);
  }

  if (missing.isEmpty) {
    print('✅ All expected screens exist and are accessible.');
  } else {
    print('⚠️ Missing or renamed screens detected:');
    for (final m in missing) {
      print('   - $m');
    }
    exitCode = 1;
  }

  // التحقق من وجود build method داخل كل شاشة
  for (final path in allFiles.where((p) => p.contains('screen'))) {
    final content = await File(path).readAsString();
    if (!content.contains('Widget build')) {
      print('⚠️ File $path seems incomplete (no build method).');
    }
  }

  print('🔎 Screen verification completed.');
}
