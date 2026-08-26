-- SQLite-compatible mirror of database/schema.sql, used only by the backend
-- smoke test (tests/smoke_test.php). Types are simplified (TEXT + CHECK instead
-- of ENUM, TEXT instead of JSON) but the columns and constraints match.
PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  phone_e164 TEXT NOT NULL UNIQUE,
  full_name  TEXT,
  role       TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer','admin')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wallets (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id       INTEGER NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
  balance_units INTEGER NOT NULL DEFAULT 0 CHECK (balance_units >= 0),
  currency      TEXT NOT NULL DEFAULT 'ILS',
  created_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment_channels (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  code        TEXT NOT NULL UNIQUE,
  name_ar     TEXT NOT NULL,
  name_en     TEXT NOT NULL,
  mode        TEXT NOT NULL DEFAULT 'manual' CHECK (mode IN ('manual','gateway')),
  account_ref TEXT,
  is_active   INTEGER NOT NULL DEFAULT 1,
  created_at  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  price        REAL NOT NULL,
  old_price    REAL,
  image_url    TEXT NOT NULL,
  category     TEXT NOT NULL,
  description  TEXT,
  images       TEXT,
  sizes        TEXT,
  rating       REAL NOT NULL DEFAULT 0,
  rating_count INTEGER NOT NULL DEFAULT 0,
  is_local     INTEGER NOT NULL DEFAULT 0,
  in_stock     INTEGER NOT NULL DEFAULT 1,
  store_name   TEXT,
  sort_order   INTEGER NOT NULL DEFAULT 0,
  created_at   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wallet_transactions (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  wallet_id        INTEGER NOT NULL REFERENCES wallets (id) ON DELETE CASCADE,
  user_id          INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  channel_id       INTEGER NOT NULL REFERENCES payment_channels (id),
  direction        TEXT NOT NULL DEFAULT 'credit' CHECK (direction IN ('credit','debit')),
  amount_units     INTEGER NOT NULL CHECK (amount_units > 0),
  currency         TEXT NOT NULL DEFAULT 'ILS',
  status           TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  transaction_ref  TEXT,
  proof_image_path TEXT,
  gateway_txn_id   TEXT UNIQUE,
  gateway_response TEXT,
  reviewed_by      INTEGER REFERENCES users (id) ON DELETE SET NULL,
  reviewed_at      TEXT,
  review_note      TEXT,
  created_at       TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
