<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Http;

use GazaLook\Wallet\Domain\TransactionStatus;
use GazaLook\Wallet\Repository\TransactionRepository;
use GazaLook\Wallet\Wallet\WalletException;
use GazaLook\Wallet\Wallet\WalletService;

/**
 * Admin-panel endpoints. These MUST sit behind admin authentication/authorisation
 * middleware (role = admin); the controller assumes the caller is already
 * verified and passes the admin's id as the reviewer.
 *
 * The core admin flow the card asks for:
 *   1. GET  /api/admin/transactions/pending  → the review queue.
 *   2. POST /api/admin/transactions/{id}/approve → credits the user's wallet.
 *   3. POST /api/admin/transactions/{id}/reject  → closes it, no credit.
 */
final class AdminController
{
    public function __construct(
        private readonly WalletService $wallet,
        private readonly TransactionRepository $transactions,
    ) {
    }

    /** GET /api/admin/transactions/pending — oldest first. */
    public function pending(int $limit = 50, int $offset = 0): JsonResponse
    {
        $items = array_map(
            static fn ($t): array => $t->toArray(),
            $this->transactions->listByStatus(TransactionStatus::Pending, $limit, $offset),
        );

        return JsonResponse::ok(['transactions' => $items]);
    }

    /** POST /api/admin/transactions/{id}/approve — approve + credit wallet. */
    public function approve(int $transactionId, int $adminId, ?string $note = null): JsonResponse
    {
        try {
            $applied = $this->wallet->approve($transactionId, $adminId, $note);
        } catch (WalletException $e) {
            return JsonResponse::error(404, $e->getMessage());
        }

        return JsonResponse::ok([
            'transaction_id' => $transactionId,
            'status' => TransactionStatus::Approved->value,
            'applied' => $applied, // false → was already reviewed (idempotent)
        ]);
    }

    /** POST /api/admin/transactions/{id}/reject — reject, no balance change. */
    public function reject(int $transactionId, int $adminId, ?string $note = null): JsonResponse
    {
        try {
            $applied = $this->wallet->reject($transactionId, $adminId, $note);
        } catch (WalletException $e) {
            return JsonResponse::error(404, $e->getMessage());
        }

        return JsonResponse::ok([
            'transaction_id' => $transactionId,
            'status' => TransactionStatus::Rejected->value,
            'applied' => $applied,
        ]);
    }
}
