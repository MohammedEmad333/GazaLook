<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Domain;

/**
 * Lifecycle of a wallet top-up. A row starts `pending` (manual review) and is
 * moved to exactly one terminal state. Phase-2 gateway top-ups are created
 * straight as `approved`.
 */
enum TransactionStatus: string
{
    case Pending = 'pending';
    case Approved = 'approved';
    case Rejected = 'rejected';

    public function isTerminal(): bool
    {
        return $this !== self::Pending;
    }
}
