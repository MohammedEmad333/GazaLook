import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

/// Root widget for GazaLook.
///
/// Owns the app-wide [AuthBloc] and the [GoRouter] (which redirects on auth
/// changes), and configures theming + Arabic-first (RTL) localization.
class GazaLookApp extends StatefulWidget {
  const GazaLookApp({super.key});

  @override
  State<GazaLookApp> createState() => _GazaLookAppState();
}

class _GazaLookAppState extends State<GazaLookApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Restore any cached session as soon as the app starts.
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    _router = AppRouter.create(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
        locale: const Locale('ar'),
        supportedLocales: const <Locale>[
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
