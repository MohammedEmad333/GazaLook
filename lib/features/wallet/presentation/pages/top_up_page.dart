import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/top_up_channel.dart';
import '../cubit/wallet_cubit.dart';

/// "شحن الرصيد" — Phase 1 manual top-up form: pick a funding channel, enter the
/// amount and the transfer's operation number, attach the receipt screenshot,
/// then submit for admin review.
class TopUpPage extends StatelessWidget {
  const TopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletCubit>.value(
      value: sl<WalletCubit>()..load(),
      child: const _TopUpView(),
    );
  }
}

class _TopUpView extends StatefulWidget {
  const _TopUpView();

  @override
  State<_TopUpView> createState() => _TopUpViewState();
}

class _TopUpViewState extends State<_TopUpView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _refController = TextEditingController();

  TopUpChannel? _channel;
  String? _receiptName;

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  void _attachReceipt() {
    // NOTE(Phase 1): a real image picker (e.g. image_picker) + upload will set
    // this. Kept dependency-free for now — we record a placeholder file name so
    // the flow, validation and admin review can be exercised end to end.
    setState(() {
      _receiptName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }

  Future<void> _submit(WalletCubit cubit) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_channel == null) {
      _snack('اختر طريقة التحويل');
      return;
    }
    if (_receiptName == null) {
      _snack('يرجى إرفاق صورة الإيصال');
      return;
    }

    final double amount = double.parse(_amountController.text.trim());
    final result = await cubit.submitTopUp(
      channel: _channel!,
      amount: amount,
      transactionRef: _refController.text.trim(),
      receiptName: _receiptName,
    );

    if (!mounted) return;
    if (result != null) {
      _snack('تم استلام طلب الشحن وهو قيد المراجعة من الإدارة.');
      context.pop();
    } else {
      _snack('تعذّر إرسال الطلب، حاول مرة أخرى.');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('شحن الرصيد')),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (BuildContext context, WalletState state) {
          final WalletCubit cubit = context.read<WalletCubit>();
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              children: <Widget>[
                Text(
                  'حوّل المبلغ عبر إحدى الطرق التالية ثم أرفق صورة الإيصال ورقم '
                  'العملية ليتم اعتماد الرصيد.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppDimensions.sectionGap),

                Text('طريقة التحويل',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.stackBase),
                DropdownButtonFormField<TopUpChannel>(
                  value: _channel,
                  hint: const Text('اختر الجهة'),
                  items: <DropdownMenuItem<TopUpChannel>>[
                    for (final TopUpChannel c in state.channels)
                      DropdownMenuItem<TopUpChannel>(
                        value: c,
                        child: Text(c.nameAr),
                      ),
                  ],
                  onChanged: (TopUpChannel? c) => setState(() => _channel = c),
                ),
                if (_channel?.accountRef != null) ...<Widget>[
                  const SizedBox(height: AppDimensions.stackBase),
                  _AccountRefHint(channel: _channel!),
                ],
                const SizedBox(height: AppDimensions.componentPadding),

                Text('المبلغ (₪)',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.stackBase),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(hintText: 'مثال: 50'),
                  validator: (String? v) {
                    final double? amount = double.tryParse((v ?? '').trim());
                    if (amount == null || amount <= 0) {
                      return 'أدخل مبلغاً صحيحاً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.componentPadding),

                Text('رقم العملية',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.stackBase),
                TextFormField(
                  controller: _refController,
                  decoration:
                      const InputDecoration(hintText: 'رقم عملية التحويل'),
                  validator: (String? v) =>
                      (v ?? '').trim().isEmpty ? 'رقم العملية مطلوب' : null,
                ),
                const SizedBox(height: AppDimensions.componentPadding),

                _ReceiptPicker(
                  receiptName: _receiptName,
                  onPick: _attachReceipt,
                ),
                const SizedBox(height: AppDimensions.sectionGap),

                FilledButton.icon(
                  onPressed: state.submitting ? null : () => _submit(cubit),
                  icon: state.submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: const Text('إرسال طلب الشحن'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccountRefHint extends StatelessWidget {
  const _AccountRefHint({required this.channel});

  final TopUpChannel channel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.componentPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withOpacity(0.4),
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: AppDimensions.stackBase),
          Expanded(
            child: Text(
              'حوّل إلى ${channel.nameAr}: ${channel.accountRef}',
              style: theme.textTheme.bodySmall,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({required this.receiptName, required this.onPick});

  final String? receiptName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool attached = receiptName != null;
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: Icon(attached ? Icons.check_circle_outline : Icons.upload_file),
      style: OutlinedButton.styleFrom(
        foregroundColor: attached ? AppColors.tertiary : AppColors.primary,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(AppDimensions.componentPadding),
      ),
      label: Align(
        alignment: Alignment.centerRight,
        child: Text(
          attached ? 'تم إرفاق الإيصال' : 'إرفاق صورة الإيصال',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
