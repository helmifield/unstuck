#!/usr/bin/env bash
# Fail closed if any tracked file matches a secret-like name.
#
# Mirrors the secret-file patterns in .gitignore ("Environment / secrets" block),
# with an explicit allow-list for non-secret example files such as .env.example.
#
# Input: filenames, one per line, passed either as arguments or on stdin.
# Exit: 0 if clean, 1 if one or more secret-like files are found.
set -euo pipefail

# Non-secret examples that would otherwise match the secret patterns below.
# Keep in sync with the negated (!) entries in .gitignore.
ALLOW_RE='(^|/)(\.env\.example)$'

# Secret-like filename patterns. Aligned with .gitignore:
#   .env  .env.*   ->  (^|/)\.env(\..*)?$
#   *.pem *.key *.p12 *.p8 *.mobileprovision  ->  .*\.(pem|key|p12|p8|mobileprovision)$
#   service-account.json credentials.json     ->  ...service-account\.json$|credentials\.json$
#   secrets.*                                 ->  secrets\..*$
SECRET_RE='(^|/)(\.env(\..*)?$|.*\.(pem|key|p12|p8|mobileprovision)$|service-account\.json$|credentials\.json$|secrets\..*)$'

# Accept filenames from args, otherwise read from stdin (e.g. `git ls-files |`).
if [ "$#" -gt 0 ]; then
  files=("$@")
else
  mapfile -t files
fi

violations=()
for file in "${files[@]}"; do
  file="${file%$'\r'}" # tolerate CRLF line endings
  [ -z "$file" ] && continue
  if printf '%s' "$file" | grep -qE "$ALLOW_RE"; then
    continue
  fi
  if printf '%s' "$file" | grep -qE "$SECRET_RE"; then
    violations+=("$file")
  fi
done

if [ "${#violations[@]}" -gt 0 ]; then
  echo "::error::Potential secret file(s) detected in tracked files:"
  for v in "${violations[@]}"; do
    printf '  - %s\n' "$v"
  done
  echo "If a flagged file is a non-secret example, add it to the allow-list in .github/scripts/check-secret-files.sh."
  exit 1
fi

echo "No secret-like tracked files detected."
