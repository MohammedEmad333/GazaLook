import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_enums.dart';
import '../cubit/orders_cubit.dart';

/// Order history screen — lists previously placed orders, most recent first.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrdersCubit>(
      create: (_) => sl<OrdersCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('طلباتي')),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (BuildContext context, OrdersState state) {
            switch (state.status) {
              case OrdersStatus.initial:
              case OrdersStatus.loading:
                return const LoadingView();
              case OrdersStatus.failure:
                return ErrorView(
                  message: state.message ?? 'تعذّر تحميل الطلبات.',
                  onRetry: () => context.read<OrdersCubit>().load(),
                );
              case OrdersStatus.empty:
                return const EmptyView(
                  message: 'لا توجد طلبات سابقة بعد.',
                  icon: Icons.receipt_long_outlined,
                );
              case OrdersStatus.success:
                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.containerMargin),
                  itemCount: state.orders.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.componentPadding),
                  itemBuilder: (BuildContext context, int index) =>
                      _OrderCard(order: state.orders[index]),
                );
            }
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String date =
        DateFormat('yyyy/MM/dd — HH:mm').format(order.createdAt);

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
              Expanded(
                child: Text(
                  order.id,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: AppDimensions.stackTight),
          Text(date, style: theme.textTheme.bodySmall),
          const Divider(height: AppDimensions.sectionGap),
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            text: '${order.itemCount} قطعة',
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: order.governorate.labelAr,
          ),
          _InfoRow(
            icon: Icons.payments_outlined,
            text: order.paymentMethod.labelAr,
          ),
          const SizedBox(height: AppDimensions.stackBase),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('الإجمالي', style: theme.textTheme.bodyMedium),
              Text(
                CurrencyFormatter.format(order.total),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppDimensions.stackBase),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        status.labelAr,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSecondaryContainer,
            ),
      ),
    );
  }
}
