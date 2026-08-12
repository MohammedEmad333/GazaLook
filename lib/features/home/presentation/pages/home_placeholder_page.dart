import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Temporary landing screen shown after authentication.
///
/// Confirms who is signed in (real user or guest) and offers sign-out, so the
/// full auth flow is verifiable. Phase 3 replaces this with the real Home feed.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthUser? user = context.select((AuthBloc b) => b.state.user);
    final bool isGuest = user?.isGuest ?? true;
    final String subtitle = isGuest
        ? 'أنت تتصفح كضيف'
        : 'مرحباً ${user?.phoneNumber ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: <Widget>[
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sectionGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isGuest ? Icons.person_outline : Icons.verified_user_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppDimensions.stackBase),
              Text('الرئيسية', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppDimensions.stackTight),
              Text(
                subtitle,
                textDirection: TextDirection.ltr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.stackBase),
              Text(
                'واجهة الصفحة الرئيسية قيد الإنشاء (المرحلة 3)',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
