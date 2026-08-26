<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment;

use GazaLook\Wallet\Domain\PaymentChannel;

/**
 * Strategy Pattern contract for turning a shopper's top-up request into a
 * ledger row. Each funding channel is handled by one concrete strategy:
 *
 *   • {@see Strategies\ManualReceiptUploadStrategy} — Phase 1: records a
 *     `pending` row from an uploaded receipt for an admin to review.
 *   • {@see Strategies\JawwalPayStrategy}, {@see Strategies\BankOfPalestineStrategy}
 *     — Phase 2: call the official gateway and record an already-`approved` row.
 *
 * Adding a new gateway later means writing one new strategy and registering it
 * in {@see PaymentService} — the wallet, ledger and API stay untouched.
 */
interface PaymentStrategy
{
    /** Stable key used to register/resolve the strategy (e.g. "manual"). */
    public function key(): string;

    /**
     * Validate and persist the top-up. Implementations create exactly one
     * `wallet_transactions` row and return its result. They must NOT credit the
     * wallet directly — crediting only ever happens on approval, inside
     * {@see \GazaLook\Wallet\Wallet\WalletService}.
     *
     * @throws \GazaLook\Wallet\Payment\PaymentException on invalid input.
     */
    public function process(TopUpRequest $request, PaymentChannel $channel): TopUpResult;
}
