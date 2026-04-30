#!/usr/bin/env bash
set -euo pipefail

# Xcode Debug build phase helper.
# Starts the local diary agent backend exactly once, so opening/running the iOS
# app from Xcode also brings up the backend service.

if [[ "${CONFIGURATION:-Debug}" != "Debug" ]]; then
  echo "[AgentServer] Skip: CONFIGURATION=${CONFIGURATION:-unknown}"
  exit 0
fi

export PATH="$HOME/.bun/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

PROJECT_ROOT="${SRCROOT:-}"
if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

SERVER_DIR="$PROJECT_ROOT/agent-server"
PORT="${AGENT_PORT:-8787}"
HEALTH_URL="http://127.0.0.1:${PORT}/health"
LOG_DIR="$PROJECT_ROOT/tmp/agent-server"
PID_FILE="$LOG_DIR/agent-server.pid"
LOG_FILE="$LOG_DIR/agent-server.log"
ENV_PATH="${AGENT_ENV_PATH:-$HOME/clawd-project/the-next/packages/app/.env}"

mkdir -p "$LOG_DIR"

if /usr/bin/curl -fsS --max-time 1 "$HEALTH_URL" >/dev/null 2>&1; then
  echo "[AgentServer] Already running at $HEALTH_URL"
  exit 0
fi

if [[ -f "$PID_FILE" ]]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" >/dev/null 2>&1; then
    echo "[AgentServer] Process $OLD_PID exists, waiting for health..."
    for _ in {1..10}; do
      if /usr/bin/curl -fsS --max-time 1 "$HEALTH_URL" >/dev/null 2>&1; then
        echo "[AgentServer] Ready at $HEALTH_URL"
        exit 0
      fi
      sleep 0.5
    done
    echo "[AgentServer] Existing process not healthy; killing stale process $OLD_PID."
    kill "$OLD_PID" >/dev/null 2>&1 || true
    sleep 0.5
  fi
fi

if ! command -v bun >/dev/null 2>&1; then
  echo "[AgentServer] ERROR: bun is not installed or not on PATH."
  echo "[AgentServer] Install Bun first, then rerun Xcode."
  exit 1
fi

if [[ ! -d "$SERVER_DIR" ]]; then
  echo "[AgentServer] ERROR: server directory not found: $SERVER_DIR"
  exit 1
fi

if [[ ! -f "$ENV_PATH" ]]; then
  echo "[AgentServer] ERROR: model env file not found: $ENV_PATH"
  echo "[AgentServer] Set AGENT_ENV_PATH to override."
  exit 1
fi

if [[ ! -d "$SERVER_DIR/node_modules" ]]; then
  echo "[AgentServer] Installing agent-server dependencies..."
  (
    cd "$SERVER_DIR"
    bun install --silent >>"$LOG_FILE" 2>&1
  )
fi

echo "[AgentServer] Starting at $HEALTH_URL"
echo "[AgentServer] Log: $LOG_FILE"

(
  cd "$SERVER_DIR"
  AGENT_PORT="$PORT" AGENT_ENV_PATH="$ENV_PATH" nohup bun src/server.ts >>"$LOG_FILE" 2>&1 &
  echo $! >"$PID_FILE"
)

for _ in {1..20}; do
  if /usr/bin/curl -fsS --max-time 1 "$HEALTH_URL" >/dev/null 2>&1; then
    echo "[AgentServer] Ready at $HEALTH_URL"
    exit 0
  fi
  sleep 0.5
done

echo "[AgentServer] ERROR: server did not become healthy. Last log lines:"
/usr/bin/tail -40 "$LOG_FILE" || true
exit 1
