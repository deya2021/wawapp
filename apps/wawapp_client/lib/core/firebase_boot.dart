import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseBoot {
  static FirebaseApp? _instance;
  static final _lock = Completer<FirebaseApp>();

  static Future<FirebaseApp> ensure() async {
    // Already initialized in this process
    if (_instance != null) return _instance!;
    if (_lock.isCompleted) return Firebase.app();

    try {
      // If any app exists, reuse it (avoid duplicate)
      if (Firebase.apps.isNotEmpty) {
        _instance = Firebase.apps.first;
        if (!_lock.isCompleted) _lock.complete(_instance!);
        return _instance!;
      }

      // First-time initialization
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _instance = app;
      if (!_lock.isCompleted) _lock.complete(app);
      return app;
    } catch (e) {
      // If a race caused duplicate-app, reuse the existing app
      if (e.toString().contains('duplicate-app')) {
        final existing = Firebase.apps.first;
        _instance = existing;
        if (!_lock.isCompleted) _lock.complete(existing);
        return existing;
      }
      rethrow;
    }
  }
}
