# GazaLook — Backend (Products API + Wallet & Top-up)

Plain PHP 8.1+ and MySQL — no framework — serving two features:

- **Products catalogue API** — the real data source that replaces the app's
  bundled demo catalog (Trello card *"باك-إند حقيقي للمنتجات"*). Responses are
  already in the Flutter `ProductModel` shape, so the app's
  `ProductRemoteDataSource` is the only swap point.
- **User wallet + digital balance top-up** (Trello card *"ربط طرق الدفع"*),
  built around a **Strategy Pattern** so today's manual receipt review can
  become tomorrow's automatic gateway without touching the wallet, ledger or API.

## Products API

| Method & path | Purpose |
|---|---|
| `GET /api/products` | full catalogue (app `ProductModel` shape) |
| `GET /api/products/{id}` | one product, or 404 |

Schema + seed (the 12 launch products): `database/products_schema.sql`. The
Flutter app calls this only when built with `--dart-define=API_BASE_URL=...`;
with no base URL it uses the bundled catalog, so it stays functional offline.

---

## Wallet & balance top-up

## Two phases, one design

| | Phase 1 — **now** (manual) | Phase 2 — **later** (gateway) |
|---|---|---|
| Shopper transfers via | Bank of Palestine / Jawwal Pay / Bal Pay | same |
| Proof | uploads receipt screenshot + operation number | none (auto) |
| Who confirms | an **admin** in the dashboard | the **gateway** callback |
| Strategy | `ManualReceiptUploadStrategy` | `JawwalPayStrategy`, `BankOfPalestineStrategy` |
| Result | `pending` → admin approves → wallet credited | `approved` → wallet credited automatically |

Switching a channel to Phase 2 is one column change (`payment_channels.mode`
= `gateway`) plus registering that channel's strategy — nothing else moves.

## 1. Database schema

`database/schema.sql` (MySQL 8 / MariaDB 10.4+). Tables:

- **users** — app accounts (phone-first), `role` = customer | admin.
- **wallets** — one balance per user. `balance_units` is money in the smallest
  unit (agora — 1 ₪ = 100) as `BIGINT`, so there is never floating-point drift.
- **payment_channels** — funding sources as rows (not an enum), each with a
  `mode` (manual | gateway). Seeded with Bank of Palestine, Jawwal Pay, Bal Pay.
- **wallet_transactions** — the ledger. One row per top-up, with columns for
  **both** phases: `transaction_ref` + `proof_image_path` (manual) and
  `gateway_txn_id` + `gateway_response` (gateway); `status` = pending | approved
  | rejected; review audit fields (`reviewed_by`, `reviewed_at`, `review_note`).

The wallet balance is only ever changed inside the same DB transaction that
approves a ledger row, so it can never diverge from the sum of approved credits.

## 2. Backend architecture (Strategy Pattern)

```
PaymentService            ← picks the strategy from the channel's mode
 ├─ PaymentStrategy (interface)
 │   ├─ ManualReceiptUploadStrategy   (Phase 1: records a pending row)
 │   └─ GatewayStrategy (abstract)    (Phase 2)
 │        ├─ JawwalPayStrategy        (skeleton — wire the SDK in charge())
 │        └─ BankOfPalestineStrategy  (skeleton)
 └─ WalletService          ← the ONLY code that credits a wallet (on approval),
                             atomic + idempotent (row lock, single-statement add)
```

Repositories (`src/Repository/*`) use **PDO prepared statements** exclusively.
`src/Http/Container.php` is the composition root that wires the graph and
registers the strategies.

Add a new gateway later = write one `GatewayStrategy` subclass + register it.
The wallet, ledger, controllers and app stay untouched.

## 3. Mobile UI/UX flow (Flutter)

Implemented in the app under `lib/features/wallet/` (see the repo root).

```
Profile ("حسابي")
  └─ "محفظتي وشحن الرصيد"  → Wallet screen
        • balance card (approved balance only)
        • top-up history with status chips (قيد المراجعة / تمت الموافقة / مرفوض)
        └─ "شحن الرصيد" → Top-up screen
              1. choose channel  → shows the account/number to transfer to
              2. enter amount (₪)
              3. enter the transfer's operation number
              4. attach the receipt screenshot
              5. submit  → row created as `pending`, "قيد المراجعة" shown
```

A pending top-up does **not** change the balance in the app — it appears in the
history as *قيد المراجعة* until an admin approves it, exactly matching the
backend. (The receipt attach is a documented placeholder pending a real image
picker + upload.)

## 4. Admin panel logic

Endpoints (put admin auth middleware in front — `role = admin`):

| Method & path | Purpose |
|---|---|
| `GET  /api/admin/transactions/pending` | the review queue (oldest first) |
| `POST /api/admin/transactions/{id}/approve` | approve → **credits the wallet** |
| `POST /api/admin/transactions/{id}/reject`  | reject (no balance change) |

