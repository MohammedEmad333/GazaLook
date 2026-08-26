import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/top_up_status.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../cubit/wallet_cubit.dart';

/// Wallet home: shows the approved balance and the top-up history, with a
/// button that opens the "شحن الرصيد" flow.
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletCubit>.value(
      value: sl<WalletCubit>()..load(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محفظتي')),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (BuildContext context, WalletState state) {
          if (state.status == WalletStatus.loading ||
              state.status == WalletStatus.initial) {
            return const LoadingView();
          }
          if (state.status == WalletStatus.failure) {
            return ErrorView(
              message: 'تعذّر تحميل المحفظة.',
              onRetry: () => context.read<WalletCubit>().load(),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.containerMargin),
            children: <Widget>[
              _BalanceCard(balance: state.balance),
              const SizedBox(height: AppDimensions.sectionGap),
              FilledButton.icon(
                onPressed: () async {
                  await context.push(AppRoutes.walletTopUp);
                  if (context.mounted) context.read<WalletCubit>().load();
                },
                icon: const Icon(Icons.add_card_outlined),
                label: const Text('شحن الرصيد'),
              ),
              const SizedBox(height: AppDimensions.sectionGap),
              Text(
                'سجل العمليات',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),
              const SizedBox(height: AppDimensions.componentPadding),
              if (state.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppDimensions.sectionGap),
                  child: EmptyView(
                    message: 'لا توجد عمليات شحن بعد',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                )
              else
                for (final WalletTransaction t in state.transactions)
                  _TransactionTile(txn: t),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.sectionGap),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppDimensions.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'الرصيد المتاح',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.onPrimaryContainer),
          ),
          const SizedBox(height: AppDimensions.stackBase),
          Text(
            CurrencyFormatter.format(balance),
            style: theme.textTheme.displayMedium
                ?.copyWith(color: AppColors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.txn});

  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackBase),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.componentPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppDimensions.borderRadiusXl,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.account_balance_outlined,
                color: AppColors.primary),
            const SizedBox(width: AppDimensions.componentPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    txn.channelNameAr,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (txn.transactionRef != null)
                    Text('رقم العملية: ${txn.transactionRef}',
                        style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  CurrencyFormatter.format(txn.amount),
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                _StatusChip(status: txn.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TopUpStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      TopUpStatus.pending => (AppColors.secondaryContainer, AppColors.onSecondaryContainer),
      TopUpStatus.approved => (AppColors.tertiaryContainer, AppColors.onTertiaryContainer),
      TopUpStatus.rejected => (AppColors.errorContainer, AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        status.labelAr,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: fg),
      ),
    );
  }
}
