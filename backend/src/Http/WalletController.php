<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Http;

use GazaLook\Wallet\Payment\PaymentException;
use GazaLook\Wallet\Payment\PaymentService;
use GazaLook\Wallet\Payment\TopUpRequest;
use GazaLook\Wallet\Repository\ChannelRepository;
use GazaLook\Wallet\Repository\TransactionRepository;
use GazaLook\Wallet\Support\Money;
use GazaLook\Wallet\Wallet\WalletService;

/**
 * Customer-facing wallet endpoints — the ones the Flutter "شحن الرصيد" screen
 * calls. Authentication (resolving the caller's user id) is assumed to be
 * handled by middleware upstream; here we take an explicit $userId.
 */
final class WalletController
{
    public function __construct(
        private readonly PaymentService $payments,
        private readonly WalletService $wallet,
        private readonly ChannelRepository $channels,
        private readonly TransactionRepository $transactions,
    ) {
    }

    /** GET /api/wallet/channels — the funding sources to render as options. */
    public function channels(): JsonResponse
    {
        $channels = array_map(
            static fn ($c): array => $c->toArray(),
            $this->channels->listActive(),
        );

        return JsonResponse::ok(['channels' => $channels]);
    }

    /** GET /api/wallet/balance?user_id=.. — current balance. */
    public function balance(int $userId): JsonResponse
    {
        $units = $this->wallet->balanceUnits($userId);

        return JsonResponse::ok([
            'balance_units' => $units,
            'balance_display' => Money::format($units),
        ]);
    }

    /** GET /api/wallet/transactions?user_id=.. — the user's top-up history. */
    public function history(int $userId): JsonResponse
    {
        $items = array_map(
            static fn ($t): array => $t->toArray(),
            $this->transactions->listByUser($userId),
        );

        return JsonResponse::ok(['transactions' => $items]);
    }

    /**
     * POST /api/wallet/top-up — create a top-up (Phase 1: manual receipt).
     *
     * @param array<string,mixed> $input decoded JSON / form body
     */
    public function topUp(array $input): JsonResponse
    {
        $userId = (int) ($input['user_id'] ?? 0);
        $channelId = (int) ($input['channel_id'] ?? 0);
        // Accept a shekel amount from the client and store it as integer units.
        $amountUnits = isset($input['amount'])
            ? Money::toUnits((float) $input['amount'])
            : (int) ($input['amount_units'] ?? 0);

        if ($userId <= 0 || $channelId <= 0) {
            return JsonResponse::error(422, 'user_id و channel_id مطلوبان.');
        }

        $request = new TopUpRequest(
            userId: $userId,
            channelId: $channelId,
            amountUnits: $amountUnits,
            transactionRef: isset($input['transaction_ref'])
                ? (string) $input['transaction_ref'] : null,
            proofImagePath: isset($input['proof_image_path'])
                ? (string) $input['proof_image_path'] : null,
        );

        try {
            $result = $this->payments->topUp($request);
        } catch (PaymentException $e) {
            return JsonResponse::error(422, $e->getMessage());
        }

        return JsonResponse::ok($result->toArray());
    }
}