Approve/reject are **idempotent**: the row is locked `FOR UPDATE`, and a row
that is already terminal returns `applied: false` with no second credit — safe
against double-clicks or retries. Approval of a `credit` transaction adds
`amount_units` to the wallet in the same transaction that flips the status.

### Customer endpoints

| Method & path | Purpose |
|---|---|
| `GET  /api/wallet/channels` | funding sources to render |
| `GET  /api/wallet/balance?user_id=..` | current approved balance |
| `GET  /api/wallet/transactions?user_id=..` | the user's history |
| `POST /api/wallet/top-up` | create a manual top-up |

## Running it

```bash
# 1. Create the schema (wallet + products)
mysql -u root gazalook < database/schema.sql
mysql -u root gazalook < database/products_schema.sql

# 2. Configure the DB connection (no secrets in source)
export DB_HOST=127.0.0.1 DB_NAME=gazalook DB_USER=gazalook DB_PASS=secret

# 3. Serve the API
php -S 127.0.0.1:8000 -t public

# 4. Try it
curl -s localhost:8000/api/products
curl -s localhost:8000/api/products/p1
curl -s localhost:8000/api/wallet/channels
curl -s -X POST localhost:8000/api/wallet/top-up \
  -H 'Content-Type: application/json' \
  -d '{"user_id":1,"channel_id":1,"amount":50,"transaction_ref":"OP-1","proof_image_path":"receipts/op-1.jpg"}'
curl -s localhost:8000/api/admin/transactions/pending
curl -s -X POST localhost:8000/api/admin/transactions/1/approve \
  -H 'Content-Type: application/json' -d '{"admin_id":2}'
```

## Where to deploy

It's plain PHP + MySQL, so almost anything runs it. Ranked for this project
(audience in Gaza → pick a nearby region: Frankfurt / EU or the Middle East for
low latency, and prefer a provider with reliable uptime):

1. **Small VPS (recommended for control)** — Hetzner (Frankfurt) or DigitalOcean:
   Nginx + PHP-FPM + MySQL, HTTPS via Let's Encrypt. ~$5–6/mo, full control over
   receipts storage, cron, and the future admin panel. Best balance for an MVP.
2. **Managed shared/cPanel PHP hosting** — zero ops, cheapest, one-click MySQL +
   Let's Encrypt. Good if you want to avoid server admin; less control.
3. **Container PaaS** — Render / Railway / Fly.io (Dockerize `public/` behind
   PHP-FPM) with a managed MySQL. Easy CI deploys; watch cold starts/pricing.
4. **Google Cloud Run + Cloud SQL** — fits if you also adopt Firebase for auth;
   heavier to set up than the above.

### Free options (MVP / testing)

- **Oracle Cloud — Always Free** (best "real server", no time limit): a free
  Ampere/ARM VM (regions incl. Frankfurt & Jeddah — close to Gaza). Install
  LAMP + Let's Encrypt and you get a genuine always-on VPS for €0. Most setup,
  best result.
- **InfinityFree** (easiest, zero-ops): free PHP + MySQL + cPanel + free SSL +
  subdomain, no credit card. Great to get the API online in minutes. Caveats:
  shared limits, no SSH, limited/unreliable cron, and outbound calls are often
  blocked (fine for Phase 1; matters for Phase-2 gateways).
  **→ Step-by-step guide: [`DEPLOY_INFINITYFREE.md`](DEPLOY_INFINITYFREE.md).**
- **Fly.io / Render** (container PaaS free tiers): Dockerize PHP-FPM; note free
  web services sleep on inactivity (cold starts) and free MySQL is limited —
  usually pair with an external free DB.

For production later, move to the paid VPS above — free tiers throttle traffic,
limit storage (receipts), and don't guarantee uptime.

Whichever you pick:
- Serve `public/` as the web root; **only** `public/index.php` is exposed.
- Terminate **HTTPS** and restrict CORS to the app's origin.
- Set the `DB_*` env vars (never commit secrets — the code already reads env).
- Store receipt screenshots on object storage or a persistent disk (not in git).
- Enable daily MySQL backups.

## Tests

A dependency-free smoke test runs the real services against in-memory SQLite:

```bash
php tests/smoke_test.php
```

It covers the full flow: manual top-up → pending → admin approve → wallet
credited, plus validation, idempotency and rejection.

## Notes / not included

- **Auth** is assumed to be handled by upstream middleware; controllers take an
  explicit `user_id` / `admin_id`.
- **Gateway credentials/SDKs** (Phase 2) are intentionally not wired — that is
  the future work the card defers. The strategy skeletons show exactly where.
- **Receipt file storage** (S3/local disk) is out of scope here; the API stores
  the resulting `proof_image_path`.
