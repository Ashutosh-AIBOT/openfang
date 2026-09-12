# Laptop Fleet Setup — Full Guide (Excellence Company)

> New here? **Read this file top to bottom, then run one command.**
> Everything is explained in order: fork → clone → auto-setup → verify → daily use.

You do **4 small manual things**. An agent (or the script) does **everything else
automatically**, with paths detected from your laptop (Linux, macOS, or WSL —
pick any folder, including a `D:` drive folder under WSL/mapped drives).

## Part 0 — What YOU do manually (10 minutes)

1. **Install basics:** Git, Rust (`rustup.rs`), Python 3, curl, and the
   `opencode` CLI on the laptop.
2. **Fork on github.com:** open `Ashutosh-AIBOT/openfang` → **Fork**.
   The fork copies **all branches** (`main`, `beta`, `yami`, `feature/*`).
3. **Have your 3 API keys ready** (paste when asked, never commit them):
   `NVIDIA_API_KEY`, `OPENROUTER_API_KEY`, `CEREBRAS_API_KEY` (optional).
4. **Run one command** (Section 2). Approve when it asks.

## Part 1 — Clone (agent runs this, or paste it yourself)

```bash
git clone https://github.com/<you>/openfang.git
cd openfang
git remote add upstream https://github.com/Ashutosh-AIBOT/openfang.git
git fetch upstream
git checkout feature/new_models
git pull origin feature/new_models
# work folder: default ~/Desktop/Project-Workshop, or pass your own:
# export WORKSHOP_DIR="/mnt/d/Project-Workshop"   # example: D: drive via WSL
```

Sync back and forth anytime:

```bash
git fetch upstream
git checkout beta && git merge upstream/beta        # take original's latest
git push origin feature/new_models                  # send your work to your fork
```

## Part 2 — Automatic setup (agent runs; paths auto-detect)

```bash
bash yami/setup/setup.sh              # defaults, prompts for keys once
# or fully custom:
WORKSHOP_DIR="/mnt/d/Project-Workshop" bash yami/setup/setup.sh
```

The script automatically: detects OS/HOME → checks prereqs → copies all
265 agents from `company/` → rewrites `/home/creator/` to your HOME →
copies the 4 workflow JSONs → merges the 3 API keys into
`~/.openfang/.env` (0600, never committed) → builds → starts daemon →
health-checks → prints counts. It never pushes, merges, or touches `yami/`.

## Part 3 — Verify (agent shows you this output)

```bash
curl -s http://127.0.0.1:4200/api/health        # {"status":"ok",...}
openfang agent list | grep -c Running            # expect 265+
openfang workflow list                           # 4 workflows
cargo run -q -p openfang-cli -- models list      # 49 models, avail True
```

Open `http://127.0.0.1:4200/` → Workflows page shows all 4 visually.

## Part 4 — Daily use

- Give work: WebChat → `COS-CommsRelay` (fleet orders) or a Lead.
- Approve plans: `openfang approvals approve <id>`.
- Reports: `COS-VoiceOfYami` digest every 30m in WebChat.
- Track long runs via dashboard (CLI times out at 120s; runs continue server-side).
