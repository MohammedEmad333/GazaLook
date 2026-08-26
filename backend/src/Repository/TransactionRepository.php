<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Repository;

use GazaLook\Wallet\Domain\TransactionStatus;
use GazaLook\Wallet\Domain\WalletTransaction;
use PDO;

/** Reads and writes the `wallet_transactions` ledger. */
final class TransactionRepository
{
    public function __construct(private readonly PDO $db)
    {
    }

    /**
     * Inserts a new top-up row and returns its id.
     *
     * @param array<string,mixed> $data
     */
    public function create(array $data): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO wallet_transactions
                (wallet_id, user_id, channel_id, direction, amount_units, currency,
                 status, transaction_ref, proof_image_path, gateway_txn_id, gateway_response)
             VALUES
                (:wallet_id, :user_id, :channel_id, :direction, :amount_units, :currency,
                 :status, :transaction_ref, :proof_image_path, :gateway_txn_id, :gateway_response)'
        );

        $stmt->execute([
            'wallet_id' => $data['wallet_id'],
            'user_id' => $data['user_id'],
            'channel_id' => $data['channel_id'],
            'direction' => $data['direction'] ?? 'credit',
            'amount_units' => $data['amount_units'],
            'currency' => $data['currency'] ?? 'ILS',
            'status' => $data['status'] ?? TransactionStatus::Pending->value,
            'transaction_ref' => $data['transaction_ref'] ?? null,
            'proof_image_path' => $data['proof_image_path'] ?? null,
            'gateway_txn_id' => $data['gateway_txn_id'] ?? null,
            'gateway_response' => isset($data['gateway_response'])
                ? json_encode($data['gateway_response'], JSON_UNESCAPED_UNICODE)
                : null,
        ]);

        return (int) $this->db->lastInsertId();
    }

    public function find(int $id): ?WalletTransaction
    {
        $stmt = $this->db->prepare('SELECT * FROM wallet_transactions WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();

        return $row === false ? null : WalletTransaction::fromRow($row);
    }

    /**
     * Locks a transaction row FOR UPDATE so an approval/rejection is applied
     * exactly once even under concurrent admin clicks. Must run in a transaction.
     */
    public function findForUpdate(int $id): ?WalletTransaction
    {
        // `FOR UPDATE` row locking is a MySQL/Postgres feature; SQLite (used in
        // tests) locks the whole DB per write transaction, so the clause is
        // simply omitted there.
        $driver = $this->db->getAttribute(PDO::ATTR_DRIVER_NAME);
        $lock = in_array($driver, ['mysql', 'pgsql'], true) ? ' FOR UPDATE' : '';

        $stmt = $this->db->prepare(
            "SELECT * FROM wallet_transactions WHERE id = :id{$lock}"
        );
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();

        return $row === false ? null : WalletTransaction::fromRow($row);
    }

    /** @return list<WalletTransaction> */
    public function listByStatus(TransactionStatus $status, int $limit = 50, int $offset = 0): array
    {
        $stmt = $this->db->prepare(
            'SELECT * FROM wallet_transactions
             WHERE status = :status
             ORDER BY created_at ASC
             LIMIT :limit OFFSET :offset'
        );
        $stmt->bindValue('status', $status->value);
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue('offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return array_map(WalletTransaction::fromRow(...), $stmt->fetchAll());
    }

    /** @return list<WalletTransaction> */
    public function listByUser(int $userId, int $limit = 50): array
    {
        $stmt = $this->db->prepare(
            'SELECT * FROM wallet_transactions
             WHERE user_id = :uid
             ORDER BY created_at DESC
             LIMIT :limit'
        );
        $stmt->bindValue('uid', $userId, PDO::PARAM_INT);
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return array_map(WalletTransaction::fromRow(...), $stmt->fetchAll());
    }

    public function markReviewed(
        int $id,
        TransactionStatus $status,
        ?int $reviewerId,
        ?string $note = null,
    ): void {
        $stmt = $this->db->prepare(
            'UPDATE wallet_transactions
             SET status = :status, reviewed_by = :reviewer,
                 reviewed_at = CURRENT_TIMESTAMP, review_note = :note
             WHERE id = :id'
        );
        $stmt->execute([
            'status' => $status->value,
            'reviewer' => $reviewerId,
            'note' => $note,
            'id' => $id,
        ]);
    }
}
