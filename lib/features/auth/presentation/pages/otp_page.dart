import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/otp_input_field.dart';

/// OTP verification screen. Shows the destination phone number, a 4-digit code
/// entry, verify/resend actions, and graceful error handling.
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final GlobalKey<OtpInputFieldState> _otpKey =
      GlobalKey<OtpInputFieldState>();
  String _code = '';

  void _verify(String code) {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(AuthOtpSubmitted(code: code));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthPhoneEntryRequested()),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          final String? message = state.errorMessage;
          if (message != null) {
            _otpKey.currentState?.clear();
            setState(() => _code = '');
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          final bool busy = state.isSubmitting;
          final String phone = state.pendingPhoneNumber ?? '';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: AppDimensions.sectionGap),
                    Icon(Icons.sms_outlined, size: 56, color: theme.colorScheme.primary),
                    const SizedBox(height: AppDimensions.stackBase),
                    Text(
                      'أدخل رمز التحقق',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppDimensions.stackTight),
                    Text.rich(
                      TextSpan(
                        text: 'تم إرسال رمز مكوّن من 4 أرقام إلى\n',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                        children: <InlineSpan>[
                          TextSpan(
                            text: phone,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sectionGap),
                    OtpInputField(
                      key: _otpKey,
                      enabled: !busy,
                      onChanged: (String value) => setState(() => _code = value),
                      onCompleted: _verify,
                    ),
                    const SizedBox(height: AppDimensions.sectionGap),
                    ElevatedButton(
                      onPressed: (busy || _code.length < 4)
                          ? null
                          : () => _verify(_code),
                      child: busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onPrimaryContainer,
                              ),
                            )
                          : const Text('تأكيد'),
                    ),
                    const SizedBox(height: AppDimensions.stackBase),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () {
                              _otpKey.currentState?.clear();
                              setState(() => _code = '');
                              context.read<AuthBloc>().add(
                                    AuthOtpRequested(phoneNumberE164: phone),
                                  );
                            },
                      child: const Text('إعادة إرسال الرمز'),
                    ),
                    // Demo helper — visible only in debug builds while the OTP
                    // provider is mocked.
                    if (kDebugMode) ...<Widget>[
                      const SizedBox(height: AppDimensions.stackBase),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.componentPadding),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withOpacity(0.4),
                          borderRadius: AppDimensions.borderRadiusLg,
                        ),
                        child: Text(
                          'وضع التجربة: استخدم الرمز ${MockAuthRemoteDataSource.demoCode}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
