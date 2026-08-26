# Deploying the GazaLook backend on AlwaysData (free)

Unlike InfinityFree, [AlwaysData](https://www.alwaysdata.com) does **not** put a
JavaScript anti-bot wall in front of your site, so a mobile app can call the API
directly. Free plan: 100 MB, PHP + MySQL, phpMyAdmin, HTTPS on
`*.alwaysdata.net`. Files are uploaded over **SFTP/FTP** (no web file manager),
so install a mobile FTP app first (e.g. **Material Files**, **AndFTP**, or
**Turbo Client**).

You reuse the exact same files as the single-file build:
`dist/index.php`, `public/.htaccess`, and a `config.php` (with AlwaysData's DB
values). SQL is the same `database/*.sql`.

---

## 1. Create the account + site

1. Sign up at alwaysdata.com → **free 100 MB** plan (no card). Pick an account
   name — it becomes your subdomain `‹account›.alwaysdata.net`.
2. Admin panel: https://admin.alwaysdata.net
3. **Web → Sites**: a site usually exists for `‹account›.alwaysdata.net`. Open it
   (or Add site) and set:
   - **Type**: PHP
   - **Directory**: `/www`
   - Save.

## 2. Create the MySQL database

**Databases → MySQL → Add a database**:
- Database name → e.g. `gazalook` (stored as `‹account›_gazalook`).
- Create/allow a user (your account user works). Note the password.
- Note the **host**: `mysql-‹account›.alwaysdata.net`, port `3306`.

## 3. Import the schema

**Databases → MySQL → phpMyAdmin** → select `‹account›_gazalook` → **Import**:
- Import `database/schema.sql`, then `database/products_schema.sql`.
- Check `products` = 12 rows.

## 4. Prepare config.php

Edit your local `config.php` with AlwaysData values:
```php
<?php
return [
    'host' => 'mysql-‹account›.alwaysdata.net',
    'port' => '3306',
    'name' => '‹account›_gazalook',
    'user' => '‹account›',           // or the DB user you created
    'pass' => 'YOUR_DB_PASSWORD',
];
```

## 5. Upload the files over FTP

**Remote access → FTP** (or SSH) in the panel gives you:
- host `ftp-‹account›.alwaysdata.net`, username `‹account›`, your account password.

In your FTP app, connect and open the **`www/`** folder, then upload:
- `dist/index.php`  → `www/index.php`
- `public/.htaccess` → `www/.htaccess`
- `config.php`      → `www/config.php`

(That's the single-file build — three files, no `app/` folder, no extraction.)

## 6. Test

```
https://‹account›.alwaysdata.net/api/products      → 12 products
https://‹account›.alwaysdata.net/api/wallet/channels
https://‹account›.alwaysdata.net/api/products/p1
```

You should get `{"ok":true,...}` — and this time it works from the app too.

## 7. Point the app at it + rebuild

Update the default in `lib/core/constants/app_constants.dart`:
```dart
defaultValue: 'https://‹account›.alwaysdata.net',
```
Commit & push — CI rebuilds the APK against the new host. (Or build locally with
`--dart-define=API_BASE_URL=https://‹account›.alwaysdata.net`.)

## Troubleshooting

- **404 on /api/...** → `.htaccess` missing in `www/`, or the site Type isn't PHP
  / Directory isn't `/www`.
- **500 / DB error** → re-check `config.php`; host must be
  `mysql-‹account›.alwaysdata.net` (not localhost).
- **Still invalid response in the app** → confirm you're on AlwaysData's URL, not
  the old InfinityFree one.
