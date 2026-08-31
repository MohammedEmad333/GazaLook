import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../orders/domain/entities/order_enums.dart';
import '../../domain/entities/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/checkout_cubit.dart';

/// Localized checkout: Gaza governorate + address, payment method
/// (Cash on Delivery default, e-wallet slots), order summary and placement.
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CheckoutCubit>(
      create: (_) => sl<CheckoutCubit>(),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView();

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onOrderPlaced(BuildContext context) async {
    context.read<CartCubit>().clear();
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle,
            color: AppColors.tertiary, size: 48),
        title: const Text('تم استلام طلبك'),
        content: const Text(
          'سنتواصل معك لتأكيد التوصيل. شكراً لدعمك المتاجر المحلية في غزة!',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
    if (context.mounted) context.go(AppRoutes.orders);
  }

  @override
  Widget build(BuildContext context) {
    final List<CartItem> items = context.watch<CartCubit>().state;
    final double subtotal = context.read<CartCubit>().subtotal;

    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen: (CheckoutState p, CheckoutState c) => p.status != c.status,
      listener: (BuildContext context, CheckoutState state) {
        if (state.status == CheckoutStatus.success) {
          _onOrderPlaced(context);
        } else if (state.status == CheckoutStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (BuildContext context, CheckoutState state) {
        final CheckoutCubit cubit = context.read<CheckoutCubit>();
        final double total = subtotal + state.deliveryFee;

        return Scaffold(
          appBar: AppBar(title: const Text('إتمام الطلب')),
          bottomNavigationBar: _PlaceOrderBar(
            total: total,
            submitting: state.status == CheckoutStatus.submitting,
            onPlace: items.isEmpty
                ? null
                : () => cubit.submit(items: items, subtotal: subtotal),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimensions.containerMargin),
            children: <Widget>[
              // Delivery
              _SectionCard(
                icon: Icons.local_shipping_outlined,
                title: 'التوصيل',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _FieldLabel('المحافظة'),
                    DropdownButtonFormField<Governorate>(
                      value: state.governorate,
                      isExpanded: true,
                      items: <DropdownMenuItem<Governorate>>[
                        for (final Governorate g in Governorate.values)
                          DropdownMenuItem<Governorate>(
                            value: g,
                            child: Text(g.labelAr),
                          ),
                      ],
                      onChanged: (Governorate? g) {
                        if (g != null) cubit.selectGovernorate(g);
                      },
                    ),
                    const SizedBox(height: AppDimensions.componentPadding),
                    const _FieldLabel('العنوان التفصيلي'),
                    TextField(
                      controller: _addressController,
                      onChanged: cubit.updateAddress,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'الشارع، البناية، رقم الشقة...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.componentPadding),

              // Payment
              _SectionCard(
                icon: Icons.payments_outlined,
                title: 'طريقة الدفع',
                child: Column(
                  children: <Widget>[
                    for (final PaymentMethod m in PaymentMethod.values)
                      _PaymentTile(
                        method: m,
                        selected: state.paymentMethod == m,
                        onTap: () => cubit.selectPayment(m),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.componentPadding),

              // Summary
              _SectionCard(
                icon: Icons.receipt_long_outlined,
                title: 'ملخص الطلب',
                child: Column(
                  children: <Widget>[
                    _SummaryRow(
                      label: 'المجموع الفرعي',
                      value: CurrencyFormatter.format(subtotal),
                    ),
                    _SummaryRow(
                      label: 'رسوم التوصيل (${state.governorate.labelAr})',
                      value: CurrencyFormatter.format(state.deliveryFee),
                    ),
                    const Divider(height: AppDimensions.sectionGap),
                    _SummaryRow(
                      label: 'الإجمالي',
                      value: CurrencyFormatter.format(total),
                      emphasize: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.componentPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppDimensions.borderRadiusXl,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.onSurface),
              const SizedBox(width: AppDimensions.stackBase),
              Expanded(child: Text(title, style: theme.textTheme.headlineMedium)),
            ],
          ),
          const SizedBox(height: AppDimensions.componentPadding),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackTight),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = !method.available;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: AppDimensions.borderRadiusLg,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.stackBase),
          padding: const EdgeInsets.all(AppDimensions.componentPadding),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer.withOpacity(0.12) : null,
            borderRadius: AppDimensions.borderRadiusLg,
            border: Border.all(
              color: selected
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.outline,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.componentPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      method.labelAr,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(method.subtitleAr, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (disabled)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text('قريباً', style: theme.textTheme.labelMedium),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle? style = emphasize
        ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.stackTight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: AppDimensions.stackBase),
          Text(
            value,
            style: emphasize
                ? theme.textTheme.headlineMedium
                    ?.copyWith(color: AppColors.primary)
                : style,
          ),
        ],
      ),
    );
  }
}

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.total,
    required this.submitting,
    required this.onPlace,
  });

  final double total;
  final bool submitting;
  final VoidCallback? onPlace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.containerMargin),
          child: Row(
            children: <Widget>[
              Column(
                // A bottomNavigationBar is laid out with a loose, full-height
                // constraint. Without min, this Column expands to fill the whole
                // screen, squeezing the checkout body to zero height (blank page
                // with the total pushed to the top). Shrink-wrap to its content.
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('الإجمالي', style: theme.textTheme.bodySmall),
                  Text(
                    CurrencyFormatter.format(total),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                // See CartPage: the themed `minimumSize` leaves width unbounded,
                // which throws "forces an infinite width" for a non-flex Row
                // child. Pin a finite minimum width so it hugs its content.
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppDimensions.buttonHeight),
                ),
                onPressed: submitting ? null : onPlace,
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('إتمام الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
