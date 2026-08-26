<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment;

use GazaLook\Wallet\Domain\TransactionStatus;

/** Outcome of {@see PaymentService::topUp()}. */
final class TopUpResult
{
    public function __construct(
        public readonly int $transactionId,
        public readonly TransactionStatus $status,
        public readonly string $message,
    ) {
    }

    /** @return array<string,mixed> */
    public function toArray(): array
    {
        return [
            'transaction_id' => $this->transactionId,
            'status' => $this->status->value,
            'message' => $this->message,
        ];
    }
}
