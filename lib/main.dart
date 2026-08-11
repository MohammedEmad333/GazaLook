import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// Entry point for GazaLook.
///
/// Kept intentionally thin: it prepares the Flutter binding, locks the app to
/// portrait for a phone-first shopping experience, and hands off to
/// [GazaLookApp]. Heavy initialisation (Hive boxes, dependency injection) is
/// added here as those features land in later phases.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phone-first: lock to portrait like the reference mock-ups.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // TODO(phase-2): initialise Hive + shared_preferences for cart/session cache.
  // TODO(phase-2): configure get_it dependency injection.

  runApp(const GazaLookApp());
}
