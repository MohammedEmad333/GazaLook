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

        $cfg = self::settings();
        $dsn = "mysql:host={$cfg['host']};port={$cfg['port']};"
            . "dbname={$cfg['name']};charset=utf8mb4";

        self::$pdo = new PDO($dsn, $cfg['user'], $cfg['pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);

        return self::$pdo;
    }

    /**
     * Resolves DB settings. Prefers environment variables (12-factor / VPS).
     * On shared hosting without env support (e.g. InfinityFree) it falls back
     * to a `config.php` file that returns an array — copy `config.sample.php`
     * to `config.php` and fill in the panel's MySQL details. `config.php` is
     * git-ignored so secrets never land in the repo.
     *
     * @return array{host:string,port:string,name:string,user:string,pass:string}
     */
    private static function settings(): array
    {
        $env = getenv('DB_HOST');
        if ($env !== false && $env !== '') {
            return [
                'host' => $env,
                'port' => getenv('DB_PORT') ?: '3306',
                'name' => getenv('DB_NAME') ?: 'gazalook',
                'user' => getenv('DB_USER') ?: 'root',
                'pass' => getenv('DB_PASS') ?: '',
            ];
        }

        // config.php location depends on the deployment layout:
        //   • single-file build: index.php + config.php in the web root → __DIR__/config.php
        //   • multi-file build: htdocs/app/src/Database/Connection.php → htdocs/config.php
        foreach ([
            __DIR__ . '/config.php',
            __DIR__ . '/../config.php',
            __DIR__ . '/../../config.php',
            __DIR__ . '/../../../config.php',
        ] as $path) {
            if (is_file($path)) {
                /** @var array<string,string> $file */
                $file = require $path;
                return [
                    'host' => $file['host'] ?? '127.0.0.1',
                    'port' => $file['port'] ?? '3306',
                    'name' => $file['name'] ?? 'gazalook',
                    'user' => $file['user'] ?? 'root',
                    'pass' => $file['pass'] ?? '',
                ];
            }
        }

        return [
            'host' => '127.0.0.1',
            'port' => '3306',
            'name' => 'gazalook',
            'user' => 'root',
            'pass' => '',
        ];
    }

    /** Test seam: inject a ready PDO (e.g. an in-memory SQLite double). */
    public static function set(PDO $pdo): void
    {
        self::$pdo = $pdo;
    }
}
