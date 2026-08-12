import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// A row of single-digit boxes for entering an OTP.
///
/// Typing a digit auto-advances to the next box; clearing a box (backspace)
/// steps focus back to the previous one. Fires [onCompleted] once full.
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  final int length;

  /// Called with the full code once every box is filled.
  final ValueChanged<String> onCompleted;

  /// Called on every change with the current (possibly partial) code.
  final ValueChanged<String>? onChanged;

  final bool enabled;

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  /// Clears every box and returns focus to the first — used after an error.
  void clear() {
    for (final TextEditingController c in _controllers) {
      c.clear();
    }
    if (mounted) _focusNodes.first.requestFocus();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      // Move forward after entering a digit.
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Step back when a box is cleared.
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged?.call(_code);
    if (_code.length == widget.length) {
      widget.onCompleted(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: List<Widget>.generate(widget.length, (int index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.stackTight),
          child: SizedBox(
            width: 56,
            height: 60,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              autofocus: index == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: AppColors.onSurface),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              decoration: const InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (String value) => _onChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
