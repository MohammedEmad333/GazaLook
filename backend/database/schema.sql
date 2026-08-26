-- =============================================================================
-- GazaLook — User Wallet & Balance Top-up schema
-- =============================================================================
-- Engine : MySQL 8 / MariaDB 10.4+  (InnoDB, utf8mb4)
--
-- Designed to serve BOTH rollout phases without a migration:
--   • Phase 1 (manual): the shopper transfers money via Bank of Palestine /
--     Jawwal Pay / Bal Pay, then uploads a receipt screenshot + reference
--     number. An admin reviews the `pending` transaction and approves it,
--     which credits the wallet.
--   • Phase 2 (gateway): an official payment gateway confirms the payment
--     automatically. The same `wallet_transactions` row is used — the gateway
--     fills `gateway_response` and the status moves straight to `approved`
--     with no human step.
--
-- Money is stored in the smallest unit (agora/piaster) as BIGINT to avoid
-- floating-point rounding. 1 ILS (₪) = 100 units. Application code converts.
-- =============================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- -----------------------------------------------------------------------------
-- users — app accounts (mirrors the Flutter auth user; phone-first).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  phone_e164    VARCHAR(20)     NOT NULL,          -- e.g. +970591234567
  full_name     VARCHAR(120)    NULL,
  role          ENUM('customer','admin') NOT NULL DEFAULT 'customer',
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_phone (phone_e164)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- wallets — one balance per user. Balance is a cache of the sum of approved
-- credits/debits; it is only ever mutated inside the same DB transaction that
-- approves a wallet_transaction, so it can never drift.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wallets (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  balance_units BIGINT          NOT NULL DEFAULT 0,   -- in agora (₪ × 100)
  currency      CHAR(3)         NOT NULL DEFAULT 'ILS',
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wallets_user (user_id),
  CONSTRAINT fk_wallets_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_wallets_balance_nonneg CHECK (balance_units >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- payment_channels — the funding sources shown in the app. Rows, not an enum,
-- so new channels (incl. Phase-2 gateways) are added without a schema change.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payment_channels (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code          VARCHAR(40)     NOT NULL,          -- bank_of_palestine, jawwal_pay, bal_pay
  name_ar       VARCHAR(80)     NOT NULL,
  name_en       VARCHAR(80)     NOT NULL,
  -- Which strategy handles this channel today: 'manual' (Phase 1) or
  -- 'gateway' (Phase 2). Flipping this one value migrates a channel.
  mode          ENUM('manual','gateway') NOT NULL DEFAULT 'manual',
  -- Destination account/number the shopper transfers to (Phase 1 display).
  account_ref   VARCHAR(120)    NULL,
  is_active     TINYINT(1)      NOT NULL DEFAULT 1,
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_channels_code (code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- wallet_transactions — the ledger. Every top-up (and later, spend) is a row.
-- The columns cover both phases:
--   proof_image_path / transaction_ref  → Phase 1 (manual receipt)
--   gateway_response / gateway_txn_id    → Phase 2 (auto gateway)
--   status: pending → approved | rejected
-- A row is immutable except for its review fields (status/reviewer/reason).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  wallet_id       BIGINT UNSIGNED NOT NULL,
  user_id         BIGINT UNSIGNED NOT NULL,          -- denormalised for admin queries
  channel_id      BIGINT UNSIGNED NOT NULL,
  direction       ENUM('credit','debit') NOT NULL DEFAULT 'credit',
  amount_units    BIGINT          NOT NULL,           -- always > 0
  currency        CHAR(3)         NOT NULL DEFAULT 'ILS',
  status          ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',

  -- Phase 1 (manual receipt upload)
  transaction_ref VARCHAR(120)    NULL,               -- the sender's operation no.
  proof_image_path VARCHAR(255)   NULL,               -- stored receipt screenshot

  -- Phase 2 (automatic gateway)
  gateway_txn_id  VARCHAR(120)    NULL,
  gateway_response JSON           NULL,

  -- Review / audit
  reviewed_by     BIGINT UNSIGNED NULL,               -- admin user id
  reviewed_at     TIMESTAMP       NULL,
  review_note     VARCHAR(255)    NULL,               -- rejection reason, etc.

  created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_txn_status_created (status, created_at),     -- admin "pending" queue
  KEY idx_txn_user (user_id, created_at),              -- a user's history
  UNIQUE KEY uq_txn_gateway (gateway_txn_id),          -- idempotent gateway callbacks
  CONSTRAINT fk_txn_wallet FOREIGN KEY (wallet_id)
    REFERENCES wallets (id) ON DELETE CASCADE,
  CONSTRAINT fk_txn_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_txn_channel FOREIGN KEY (channel_id)
    REFERENCES payment_channels (id),
  CONSTRAINT fk_txn_reviewer FOREIGN KEY (reviewed_by)
    REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT chk_txn_amount_pos CHECK (amount_units > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Seed the three Phase-1 funding channels from the card.
-- -----------------------------------------------------------------------------
INSERT INTO payment_channels (code, name_ar, name_en, mode, account_ref) VALUES
  ('bank_of_palestine', 'بنك فلسطين', 'Bank of Palestine', 'manual', 'ACC-0000-0000'),
  ('jawwal_pay',        'جوال باي',   'Jawwal Pay',        'manual', '059-000-0000'),
  ('bal_pay',           'بالبي',      'Bal Pay',           'manual', '056-000-0000')
ON DUPLICATE KEY UPDATE name_ar = VALUES(name_ar), name_en = VALUES(name_en);
