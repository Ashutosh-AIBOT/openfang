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
| 2 | `7b56ae1` | `docs: add commit convention with feature/new_models log` | New `docs/commit-convention.md`: format, template, good/bad examples, living log. |
| 3 | `fd25bd0` | `feat: add top 11 free NIM models to nvidia catalog` | 11 entries (`model_catalog.rs`, NIM 6→17, all `provider=nvidia` via NIM endpoint, 0.0/0.0 free): nano-3, diffusiongemma, deepseek-flash/pro, glimmer, laguna, gemma-4, gpt-oss, nemotron-51b, nemotron-super-120b, kimi-k3 + 22 aliases. Free pricing branches (`metering.rs`). Old 5 entries kept for backward compat; wizard default stays lightning (rank 1). Specs verified against build.nvidia.com model cards + live `/v1/models` (80 IDs). |
| 4 | _(this commit)_ | `feat: add top 10 free OpenRouter research models` | 10 `:free` entries (`model_catalog.rs`, OR 22→32, all tool-calling per live OR API): ling-vl, nex-mini/pro, inkling-small/inkling, laguna-s, north-mini, ultra-550b, lfm-2.6b, lightning-OR + 11 aliases. OR free route needs only `OPENROUTER_API_KEY`. Excluded: embeddings/TTS/rerank/safety (wrong modality), Dots3-Note (retires 2026-09-30), domain-only Fin/Sante. |

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
