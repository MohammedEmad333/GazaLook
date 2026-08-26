<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Wallet;

use GazaLook\Wallet\Domain\TransactionStatus;
use GazaLook\Wallet\Repository\TransactionRepository;
use GazaLook\Wallet\Repository\WalletRepository;
use PDO;

/**
 * Owns the money-moving operations behind the admin panel. Approving a pending
 * top-up is the ONLY path that credits a wallet, and it does so atomically:
 * the ledger row and the balance change commit together or not at all, and a
 * row that is already terminal is never credited twice.
 */
final class WalletService
{
    public function __construct(
        private readonly PDO $db,
        private readonly TransactionRepository $transactions,
        private readonly WalletRepository $wallets,
    ) {
    }

    /**
     * Approve a pending top-up and credit the wallet in one DB transaction.
     *
     * @return bool true if it was approved now, false if it was already terminal.
     * @throws WalletException if the transaction does not exist.
     */
    public function approve(int $transactionId, ?int $reviewerId, ?string $note = null): bool
    {
        return $this->inTransaction(function () use ($transactionId, $reviewerId, $note): bool {
            $txn = $this->transactions->findForUpdate($transactionId);
            if ($txn === null) {
                throw new WalletException('العملية غير موجودة.');
            }
            // Idempotent: approving an already-approved/rejected row is a no-op.
            if ($txn->status->isTerminal()) {
                return false;
            }

            $this->transactions->markReviewed(
                $transactionId,
                TransactionStatus::Approved,
                // reviewed_by is a nullable FK; the gateway path passes null.
                $reviewerId,
                $note,
            );

            if ($txn->direction === 'credit') {
                $this->wallets->creditBalance($txn->walletId, $txn->amountUnits);
            }

            return true;
        });
    }

    /**
     * Reject a pending top-up. No balance change. Idempotent for terminal rows.
     *
     * @throws WalletException if the transaction does not exist.
     */
    public function reject(int $transactionId, ?int $reviewerId, ?string $note = null): bool
    {
        return $this->inTransaction(function () use ($transactionId, $reviewerId, $note): bool {
            $txn = $this->transactions->findForUpdate($transactionId);
            if ($txn === null) {
                throw new WalletException('العملية غير موجودة.');
            }
            if ($txn->status->isTerminal()) {
                return false;
            }

            $this->transactions->markReviewed(
                $transactionId,
                TransactionStatus::Rejected,
                $reviewerId,
                $note,
            );

            return true;
        });
    }

    public function balanceUnits(int $userId): int
    {
        $walletId = $this->wallets->ensureWalletForUser($userId);

        return $this->wallets->balanceUnits($walletId);
    }

    /** @template T @param callable():T $work @return T */
    private function inTransaction(callable $work): mixed
    {
        $ownTransaction = !$this->db->inTransaction();
        if ($ownTransaction) {
            $this->db->beginTransaction();
        }
        try {
            $result = $work();
            if ($ownTransaction) {
                $this->db->commit();
            }
            return $result;
        } catch (\Throwable $e) {
            if ($ownTransaction && $this->db->inTransaction()) {
                $this->db->rollBack();
            }
            throw $e;
        }
    }
}
