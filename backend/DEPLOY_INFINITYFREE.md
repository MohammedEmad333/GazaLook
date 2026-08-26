# Deploying the GazaLook backend on InfinityFree (free)

Step-by-step guide to put the products + wallet API online for free on
[InfinityFree](https://infinityfree.com). Time: ~20–30 minutes. No credit card.

> InfinityFree gives you a public web root called **`htdocs`**. The plan below
> keeps `index.php` in `htdocs` and the application code in a protected
> `htdocs/app/` folder, with your DB password in a git-ignored `config.php`.

---

## Single-file option (easiest on mobile)

If your file manager can't extract zips (InfinityFree's web one can't), skip the
`app/` folder entirely: run `bash build-single-file.sh` to bundle the whole
backend into one `dist/index.php`, then upload just **three files** to `htdocs`:

```
htdocs/
  index.php     ← dist/index.php (the whole API in one file)
  .htaccess     ← public/.htaccess
  config.php    ← your DB credentials (from config.sample.php)
```

`config.php` must sit next to `index.php` (the code auto-detects it there). The
rest of this guide — DB creation, phpMyAdmin import, SSL, testing, pointing the
app — is identical. The multi-file layout below is the alternative.

## 0. What you'll end up with

```
htdocs/
  index.php        ← the API front controller (from backend/public/index.php)
  .htaccess        ← routing + HTTPS + hardening (from backend/public/.htaccess)
  config.php       ← your DB credentials (from backend/config.sample.php) — NOT in git
  app/
    autoload.php   ← from backend/autoload.php
    .htaccess      ← "Require all denied" (see step 5)
    src/…          ← from backend/src/
```

Your API base URL will be, e.g. `https://gazalook.infinityfreeapp.com`.

---

## 1. Create the account and site

1. Sign up at infinityfree.com and verify your email.
2. **Create Account** → choose a free subdomain (e.g. `gazalook.infinityfreeapp.com`)
   or connect your own domain. Wait a few minutes for it to activate.
3. Open the **Control Panel** (Vista/cPanel-style) for the new site.

## 2. Create the MySQL database

1. Control Panel → **MySQL Databases**.
2. Create a database, e.g. `gazalook`. InfinityFree prefixes it, so the real
   name becomes something like `epiz_1234567_gazalook`.
3. Note the four values shown on that page:
   - **DB Host** (e.g. `sql201.infinityfree.com`)
   - **DB Name** (`epiz_1234567_gazalook`)
   - **DB User** (`epiz_1234567`)
   - **DB Password** (your account DB password)

## 3. Import the schema

1. Control Panel → **phpMyAdmin** → select your database.
2. **Import** tab → upload and run **`database/schema.sql`** (wallet tables).
3. Import again with **`database/products_schema.sql`** (products + seed).
4. Confirm the `products`, `wallets`, `wallet_transactions`, `payment_channels`
   and `users` tables now exist, and `products` has 12 rows.

## 4. Add your credentials (`config.php`)

1. On your computer, copy `backend/config.sample.php` to `backend/config.php`.
2. Fill in the four values from step 2. Example:
   ```php
   return [
       'host' => 'sql201.infinityfree.com',
       'port' => '3306',
       'name' => 'epiz_1234567_gazalook',
       'user' => 'epiz_1234567',
       'pass' => 'your-db-password',
   ];
   ```
   `config.php` is git-ignored, so it never gets committed.

## 5. Upload the files

Use the Control Panel **File Manager** or any FTP client (FileZilla) with the
FTP details from **Control Panel → FTP Accounts**. Upload into `htdocs`:

| From (repo) | To (server) |
|---|---|
| `backend/public/index.php` | `htdocs/index.php` |
| `backend/public/.htaccess` | `htdocs/.htaccess` |
| `backend/config.php` | `htdocs/config.php` |
| `backend/autoload.php` | `htdocs/app/autoload.php` |
| `backend/src/` (whole folder) | `htdocs/app/src/` |

Then create **`htdocs/app/.htaccess`** with a single line so the code can never
be fetched over HTTP:

```apache
Require all denied
```

> The front controller auto-detects this layout: `index.php` looks for
> `app/autoload.php`, and `config.php` is read from the web root — no code edits
> needed.

## 6. Test it

Open in a browser / curl (replace with your subdomain):

```bash
curl -s https://gazalook.infinityfreeapp.com/api/products
curl -s https://gazalook.infinityfreeapp.com/api/products/p1
curl -s https://gazalook.infinityfreeapp.com/api/wallet/channels
```

You should get `{"ok":true,"data":{...}}`. If you see an InfinityFree "security
check" page on the very first request, that's their bot protection — real app
requests from the phone pass; for curl add `-H 'User-Agent: Mozilla/5.0'`.

## 7. Point the Flutter app at it

Build the app with the API base URL (no code change):

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://gazalook.infinityfreeapp.com
```

Without `API_BASE_URL` the app keeps using the bundled demo catalog, so debug
builds and CI stay green.

---

## Enable free HTTPS (SSL)

InfinityFree issues free SSL via **Control Panel → Free SSL Certificates** (or
the linked "SSL/CloudFlare" tool). Issue a certificate for your (sub)domain,
wait for it to go active, then the `.htaccess` HTTPS redirect will serve
everything over `https://`.

## Limitations to expect (free tier)

- **Outbound connections are blocked** on InfinityFree. Phase-1 (manual receipt
  upload + admin approval) works fully; **Phase-2 payment gateways** need
  outbound HTTPS, so they require a paid host or a VPS.
- Shared CPU/hit limits and **no reliable cron**. Fine for an MVP/demo.
- Receipt screenshots: store them under `htdocs/uploads/` (create the folder)
  for now; move to object storage when you outgrow the free disk.
- For anything production-grade, migrate to the VPS setup in `README.md`
  (Oracle Always Free is a good free step up with outbound access).

## Troubleshooting

- **500 error / "autoload not found"** → the `app/` folder or `autoload.php`
  wasn't uploaded to `htdocs/app/`.
- **DB connection error** → re-check the four values in `config.php`; the host
  is the `sqlNNN...` value, not `localhost` (InfinityFree DB is on a separate
  server).
- **404 on `/api/...`** → `.htaccess` didn't upload, or `mod_rewrite` is off;
  make sure `htdocs/.htaccess` exists.
- **Arabic shows as `????`** → ensure phpMyAdmin imported with UTF-8 (the schema
  already sets `utf8mb4`).
