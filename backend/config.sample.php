<?php

declare(strict_types=1);

/**
 * Database configuration for hosts without environment variables (e.g.
 * InfinityFree shared hosting).
 *
 * SETUP:
 *   1. Copy this file to `config.php` in the same folder as `autoload.php`.
 *   2. Fill in the values from your hosting panel → MySQL Databases.
 *   3. NEVER commit `config.php` — it is git-ignored.
 *
 * On a VPS you can skip this file entirely and set the DB_HOST / DB_PORT /
 * DB_NAME / DB_USER / DB_PASS environment variables instead.
 */

return [
    // InfinityFree shows these under "MySQL Databases":
    'host' => 'sqlXXX.infinityfree.com', // e.g. sql201.infinityfree.com
    'port' => '3306',
    'name' => 'epiz_XXXXXXX_gazalook',   // the full DB name incl. the epiz_ prefix
    'user' => 'epiz_XXXXXXX',            // the DB username
    'pass' => 'YOUR_DB_PASSWORD',
];
