#!/usr/bin/env bash
# UNSTUCK development control layer.
#
# A single entry point so developers do not start services by hand. All paths
# are relative to the repo root (no machine-specific paths). Reports service
# health clearly. Does NOT create or use production credentials.
#
# Usage:
#   scripts/dev.sh up       start the API (background)
#   scripts/dev.sh down     stop the API
#   scripts/dev.sh status   show running state + live health probe
#   scripts/dev.sh test     run all available tests (api; ios reported if swift missing)
#   scripts/dev.sh lint     run all linters (api)
#   scripts/dev.sh          (no arg) prints help
set -euo pipefail

# Resolve repo root from this script's location, regardless of cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PID_FILE="$REPO_ROOT/.dev/api.pid"
LOG_FILE="$REPO_ROOT/.dev/api.log"
DEFAULT_PORT="${PORT:-3000}"
DEFAULT_HOST="${HOST:-127.0.0.1}"
HEALTH_URL="http://${DEFAULT_HOST}:${DEFAULT_PORT}/health"

c_red() { printf '\033[31m'; }
c_grn() { printf '\033[32m'; }
c_ylw() { printf '\033[33m'; }
c_rst() { printf '\033[0m'; }
say() { printf '%s\n' "$*"; }

ensure_node() {
  command -v node >/dev/null 2>&1 || { say "$(c_red)node not found$(c_rst)"; exit 1; }
}

api_running_pid() {
  [ -f "$PID_FILE" ] || return 1
  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  [ -n "$pid" ] || return 1
  if kill -0 "$pid" 2>/dev/null; then
    echo "$pid"
    return 0
  fi
  return 1
}

cmd_up() {
  ensure_node
  mkdir -p "$REPO_ROOT/.dev"
  if pid="$(api_running_pid)"; then
    say "$(c_ylw)API already running$(c_rst) (pid $pid)"; return 0
  fi
  say "$(c_grn)Starting API…$(c_rst)"
  # Install deps if missing (workspaces hoist).
  [ -d "$REPO_ROOT/node_modules/@nestjs" ] || npm --prefix "$REPO_ROOT" install >/dev/null
  # Ensure the shared contracts package and the API are built (DI metadata lives
  # only in compiled output; tsx/esbuild do not emit it). Cheap if up-to-date.
  npm --prefix "$REPO_ROOT" run build >/dev/null 2>&1
  PORT="$DEFAULT_PORT" HOST="$DEFAULT_HOST" NODE_ENV=local \
    npm --workspace @unstuck/api run start >"$LOG_FILE" 2>&1 &
  local pid=$!
  echo "$pid" >"$PID_FILE"
  # Wait for health (max ~20s).
  for _ in $(seq 1 40); do
    if curl -sf "$HEALTH_URL" >/dev/null 2>&1; then
      say "$(c_grn)API up$(c_rst) pid=$pid  $HEALTH_URL  (logs: .dev/api.log)"
      return 0
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
      say "$(c_red)API exited during startup. Logs:$(c_rst)"; tail -n 20 "$LOG_FILE" || true
      rm -f "$PID_FILE"
      return 1
    fi
    sleep 0.5
  done
  say "$(c_red)API did not become healthy in time. Logs:$(c_rst)"; tail -n 20 "$LOG_FILE" || true
  return 1
}

cmd_down() {
  if pid="$(api_running_pid)"; then
    kill "$pid" 2>/dev/null || true
    say "$(c_grn)Stopped API$(c_rst) (pid $pid)"
  else
    say "$(c_ylw)API not running$(c_rst)"
  fi
  rm -f "$PID_FILE"
}

cmd_status() {
  if pid="$(api_running_pid)"; then
    say "$(c_grn)API running$(c_rst) (pid $pid)"
  else
    say "$(c_ylw)API not running$(c_rst)"
  fi
  if curl -sf "$HEALTH_URL" >/dev/null 2>&1; then
    local body
    body="$(curl -s "$HEALTH_URL" 2>/dev/null || echo '{}')"
    say "$(c_grn)health: ok$(c_rst)  $body"
  else
    say "$(c_red)health: no response at $HEALTH_URL$(c_rst)"
  fi
  if command -v swift >/dev/null 2>&1; then
    say "swift: available"
  else
    say "swift: $(c_ylw)not available (iOS build/test skipped)$(c_rst)"
  fi
}

cmd_test() {
  say "$(c_grn)Running backend tests…$(c_rst)"
  npm --workspace @unstuck/api run test
  if command -v swift >/dev/null 2>&1; then
    say "$(c_grn)Running iOS boundary tests…$(c_rst)"
    (cd "$REPO_ROOT/apps/iOS" && swift test)
  else
    say "$(c_ylw)swift not available — iOS tests skipped (reported, not faked)$(c_rst)"
  fi
}

cmd_lint() {
  say "$(c_grn)Running backend lint…$(c_rst)"
  npm --workspace @unstuck/api run lint
}

cmd_help() {
  cat <<'EOF'
UNSTUCK dev control
  up      start the API (background)
  down    stop the API
  status  show running state + live health probe
  test    run all available tests
  lint    run all linters
EOF
}

case "${1:-}" in
  up) cmd_up ;;
  down) cmd_down ;;
  status) cmd_status ;;
  test) cmd_test ;;
  lint) cmd_lint ;;
  *) cmd_help ;;
esac
