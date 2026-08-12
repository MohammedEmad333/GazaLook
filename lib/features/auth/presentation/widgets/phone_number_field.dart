import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/phone_validator.dart';

/// Phone entry field with a dialing-code selector (+970 / +972), mirroring the
/// onboarding mock-up. The code sits on the trailing (right, in RTL) edge.
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.selectedPrefix,
    required this.onPrefixChanged,
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String selectedPrefix;
  final ValueChanged<String> onPrefixChanged;
  final String? errorText;
  final bool enabled;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      style: theme.textTheme.bodyLarge,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
        LengthLimitingTextInputFormatter(12),
      ],
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: '59 123 4567',
        errorText: errorText,
        prefixIcon: _PrefixSelector(
          selectedPrefix: selectedPrefix,
          enabled: enabled,
          onChanged: onPrefixChanged,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 96),
      ),
    );
  }
}

/// The tappable dialing-code dropdown shown inside the field.
class _PrefixSelector extends StatelessWidget {
  const _PrefixSelector({
    required this.selectedPrefix,
    required this.onChanged,
    required this.enabled,
  });

  final String selectedPrefix;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.call_outlined, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedPrefix,
              isDense: true,
              onChanged: enabled
                  ? (String? value) {
                      if (value != null) onChanged(value);
                    }
                  : null,
              style: theme.textTheme.bodyLarge,
              items: PhoneValidator.supportedPrefixes
                  .map(
                    (String prefix) => DropdownMenuItem<String>(
                      value: prefix,
                      child: Text(prefix, textDirection: TextDirection.ltr),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }
}
