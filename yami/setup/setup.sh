#!/usr/bin/env bash
# Excellence fleet auto-setup. Run from the repo root (feature/new_models).
# Detects OS/HOME automatically. Never pushes, merges, commits, or prints keys.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
OF_HOME="${OPENFANG_HOME:-$HOME/.openfang}"
WORKSHOP_DIR="${WORKSHOP_DIR:-$HOME/Desktop/Project-Workshop}"
DRY_RUN="${DRY_RUN:-0}"

say() { printf '%s\n' "$*"; }
run() { if [ "$DRY_RUN" = "1" ]; then printf '[dry-run] %s\n' "$*"; else eval "$*"; fi }

say "== 1. Detecting environment =="
say "OS: $(uname -s) | HOME: $HOME | OPENFANG_HOME: $OF_HOME | WORKSHOP: $WORKSHOP_DIR"

say "== 2. Checking prereqs (install manually if missing) =="
for t in git cargo python3 curl opencode; do
  if command -v "$t" >/dev/null 2>&1; then say "OK: $t"; else say "MISSING: $t (install it, then re-run)"; fi
done

say "== 3. Installing 265 agents =="
run "mkdir -p \"$OF_HOME/agents\""
run "cp -r \"$REPO/company/.\" \"$OF_HOME/agents/\""
if [ "$HOME" != "/home/creator" ]; then
  say "Rewriting /home/creator/ -> $HOME in copied configs"
  run "grep -rl '/home/creator/' \"$OF_HOME/agents/\" | xargs sed -i \"s|/home/creator/|$HOME/|g\""
else
  say "HOME matches source paths, no rewrite needed"
fi

say "== 4. Installing 4 workflows =="
run "mkdir -p \"$OF_HOME/workflows\" \"$WORKSHOP_DIR/projects\""
run "cp \"$REPO/workflows/cosmos-down-decree.json\" \"$REPO/workflows/cosmos-up-report.json\" \"$REPO/workflows/cosmos-drill-mini.json\" \"$REPO/workflows/exc-all-210-single.json\" \"$OF_HOME/workflows/\""

say "== 5. API keys (paste once; stored 0600, never committed) =="
ENV_FILE="$OF_HOME/.env"
run "mkdir -p \"$OF_HOME\" && touch \"$ENV_FILE\" && chmod 600 \"$ENV_FILE\""
for KEY in NVIDIA_API_KEY OPENROUTER_API_KEY CEREBRAS_API_KEY; do
  if grep -q "^${KEY}=" "$ENV_FILE" 2>/dev/null; then
    say "kept existing: $KEY"
  else
    if [ "$DRY_RUN" = "1" ]; then say "[dry-run] would prompt for: $KEY"; continue; fi
    printf 'Paste %s (Enter to skip): ' "$KEY"
    stty -echo 2>/dev/null || true
    read -r VAL
    stty echo 2>/dev/null || true
    printf '\n'
    if [ -n "${VAL:-}" ]; then printf '%s=%s\n' "$KEY" "$VAL" >> "$ENV_FILE"; say "saved: $KEY"; else say "skipped: $KEY"; fi
    unset VAL
  fi
done
run "chmod 600 \"$ENV_FILE\""

say "== 6. Build + start daemon =="
run "cargo build --workspace --lib"
run "curl -s -X POST http://127.0.0.1:4200/api/shutdown || true"
run "sleep 3"
if [ "$DRY_RUN" = "1" ]; then say "[dry-run] would start daemon here"; else
  (cd "$REPO" && nohup cargo run -q -p openfang-cli -- start > /tmp/openfang-setup.log 2>&1 &)
  sleep 60
fi

say "== 7. Verify =="
run "curl -s --max-time 10 http://127.0.0.1:4200/api/health"
run "openfang agent list 2>/dev/null | grep -c Running || true"
run "openfang workflow list 2>/dev/null | tail -6 || true"
say "Done. Dashboard: http://127.0.0.1:4200/ | Reports: chat COS-VoiceOfYami | Approvals: openfang approvals"
