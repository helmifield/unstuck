#!/usr/bin/env bash
# Deterministic test for the secret-file detection logic.
#
# Guards against regressions, in particular the .env.example false positive
# documented in docs/BOOTSTRAP_AUDIT.md. Runs locally and in CI.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-secret-files.sh"
pass=0
fail=0

expect_clean() {
  local input="$1" name="$2"
  if printf '%s\n' "$input" | "$SCRIPT" >/dev/null 2>&1; then
    echo "PASS: $name -> clean"; pass=$((pass + 1))
  else
    echo "FAIL: $name -> expected clean, got violation"; fail=$((fail + 1))
  fi
}

expect_violation() {
  local input="$1" name="$2"
  if printf '%s\n' "$input" | "$SCRIPT" >/dev/null 2>&1; then
    echo "FAIL: $name -> expected violation, got clean"; fail=$((fail + 1))
  else
    echo "PASS: $name -> violation"; pass=$((pass + 1))
  fi
}

# --- Must NOT be flagged (non-secret) ---
expect_clean ".env.example" ".env.example is allowed"
expect_clean "README.md" "plain doc is ignored"
expect_clean "src/index.ts" "source file is ignored"
expect_clean "docs/SECURITY.md" "docs are ignored"
expect_clean "$(printf '%s\n' '.env.example' 'README.md' 'src/index.ts')" "mixed non-secret list is clean"
expect_clean "subdir/.env.example" "nested .env.example is allowed"

# --- Must be flagged (secret-like) ---
expect_violation ".env" ".env is flagged"
expect_violation ".env.local" ".env.local is flagged"
expect_violation ".env.production" ".env.production is flagged"
expect_violation "config/.env" "nested .env is flagged"
expect_violation "private.key" "*.key is flagged"
expect_violation "cert.pem" "*.pem is flagged"
expect_violation "AuthKey_ABCD123.p8" "*.p8 is flagged"
expect_violation "profile.mobileprovision" "*.mobileprovision is flagged"
expect_violation "service-account.json" "service-account.json is flagged"
expect_violation "credentials.json" "credentials.json is flagged"
expect_violation "secrets.yaml" "secrets.* is flagged"
expect_violation "secrets.json" "secrets.* (json) is flagged"
expect_violation "deploy/secrets.env" "nested secrets.* is flagged"

# --- Fail closed even when a non-secret example is also present ---
expect_violation "$(printf '%s\n' '.env.example' 'id_rsa.pem')" "secret present alongside .env.example fails closed"

echo ""
echo "Results: $pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
