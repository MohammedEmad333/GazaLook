<?php

declare(strict_types=1);

/**
 * Minimal PSR-4 autoloader so the backend runs with plain PHP (no Composer
 * required). Maps the `GazaLook\Wallet\` namespace to `src/`. If you do use
 * Composer, `composer.json` declares the same mapping.
 */
spl_autoload_register(static function (string $class): void {
    $prefix = 'GazaLook\\Wallet\\';
    $baseDir = __DIR__ . '/src/';

    if (!str_starts_with($class, $prefix)) {
        return;
    }

    $relative = substr($class, strlen($prefix));
    $file = $baseDir . str_replace('\\', '/', $relative) . '.php';

    if (is_file($file)) {
        require $file;
    }
});
