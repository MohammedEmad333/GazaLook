#!/usr/bin/env bash
# Concatenates the whole backend into ONE index.php (bracketed namespaces),
# for hosts whose file manager can't extract zips or where uploading many
# files is impractical (e.g. InfinityFree on mobile).
#
# Usage:   bash backend/build-single-file.sh            # → dist/index.php
# Deploy:  upload dist/index.php + public/.htaccess + a filled config.php
#          into the web root (htdocs). See DEPLOY_INFINITYFREE.md.
set -euo pipefail
cd "$(dirname "$0")"

OUT_DIR="dist"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/index.php"

# Wrap one source file in a bracketed namespace block: keep from its
# `namespace X;` line to EOF, turn it into `namespace X {`, and close with `}`.
emit() {
  awk '
    /^namespace [^{]*;[[:space:]]*$/ && !s { l=$0; sub(/;[[:space:]]*$/," {",l); print l; s=1; next }
    s { print }
    END { if (s) print "}" }
  ' "$1"
  echo
}

# Dependency-ordered: interfaces/parents before implementers/children.
FILES=(
  src/Support/Money.php
  src/Domain/TransactionStatus.php
  src/Domain/ChannelMode.php
  src/Domain/PaymentChannel.php
  src/Domain/WalletTransaction.php
  src/Payment/PaymentException.php
  src/Payment/TopUpRequest.php
  src/Payment/TopUpResult.php
  src/Payment/PaymentStrategy.php
  src/Repository/WalletRepository.php
  src/Repository/TransactionRepository.php
  src/Repository/ChannelRepository.php
  src/Repository/ProductRepository.php
  src/Wallet/WalletException.php
  src/Wallet/WalletService.php
  src/Payment/Strategies/ManualReceiptUploadStrategy.php
  src/Payment/Strategies/GatewayStrategy.php
  src/Payment/Strategies/JawwalPayStrategy.php
  src/Payment/Strategies/BankOfPalestineStrategy.php
  src/Payment/PaymentService.php
  src/Database/Connection.php
  src/Http/JsonResponse.php
  src/Http/ProductController.php
  src/Http/WalletController.php
  src/Http/AdminController.php
  src/Http/Container.php
)

{
  echo "<?php"
  echo "declare(strict_types=1);"
  echo "// GazaLook backend — SINGLE-FILE build (auto-generated from backend/src/*)."
  echo "// Do not hand-edit; edit the sources and re-run backend/build-single-file.sh."
  echo
  for f in "${FILES[@]}"; do emit "$f"; done
  # The router runs in the global namespace after every class is defined.
  echo "namespace {"
  echo "use GazaLook\\Wallet\\Http\\Container;"
  echo "use GazaLook\\Wallet\\Http\\JsonResponse;"
  awk '/\$method = \$_SERVER/{p=1} p{print}' public/index.php
  echo "}"
} > "$OUT"

php -l "$OUT"
echo "Built $OUT"
