<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Repository;

use PDO;

/**
 * Reads the `products` catalogue and returns rows already shaped to match the
 * Flutter `ProductModel.fromMap` contract (camelCase keys), so the app's
 * ProductRemoteDataSource can consume the API response unchanged.
 */
final class ProductRepository
{
    public function __construct(private readonly PDO $db)
    {
    }

    /** @return list<array<string,mixed>> */
    public function all(): array
    {
        $stmt = $this->db->query('SELECT * FROM products ORDER BY sort_order, id');

        return array_map($this->toApi(...), $stmt->fetchAll());
    }

    /** @return array<string,mixed>|null */
    public function find(string $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM products WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();

        return $row === false ? null : $this->toApi($row);
    }

    /**
     * Maps a DB row to the API/`ProductModel` JSON shape.
     *
     * @param array<string,mixed> $row
     * @return array<string,mixed>
     */
    private function toApi(array $row): array
    {
        return [
            'id' => (string) $row['id'],
            'name' => (string) $row['name'],
            'price' => (float) $row['price'],
            'oldPrice' => $row['old_price'] !== null ? (float) $row['old_price'] : null,
            'imageUrl' => (string) $row['image_url'],
            'category' => (string) $row['category'],
            'description' => (string) ($row['description'] ?? ''),
            'images' => $this->decodeList($row['images'] ?? null),
            'sizes' => $this->decodeList($row['sizes'] ?? null),
            'rating' => (float) ($row['rating'] ?? 0),
            'ratingCount' => (int) ($row['rating_count'] ?? 0),
            'isLocal' => (bool) ($row['is_local'] ?? false),
            'inStock' => (bool) ($row['in_stock'] ?? true),
            'storeName' => $row['store_name'] !== null ? (string) $row['store_name'] : null,
        ];
    }

    /** @return list<string> */
    private function decodeList(mixed $json): array
    {
        if (!is_string($json) || $json === '') {
            return [];
        }
        $decoded = json_decode($json, true);

        return is_array($decoded) ? array_values(array_map('strval', $decoded)) : [];
    }
}
