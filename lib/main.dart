import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

/// Entry point for GazaLook.
///
/// Prepares the Flutter binding, locks to portrait for a phone-first shopping
/// experience, initialises dependency injection (which loads the persisted
/// session store), then hands off to [GazaLookApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Register data sources, repositories, use cases and blocs.
  await initDependencies();

  runApp(const GazaLookApp());
}
