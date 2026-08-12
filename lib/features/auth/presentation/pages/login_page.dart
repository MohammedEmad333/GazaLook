import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/phone_validator.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/phone_number_field.dart';

/// Onboarding / login screen: welcome copy, phone-number entry with a
/// +970/+972 selector, and a "Browse as Guest" shortcut.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();
  String _prefix = AppConstants.phonePrefixPS;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String raw = _controller.text;
    final String? error = PhoneValidator.validationError(raw);
    setState(() => _errorText = error);
    if (error != null) return;

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthOtpRequested(
            phoneNumberE164: PhoneValidator.toE164(raw, _prefix),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          final String? message = state.errorMessage;
          if (message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          final bool busy = state.isSubmitting;
          return Stack(
            children: <Widget>[
              // Warm gradient backdrop (asset-free, low-bandwidth friendly).
              const _GradientBackdrop(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.containerMargin),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: AppDimensions.sectionGap * 2),
                        _Header(theme: theme),
                        const SizedBox(height: AppDimensions.sectionGap),
                        _LoginCard(
                          child: Column(
                            children: <Widget>[
                              PhoneNumberField(
                                controller: _controller,
                                selectedPrefix: _prefix,
                                enabled: !busy,
                                errorText: _errorText,
                                onPrefixChanged: (String value) =>
                                    setState(() => _prefix = value),
                                onSubmitted: _submit,
                              ),
                              const SizedBox(height: AppDimensions.stackBase),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: busy ? null : _submit,
                                  child: busy
                                      ? const _ButtonSpinner()
                                      : const Text('دخول'),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.stackBase),
                              const Divider(),
                              TextButton.icon(
                                onPressed: busy
                                    ? null
                                    : () => context
                                        .read<AuthBloc>()
                                        .add(const AuthGuestRequested()),
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: const Text('تصفح كضيف'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'أهلاً بك في ${AppConstants.appName}',
          textAlign: TextAlign.center,
          style: theme.textTheme.displayMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppDimensions.stackBase),
        Text(
          'موضة غزة المحلية بين يديك',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppDimensions.stackTight),
        Text(
          'Local Gaza Fashion in your hands',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(color: AppColors.outline),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.containerMargin + 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderRadiusXl,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GradientBackdrop extends StatelessWidget {
  const _GradientBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.primaryFixed,
            AppColors.background,
            AppColors.background,
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.onPrimaryContainer,
      ),
    );
  }
}
