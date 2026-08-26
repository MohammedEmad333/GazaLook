<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Repository;

use GazaLook\Wallet\Domain\PaymentChannel;
use PDO;

/** Reads the `payment_channels` catalogue. */
final class ChannelRepository
{
    public function __construct(private readonly PDO $db)
    {
    }

    public function find(int $id): ?PaymentChannel
    {
        $stmt = $this->db->prepare('SELECT * FROM payment_channels WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();

        return $row === false ? null : PaymentChannel::fromRow($row);
    }

    /** @return list<PaymentChannel> */
    public function listActive(): array
    {
        $stmt = $this->db->query('SELECT * FROM payment_channels WHERE is_active = 1 ORDER BY id');

        return array_map(PaymentChannel::fromRow(...), $stmt->fetchAll());
    }
}
