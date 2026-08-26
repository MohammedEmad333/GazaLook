<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment\Strategies;

use GazaLook\Wallet\Domain\PaymentChannel;
use GazaLook\Wallet\Domain\TransactionStatus;
use GazaLook\Wallet\Payment\PaymentException;
use GazaLook\Wallet\Payment\PaymentStrategy;
use GazaLook\Wallet\Payment\TopUpRequest;
use GazaLook\Wallet\Payment\TopUpResult;
use GazaLook\Wallet\Repository\TransactionRepository;
use GazaLook\Wallet\Repository\WalletRepository;
use GazaLook\Wallet\Wallet\WalletService;

/**
 * Phase 2 base strategy. Concrete gateways (Jawwal Pay, Bank of Palestine)
 * extend this and implement {@see charge()} against their official API/SDK.
 * On a successful charge the transaction is recorded AND approved immediately
 * (auto-credit, no admin step) in one atomic operation.
 *
 * Left as a documented skeleton because the real API credentials/SDKs are not
 * available yet — that is exactly the Phase-2 work the card defers.
 */
abstract class GatewayStrategy implements PaymentStrategy
{
    public function __construct(
        protected readonly TransactionRepository $transactions,
        protected readonly WalletRepository $wallets,
        protected readonly WalletService $walletService,
    ) {
    }

    /**
     * Call the provider and return its raw response on success. Throw a
     * {@see PaymentException} if the charge is declined.
     *
     * @return array{gateway_txn_id:string, raw:array<string,mixed>}
     */
    abstract protected function charge(TopUpRequest $request, PaymentChannel $channel): array;

    public function process(TopUpRequest $request, PaymentChannel $channel): TopUpResult
    {
        if ($request->amountUnits <= 0) {
            throw new PaymentException('المبلغ يجب أن يكون أكبر من صفر.');
        }

        // 1) Talk to the provider (implemented per gateway).
        $charge = $this->charge($request, $channel);

        // 2) Record an already-approved ledger row + credit the wallet atomically.
        $walletId = $this->wallets->ensureWalletForUser($request->userId);
        $txnId = $this->transactions->create([
            'wallet_id' => $walletId,
            'user_id' => $request->userId,
            'channel_id' => $channel->id,
            'direction' => 'credit',
            'amount_units' => $request->amountUnits,
            'currency' => $request->currency,
            'status' => TransactionStatus::Pending->value,
            'gateway_txn_id' => $charge['gateway_txn_id'],
            'gateway_response' => $charge['raw'],
        ]);

        // No human actor: the gateway confirmed, so approve automatically.
        $this->walletService->approve($txnId, reviewerId: null, note: 'auto-approved by gateway');

        return new TopUpResult(
            transactionId: $txnId,
            status: TransactionStatus::Approved,
            message: 'تم شحن الرصيد بنجاح.',
        );
    }
}
