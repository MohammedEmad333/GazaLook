<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Domain;

/** A single ledger row from `wallet_transactions`. */
final class WalletTransaction
{
    public function __construct(
        public readonly int $id,
        public readonly int $walletId,
        public readonly int $userId,
        public readonly int $channelId,
        public readonly string $direction,
        public readonly int $amountUnits,
        public readonly string $currency,
        public readonly TransactionStatus $status,
        public readonly ?string $transactionRef,
        public readonly ?string $proofImagePath,
        public readonly ?string $gatewayTxnId,
        public readonly ?string $reviewNote,
        public readonly ?int $reviewedBy,
        public readonly ?string $createdAt,
    ) {
    }

    /** @param array<string,mixed> $row */
    public static function fromRow(array $row): self
    {
        return new self(
            id: (int) $row['id'],
            walletId: (int) $row['wallet_id'],
            userId: (int) $row['user_id'],
            channelId: (int) $row['channel_id'],
            direction: (string) $row['direction'],
            amountUnits: (int) $row['amount_units'],
            currency: (string) $row['currency'],
            status: TransactionStatus::from((string) $row['status']),
            transactionRef: $row['transaction_ref'] ?? null,
            proofImagePath: $row['proof_image_path'] ?? null,
            gatewayTxnId: $row['gateway_txn_id'] ?? null,
            reviewNote: $row['review_note'] ?? null,
            reviewedBy: isset($row['reviewed_by']) ? (int) $row['reviewed_by'] : null,
            createdAt: $row['created_at'] ?? null,
        );
    }

    /** @return array<string,mixed> */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'wallet_id' => $this->walletId,
            'user_id' => $this->userId,
            'channel_id' => $this->channelId,
            'direction' => $this->direction,
            'amount_units' => $this->amountUnits,
            'amount_display' => \GazaLook\Wallet\Support\Money::format($this->amountUnits),
            'currency' => $this->currency,
            'status' => $this->status->value,
            'transaction_ref' => $this->transactionRef,
            'proof_image_path' => $this->proofImagePath,
            'gateway_txn_id' => $this->gatewayTxnId,
            'review_note' => $this->reviewNote,
            'created_at' => $this->createdAt,
        ];
    }
}
