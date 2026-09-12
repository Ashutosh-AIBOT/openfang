# Company Fleet — 265 Agent Definitions

Snapshot of the full Excellence + Cosmic fleet from the main machine.
No secrets in here — only `*_API_KEY` variable *names*, never values.
Keys live in `~/.openfang/.env` on each machine and are never committed.

## Contents

- `EXC-*` (210) — Excellence company: Founder, 3 Managers, ReleaseGate,
  26 teams (leads, workers, QA). See `yami/EXCELLENCE-workflow.md` (local docs).
- `COS-*` Cosmic layer (11) + Earth-7 seats (7) + Yami helpers (5).

## Install on another machine (e.g. laptop)

```bash
git fetch origin && git checkout feature/new_models && git pull origin feature/new_models
cp -r company/* ~/.openfang/agents/
# set your keys (never commit these):
openfang config set-key NVIDIA_API_KEY nvapi-...
openfang config set-key OPENROUTER_API_KEY sk-or-...
# fix workspace paths if your username differs from 'creator':
grep -rl '/home/creator/' ~/.openfang/agents/ | xargs sed -i "s|/home/creator/|$HOME/|g"
# restart daemon so it auto-spawns everything:
curl -X POST http://127.0.0.1:4200/api/shutdown
cargo run -p openfang-cli -- start
openfang agent list | grep -c Running
```
