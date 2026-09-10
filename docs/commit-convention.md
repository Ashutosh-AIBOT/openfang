# Commit Convention (`feature/new_models` and all future branches)

> Authority: `CONTRIBUTING.md:347` (imperative mood) + `yami/git-instruction.md`
> (branch flow `feature/* -> beta -> yami`) + Conventional Commits types.
> Every commit MUST follow this file so history shows WHAT was done,
> WHY, and HOW it was verified.

## 1. Format (required)

```
<type>: <imperative subject, max 72 chars>

<WHAT — files + behavior change, 1-3 lines>
<WHY — issue/error it fixes, 1-2 lines>
<HOW VERIFIED — build/clippy/test/daemon output, 1-2 lines>
```

Rules:

- `type`: `feat` (new model/feature), `fix` (bug), `docs`, `chore`,
  `refactor`, `test`. Lowercase, colon + space after.
- Subject: imperative mood (`Add`, `Fix`, `Update`), no trailing period.
- Body: blank line after subject, then WHAT / WHY / HOW VERIFIED.
- One task = one commit = one branch. Never mix two tasks.
- NEVER commit secrets (`.env`, `secrets.env`, keys), `target/`,
  `~/.openfang/` home-dir files, or `yami/` (local docs, untracked).
- No auto-push, no auto-merge to `beta`. Commit stays on `feature/*`
  until user says `push` / `merge to beta`.

## 2. Template (copy-paste)

```bash
git add <intended files only>   # check with: git status --short && git diff --stat
git commit -m "<type>: <subject>" \
  -m "<WHAT>" \
  -m "<WHY>" \
  -m "<HOW VERIFIED>"
```

## 3. Example (good)

```
feat: add nvidia nemotron-3.5-lightning-30b-a3b NIM model

WHAT: Smart-tier catalog entry (1M ctx, 16384 out, 0.0/0.0 free,
tools+streaming) + 3 aliases; (0.0,0.0) metering rate; nvidia
wizard defaults; NVIDIA_API_KEY hint in .env.example.
WHY: Cosmos agent returned Model not found: 404 page not found
because catalog had only 5 old NIM IDs and /model could not resolve
nvidia/nemotron-3.5-lightning-30b-a3b.
HOW VERIFIED: cargo build --workspace --lib OK; runtime 993 +
kernel 289 tests OK; daemon 0.6.9 healthy; models list 6 nvidia
models avail True; live Cosmos chat returns text.
```

## 4. Example (bad — do NOT do this)

```
fixed stuff
update model
wip
```

Missing type, missing WHAT/WHY/verification, impossible to review.

## 5. Commit log — `feature/new_models` (living record)

| # | Hash | Message | What was solved |
|---|------|---------|-----------------|
| 1 | `a547155` | `feat: add nvidia nemotron-3.5-lightning-30b-a3b NIM model` | Catalog entry + aliases (`model_catalog.rs`), free pricing (`metering.rs`), wizard defaults (`init_wizard.rs`, `wizard.rs`), `.env.example` hint. Fixes Cosmos `Model not found: 404 page not found`. Verified: build OK, 993+289 tests OK, daemon healthy, 6 nvidia models, live chat returns `I'm doing well, thank you!`. Local-only (not committed): `~/.openfang/agents/Cosmos/agent.toml` fallback prefix fix. |
| 2 | _(next)_ | _Add row here on each new commit on this branch_ | _e.g. second free NIM model, same template_ |

Branch flow reminder:

```bash
# work:
git checkout beta && git pull origin beta
git checkout -b feature/new_models   # once; stay on it after
# ... edit + verify ...
git add <files>; git commit   # per this file; NO push
# only on explicit user approval:
git checkout beta && git pull origin beta
git merge feature/new_models
git push origin beta
```
