<?php

declare(strict_types=1);

/**
 * Front controller + tiny router for the GazaLook wallet API.
 *
 * Routes (JSON in / JSON out):
 *   GET  /api/wallet/channels
 *   GET  /api/wallet/balance?user_id=..
 *   GET  /api/wallet/transactions?user_id=..
 *   POST /api/wallet/top-up
 *   GET  /api/admin/transactions/pending
 *   POST /api/admin/transactions/{id}/approve
 *   POST /api/admin/transactions/{id}/reject
 *
 * Auth is intentionally out of scope here — put an auth middleware in front and
 * pass the resolved user/admin id via the request. For the demo the ids are
 * read from the request body/query.
 */

require __DIR__ . '/../autoload.php';

use GazaLook\Wallet\Http\Container;
use GazaLook\Wallet\Http\JsonResponse;

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$path = rtrim(parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/', '/');
if ($path === '') {
    $path = '/';
}

/** @return array<string,mixed> */
$readJsonBody = static function (): array {
    $raw = file_get_contents('php://input') ?: '';
    if ($raw === '') {
        return $_POST;
    }
    $decoded = json_decode($raw, true);

    return is_array($decoded) ? $decoded : [];
};

try {
    $container = new Container();
    $response = null;

    // POST /api/admin/transactions/{id}/approve|reject
    if ($method === 'POST'
        && preg_match('#^/api/admin/transactions/(\d+)/(approve|reject)$#', $path, $m) === 1
    ) {
        $body = $readJsonBody();
        $txnId = (int) $m[1];
        $adminId = (int) ($body['admin_id'] ?? 0);
        $note = isset($body['note']) ? (string) $body['note'] : null;
        $admin = $container->adminController();
        $response = $m[2] === 'approve'
            ? $admin->approve($txnId, $adminId, $note)
            : $admin->reject($txnId, $adminId, $note);
    } else {
        $response = match ("{$method} {$path}") {
            'GET /api/wallet/channels' => $container->walletController()->channels(),
            'GET /api/wallet/balance' => $container->walletController()
                ->balance((int) ($_GET['user_id'] ?? 0)),
            'GET /api/wallet/transactions' => $container->walletController()
                ->history((int) ($_GET['user_id'] ?? 0)),
            'POST /api/wallet/top-up' => $container->walletController()
                ->topUp($readJsonBody()),
            'GET /api/admin/transactions/pending' => $container->adminController()
                ->pending((int) ($_GET['limit'] ?? 50), (int) ($_GET['offset'] ?? 0)),
            default => JsonResponse::error(404, 'المسار غير موجود.'),
        };
    }

    $response->send();
} catch (\Throwable $e) {
    // Never leak internals; log server-side, return a generic 500.
    error_log('[wallet-api] ' . $e->getMessage());
    JsonResponse::error(500, 'خطأ داخلي في الخادم.')->send();
}
