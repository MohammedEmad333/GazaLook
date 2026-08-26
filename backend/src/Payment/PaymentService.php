<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment;

use GazaLook\Wallet\Domain\ChannelMode;
use GazaLook\Wallet\Repository\ChannelRepository;

/**
 * Entry point for creating a top-up. It resolves the right {@see PaymentStrategy}
 * for the chosen channel and delegates — the caller never needs to know whether
 * a channel is manual (Phase 1) or gateway-backed (Phase 2).
 *
 * Strategy selection rule:
 *   • channel.mode = manual  → the shared "manual" strategy.
 *   • channel.mode = gateway → the strategy registered under the channel code
 *     (e.g. "jawwal_pay"), falling back to an error if none is registered.
 */
final class PaymentService
{
    /** @var array<string,PaymentStrategy> keyed by strategy key */
    private array $strategies = [];

    public function __construct(private readonly ChannelRepository $channels)
    {
    }

    /** Register a strategy; last one registered under a key wins. */
    public function register(PaymentStrategy $strategy): void
    {
        $this->strategies[$strategy->key()] = $strategy;
    }

    public function topUp(TopUpRequest $request): TopUpResult
    {
        $channel = $this->channels->find($request->channelId);
        if ($channel === null || !$channel->isActive) {
            throw new PaymentException('طريقة الدفع غير متاحة.');
        }

        $key = $channel->mode === ChannelMode::Manual ? 'manual' : $channel->code;
        $strategy = $this->strategies[$key] ?? null;
        if ($strategy === null) {
            throw new PaymentException("لا يوجد معالج للدفع لهذه القناة ({$key}).");
        }

        return $strategy->process($request, $channel);
    }
}
