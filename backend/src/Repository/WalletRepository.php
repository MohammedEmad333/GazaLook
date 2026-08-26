<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Repository;

use PDO;

/**
 * Reads and mutates the `wallets` table. The balance is only ever changed
 * through {@see creditBalance()}, which is always called inside the same DB
 * transaction that approves a ledger row (see WalletService), so the cached
 * balance can never drift from the sum of approved transactions.
 */
final class WalletRepository
{
    public function __construct(private readonly PDO $db)
    {
    }

    /** Returns the wallet id for a user, creating an empty wallet on first use. */
    public function ensureWalletForUser(int $userId): int
    {
        $stmt = $this->db->prepare('SELECT id FROM wallets WHERE user_id = :uid');
        $stmt->execute(['uid' => $userId]);
        $id = $stmt->fetchColumn();

        if ($id !== false) {
            return (int) $id;
        }

        $insert = $this->db->prepare(
            'INSERT INTO wallets (user_id, balance_units) VALUES (:uid, 0)'
        );
        $insert->execute(['uid' => $userId]);

        return (int) $this->db->lastInsertId();
    }

    public function balanceUnits(int $walletId): int
    {
        $stmt = $this->db->prepare('SELECT balance_units FROM wallets WHERE id = :id');
        $stmt->execute(['id' => $walletId]);

        return (int) $stmt->fetchColumn();
    }

    /**
     * Atomically adds [$units] to the wallet balance. MUST be called within an
     * open transaction. Uses a single UPDATE so concurrent approvals serialise
     * on the row lock rather than read-modify-write in PHP.
     */
    public function creditBalance(int $walletId, int $units): void
    {
        $stmt = $this->db->prepare(
            'UPDATE wallets SET balance_units = balance_units + :units WHERE id = :id'
        );
        $stmt->execute(['units' => $units, 'id' => $walletId]);
    }
}
