<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Domain;

/** A funding source row from `payment_channels` (Bank of Palestine, etc.). */
final class PaymentChannel
{
    public function __construct(
        public readonly int $id,
        public readonly string $code,
        public readonly string $nameAr,
        public readonly string $nameEn,
        public readonly ChannelMode $mode,
        public readonly ?string $accountRef,
        public readonly bool $isActive,
    ) {
    }

    /** @param array<string,mixed> $row */
    public static function fromRow(array $row): self
    {
        return new self(
            id: (int) $row['id'],
            code: (string) $row['code'],
            nameAr: (string) $row['name_ar'],
            nameEn: (string) $row['name_en'],
            mode: ChannelMode::from((string) $row['mode']),
            accountRef: $row['account_ref'] !== null ? (string) $row['account_ref'] : null,
            isActive: (bool) $row['is_active'],
        );
    }

    /** @return array<string,mixed> */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name_ar' => $this->nameAr,
            'name_en' => $this->nameEn,
            'mode' => $this->mode->value,
            'account_ref' => $this->accountRef,
            'is_active' => $this->isActive,
        ];
    }
}
