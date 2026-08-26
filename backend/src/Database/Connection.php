<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Database;

use PDO;

/**
 * Thin PDO factory. Reads connection settings from environment variables so no
 * credentials ever live in source (12-factor). See backend/README.md.
 */
final class Connection
{
    private static ?PDO $pdo = null;

    public static function get(): PDO
    {
        if (self::$pdo instanceof PDO) {
            return self::$pdo;
        }

        $host = getenv('DB_HOST') ?: '127.0.0.1';
        $port = getenv('DB_PORT') ?: '3306';
        $name = getenv('DB_NAME') ?: 'gazalook';
        $user = getenv('DB_USER') ?: 'root';
        $pass = getenv('DB_PASS') ?: '';

        $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";

        self::$pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);

        return self::$pdo;
    }

    /** Test seam: inject a ready PDO (e.g. an in-memory SQLite double). */
    public static function set(PDO $pdo): void
    {
        self::$pdo = $pdo;
    }
}
