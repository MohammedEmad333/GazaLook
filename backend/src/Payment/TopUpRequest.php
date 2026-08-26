<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment;

/**
 * Immutable input for a top-up. What the shopper submits from the app's
 * "شحن الرصيد" screen. Phase-1 fields (transactionRef, proofImagePath) and
 * Phase-2 fields (gatewayTxnId, gatewayResponse) coexist; each strategy reads
 * only what it needs.
 *
 * @phpstan-type GatewayResponse array<string,mixed>|null
 */
final class TopUpRequest
{
    /** @param array<string,mixed>|null $gatewayResponse */
    public function __construct(
        public readonly int $userId,
        public readonly int $channelId,
        public readonly int $amountUnits,
        public readonly ?string $transactionRef = null,
        public readonly ?string $proofImagePath = null,
        public readonly ?string $gatewayTxnId = null,
        public readonly ?array $gatewayResponse = null,
        public readonly string $currency = 'ILS',
    ) {
    }
}
