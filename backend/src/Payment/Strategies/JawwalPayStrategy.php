<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment\Strategies;

use GazaLook\Wallet\Domain\PaymentChannel;
use GazaLook\Wallet\Payment\PaymentException;
use GazaLook\Wallet\Payment\TopUpRequest;

/**
 * Phase 2 — Jawwal Pay gateway. Skeleton only: wire the official Jawwal Pay
 * API/SDK inside {@see charge()} once credentials are provisioned. No other
 * layer changes when this goes live — just switch the channel's `mode` to
 * `gateway` and register this strategy.
 */
final class JawwalPayStrategy extends GatewayStrategy
{
    public function key(): string
    {
        return 'jawwal_pay';
    }

    protected function charge(TopUpRequest $request, PaymentChannel $channel): array
    {
        // TODO(Phase 2): call the Jawwal Pay API with credentials from env.
        //   $response = $this->client->charge([...]);
        //   if (!$response->isSuccessful()) throw new PaymentException(...);
        //   return ['gateway_txn_id' => $response->id, 'raw' => $response->toArray()];
        throw new PaymentException('بوابة جوال باي غير مفعّلة بعد (المرحلة الثانية).');
    }
}
