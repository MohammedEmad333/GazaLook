import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_tile.dart';

/// Shopping cart screen: line items with quantity steppers + delete, and a
/// sticky summary that leads into checkout.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات')),
      bottomNavigationBar: const AppBottomNavBar(current: AppTab.cart),
      body: BlocBuilder<CartCubit, List<CartItem>>(
        builder: (BuildContext context, List<CartItem> items) {
          if (items.isEmpty) {
            return _EmptyCart(onBrowse: () => context.go(AppRoutes.home));
          }
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.containerMargin,
                    vertical: AppDimensions.stackBase,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) =>
                      CartItemTile(item: items[index]),
                ),
              ),
              _CartSummaryBar(
                subtotal: context.read<CartCubit>().subtotal,
                itemCount: context.read<CartCubit>().itemCount,
                onCheckout: () => context.push(AppRoutes.checkout),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const EmptyView(
            message: 'سلة المشتريات فارغة',
            icon: Icons.shopping_cart_outlined,
          ),
          const SizedBox(height: AppDimensions.componentPadding),
          FilledButton(
            onPressed: onBrowse,
            child: const Text('تصفّح المنتجات'),
          ),
        ],
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({
    required this.subtotal,
    required this.itemCount,
    required this.onCheckout,
  });

  final double subtotal;
  final int itemCount;
  final VoidCallback onCheckout;

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
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.containerMargin),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('المجموع الفرعي', style: theme.textTheme.bodySmall),
                Text(
                  CurrencyFormatter.format(subtotal),
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              // The global filledButton theme sets `minimumSize` via
              // `Size.fromHeight`, which leaves the width unbounded (infinity).
              // As a non-flex child of this Row the button is measured with
              // unbounded width, so that infinity propagates and layout throws
              // ("BoxConstraints forces an infinite width"), freezing the cart.
              // Pin a finite minimum width so it sizes to its content instead.
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppDimensions.buttonHeight),
              ),
              onPressed: onCheckout,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text('المتابعة للدفع ($itemCount)'),
            ),
          ],
        ),
      ),
    );
  }
}
