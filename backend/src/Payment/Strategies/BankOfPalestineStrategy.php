<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment\Strategies;

use GazaLook\Wallet\Domain\PaymentChannel;
use GazaLook\Wallet\Payment\PaymentException;
use GazaLook\Wallet\Payment\TopUpRequest;

/**
 * Phase 2 — Bank of Palestine gateway. Skeleton only: implement {@see charge()}
 * against the bank's official payment API once it is available. See
 * {@see JawwalPayStrategy} for the pattern.
 */
final class BankOfPalestineStrategy extends GatewayStrategy
{
    public function key(): string
    {
        return 'bank_of_palestine';
    }

    protected function charge(TopUpRequest $request, PaymentChannel $channel): array
    {
        // TODO(Phase 2): integrate the Bank of Palestine gateway here.
        throw new PaymentException('بوابة بنك فلسطين غير مفعّلة بعد (المرحلة الثانية).');
    }
}
