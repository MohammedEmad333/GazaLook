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

/**
 * Phase 1 strategy. The shopper has already transferred the money out-of-band
 * (Bank of Palestine / Jawwal Pay / Bal Pay) and uploads the receipt
 * screenshot + the operation reference number. We record a `pending`
 * transaction; an admin later approves it, which is what actually credits the
 * wallet (see WalletService). Nothing is credited here.
 */
final class ManualReceiptUploadStrategy implements PaymentStrategy
{
    public function __construct(
        private readonly TransactionRepository $transactions,
        private readonly WalletRepository $wallets,
    ) {
    }

    public function key(): string
    {
        return 'manual';
    }

    public function process(TopUpRequest $request, PaymentChannel $channel): TopUpResult
    {
        if ($request->amountUnits <= 0) {
            throw new PaymentException('المبلغ يجب أن يكون أكبر من صفر.');
        }
        if ($request->transactionRef === null || trim($request->transactionRef) === '') {
            throw new PaymentException('رقم العملية مطلوب.');
        }
        if ($request->proofImagePath === null || trim($request->proofImagePath) === '') {
            throw new PaymentException('صورة الإيصال مطلوبة.');
        }

        $walletId = $this->wallets->ensureWalletForUser($request->userId);

        $txnId = $this->transactions->create([
            'wallet_id' => $walletId,
            'user_id' => $request->userId,
            'channel_id' => $channel->id,
            'direction' => 'credit',
            'amount_units' => $request->amountUnits,
            'currency' => $request->currency,
            'status' => TransactionStatus::Pending->value,
            'transaction_ref' => $request->transactionRef,
            'proof_image_path' => $request->proofImagePath,
        ]);

        return new TopUpResult(
            transactionId: $txnId,
            status: TransactionStatus::Pending,
            message: 'تم استلام طلب الشحن وهو قيد المراجعة من الإدارة.',
        );
    }
}
