<?php

declare(strict_types=1);

/**
 * Self-contained smoke test for the wallet backend. Runs the real services
 * against an in-memory SQLite database (no MySQL needed):
 *
 *   php backend/tests/smoke_test.php
 *
 * Exercises the full Phase-1 flow: manual top-up → pending → admin approve →
 * wallet credited, plus idempotency and rejection.
 */

require __DIR__ . '/../autoload.php';

use GazaLook\Wallet\Database\Connection;
use GazaLook\Wallet\Domain\TransactionStatus;
use GazaLook\Wallet\Http\Container;
use GazaLook\Wallet\Payment\TopUpRequest;
use GazaLook\Wallet\Support\Money;

$failures = 0;
function check(string $label, bool $cond): void
{
    global $failures;
    echo ($cond ? "  ✓ " : "  ✗ ") . $label . PHP_EOL;
    if (!$cond) {
        $failures++;
    }
}

// ---- Boot an in-memory SQLite DB with the portable schema ------------------
$pdo = new PDO('sqlite::memory:', null, null, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
]);
$pdo->exec('PRAGMA foreign_keys = ON;');
$pdo->exec((string) file_get_contents(__DIR__ . '/schema.sqlite.sql'));

// Seed a customer, an admin and the Bank of Palestine channel.
$pdo->exec("INSERT INTO users (phone_e164, role) VALUES ('+970591234567','customer')");
$pdo->exec("INSERT INTO users (phone_e164, role) VALUES ('+970599999999','admin')");
$pdo->exec("INSERT INTO payment_channels (code, name_ar, name_en, mode, account_ref)
            VALUES ('bank_of_palestine','بنك فلسطين','Bank of Palestine','manual','ACC-1')");
$userId = 1;
$adminId = 2;
$channelId = 1;

// Seed two catalog products.
$pdo->exec("INSERT INTO products
    (id, name, price, old_price, image_url, category, sizes, rating, rating_count, is_local, in_stock, sort_order)
    VALUES
    ('p1','فستان صيفي حريري',120,NULL,'https://img/p1','women','[\"S\",\"M\",\"L\"]',4.8,124,1,1,1),
    ('p3','قميص كتان خفيف',95,130,'https://img/p3','men','[\"M\",\"L\"]',4.4,61,0,1,2)");

Connection::set($pdo);
$container = new Container($pdo);
$wallet = $container->walletController();
$admin = $container->adminController();
$products = $container->productController();

echo "Money conversion" . PHP_EOL;
check('25.50 ₪ → 2550 units', Money::toUnits(25.50) === 2550);
check('2550 units → "25.50 ₪"', Money::format(2550) === '25.50 ₪');

echo "Manual top-up (Phase 1)" . PHP_EOL;
$res = $wallet->topUp([
    'user_id' => $userId,
    'channel_id' => $channelId,
    'amount' => 50,
    'transaction_ref' => 'OP-123',
    'proof_image_path' => 'receipts/op-123.jpg',
]);
check('top-up accepted (HTTP 200)', $res->status === 200);
$txnId = (int) ($res->body['data']['transaction_id'] ?? 0);
check('created a transaction id', $txnId > 0);
check('status is pending', ($res->body['data']['status'] ?? '') === TransactionStatus::Pending->value);

$bal = $wallet->balance($userId);
check('balance still 0 before approval', ($bal->body['data']['balance_units'] ?? -1) === 0);

echo "Missing receipt is rejected" . PHP_EOL;
$bad = $wallet->topUp([
    'user_id' => $userId,
    'channel_id' => $channelId,
    'amount' => 50,
    'transaction_ref' => 'OP-124',
    // no proof_image_path
]);
check('validation error (HTTP 422)', $bad->status === 422);

echo "Admin review queue + approval" . PHP_EOL;
$pending = $admin->pending();
check('one pending transaction in the queue', count($pending->body['data']['transactions']) === 1);

$approve = $admin->approve($txnId, $adminId, 'looks good');
check('approve applied', ($approve->body['data']['applied'] ?? false) === true);

$bal = $wallet->balance($userId);
check('wallet credited 50 ₪ (5000 units)', ($bal->body['data']['balance_units'] ?? -1) === 5000);

echo "Approval is idempotent" . PHP_EOL;
$again = $admin->approve($txnId, $adminId);
check('second approve is a no-op', ($again->body['data']['applied'] ?? true) === false);
$bal = $wallet->balance($userId);
check('balance unchanged after re-approve', ($bal->body['data']['balance_units'] ?? -1) === 5000);

echo "Rejection path" . PHP_EOL;
$res2 = $wallet->topUp([
    'user_id' => $userId,
    'channel_id' => $channelId,
    'amount' => 20,
    'transaction_ref' => 'OP-200',
    'proof_image_path' => 'receipts/op-200.jpg',
]);
$txn2 = (int) $res2->body['data']['transaction_id'];
$reject = $admin->reject($txn2, $adminId, 'blurry receipt');
check('reject applied', ($reject->body['data']['applied'] ?? false) === true);
$bal = $wallet->balance($userId);
check('balance unchanged after rejection', ($bal->body['data']['balance_units'] ?? -1) === 5000);

echo "Products API" . PHP_EOL;
$list = $products->list();
check('lists all products', count($list->body['data']['products']) === 2);
$first = $list->body['data']['products'][0];
check('product JSON uses ProductModel keys', isset($first['imageUrl'], $first['ratingCount'], $first['inStock']));
check('sizes decoded to a list', is_array($first['sizes']) && $first['sizes'] === ['S', 'M', 'L']);
check('isOnOffer product exposes oldPrice', ($products->show('p3')->body['data']['product']['oldPrice'] ?? null) === 130.0);
check('unknown product → 404', $products->show('nope')->status === 404);

echo PHP_EOL . ($failures === 0
    ? "All backend smoke checks passed ✅" . PHP_EOL
    : "{$failures} check(s) FAILED ❌" . PHP_EOL);

exit($failures === 0 ? 0 : 1);
