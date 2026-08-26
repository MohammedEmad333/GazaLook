import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// The account screen: who is signed in, quick links to orders / wishlist /
/// reviews, local support contact, and sign-out (or sign-in for guests).
///
/// Reads the app-wide [AuthBloc]; no additional data source is needed.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthUser? user = context.select((AuthBloc b) => b.state.user);
    final bool isGuest = user?.isGuest ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      bottomNavigationBar: const AppBottomNavBar(current: AppTab.profile),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.containerMargin),
        children: <Widget>[
          _ProfileHeader(user: user, isGuest: isGuest),
          const SizedBox(height: AppDimensions.sectionGap),

          _MenuTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'محفظتي وشحن الرصيد',
            onTap: () => context.push(AppRoutes.wallet),
          ),
          _MenuTile(
            icon: Icons.receipt_long_outlined,
            label: 'طلباتي',
            onTap: () => context.push(AppRoutes.orders),
          ),
          _MenuTile(
            icon: Icons.favorite_border,
            label: 'المفضلة',
            onTap: () => context.go(AppRoutes.wishlist),
          ),
          _MenuTile(
            icon: Icons.star_border,
            label: 'تقييماتي',
            onTap: () => _showComingSoon(context, 'تقييماتي'),
          ),
          _MenuTile(
            icon: Icons.support_agent_outlined,
            label: 'التواصل مع الدعم المحلي',
            onTap: () => _showSupportSheet(context),
          ),

          const SizedBox(height: AppDimensions.sectionGap),
          OutlinedButton.icon(
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
            icon: Icon(isGuest ? Icons.login : Icons.logout),
            label: Text(isGuest ? 'تسجيل الدخول' : 'تسجيل الخروج'),
          ),
          const SizedBox(height: AppDimensions.stackBase),
          Center(
            child: Text(
              'GazaLook',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature — قريباً')));
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.containerMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('التواصل مع الدعم المحلي',
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.stackBase),
                Text(
                  'فريق GazaLook جاهز لمساعدتك في الطلبات والتوصيل داخل غزة.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppDimensions.componentPadding),
                const _ContactRow(
                  icon: Icons.chat_outlined,
                  label: 'واتساب',
                  value: '+970 59 000 0000',
                ),
                const _ContactRow(
                  icon: Icons.phone_outlined,
                  label: 'هاتف',
                  value: '+970 8 000 0000',
                ),
                const _ContactRow(
                  icon: Icons.email_outlined,
                  label: 'البريد الإلكتروني',
                  value: 'support@gazalook.ps',
                ),
                const SizedBox(height: AppDimensions.stackBase),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.isGuest});

  final AuthUser? user;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String name = isGuest
        ? 'زائر'
        : (user?.displayName?.isNotEmpty ?? false
            ? user!.displayName!
            : 'مستخدم GazaLook');

    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.primaryContainer,
          child: Icon(
            isGuest ? Icons.person_outline : Icons.person,
            size: 34,
            color: AppColors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppDimensions.containerMargin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppDimensions.stackTight),
              Text(
                isGuest
                    ? 'سجّل الدخول لحفظ طلباتك ومفضلتك'
                    : (user?.phoneNumber ?? ''),
                textDirection:
                    isGuest ? TextDirection.rtl : TextDirection.ltr,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackBase),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppDimensions.borderRadiusXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.borderRadiusXl,
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.componentPadding),
            decoration: BoxDecoration(
              borderRadius: AppDimensions.borderRadiusXl,
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppDimensions.componentPadding),
                Expanded(
                  child: Text(label, style: theme.textTheme.bodyLarge),
                ),
                const Icon(
                  Icons.chevron_left,
                  color: AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.stackBase),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppDimensions.componentPadding),
          Text('$label: ', style: theme.textTheme.bodyMedium),
          Expanded(
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
