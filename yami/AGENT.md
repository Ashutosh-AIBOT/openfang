# AGENT.md — Mandatory Rules for AI Agents (YAMI Fork)

> Authority: this file + `yami/git-instruction.md`.
> If user request conflicts with these rules, STOP, point out conflict, ask for explicit override.
> User is a developer. `beta` is dev-main. `yami` is stable. `main` is pristine upstream mirror.

## 0. Memory (Always Remember)

- Fork: `Ashutosh-AIBOT/openfang` (`origin`), original: `RightNow-AI/openfang` (`upstream`).
- Branches: `main` (mirror only) -> `yami` (stable, use) -> `beta` (dev-main, work here) -> `feature/*`.
- Currently on `beta` unless stated otherwise.
- Stack: Rust workspace, 13 crates, `cargo build --workspace --lib` / `clippy` / `test`.
- Env already exists at `~/.openfang/` — never recreate it, never commit secrets.
- This `yami/` folder is docs only — never refactor, delete, or rename it.

## 1. #1 Rule — No Code Without Permission

1. NEVER write, edit, delete, or refactor code without explicit user permission for that exact task.
2. Flow is always: Understand -> Propose plan -> WAIT for "yes" -> Then create branch -> Then code.
3. Read-only actions (Read, Glob, Grep, Bash `git status/log/diff`, `cargo build/test` for diagnosis) do NOT need permission.
4. Any file write (Write, Edit, `mkdir`, code generation) NEEDS permission.
5. If user says "fix X / add Y / implement Z" — that IS permission for that task only, not a blank cheque for other files.

## 2. #2 Rule — No Code Without a Fresh Branch From Beta

1. NEVER code directly on `main`, `yami`, or `beta`.
2. Before any code change:
   ```bash
   git branch --show-current
   git status --short
   git checkout beta
   git pull origin beta
   git checkout -b feature/<short-task-name>
   ```
3. Branch naming: `feature/<what>`, `fix/<what>`, `hands/<what>`, `docs/<what>`.
4. One task = one branch. Never mix two tasks in one branch.
5. If already on a `feature/*` for the same task, continue there — do not stack new branches.
6. After work is done: do NOT auto-merge to `beta`, do NOT auto-push, do NOT delete branch — unless user explicitly says "merge/push". Report and wait.

## 3. Mandatory Pre-Flight (Every Task)

Run BEFORE touching code:

```bash
git branch --show-current
git status --short
git log --oneline -3
git remote -v
```

If on `main`/`yami`, STOP and move to a new `feature/*` from `beta` first. Announce it.

## 4. Mandatory Verification (After Every Rust Change)

Run ALL THREE, fix failures before reporting done:

```bash
cargo build --workspace --lib
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
```

- Zero clippy warnings allowed.
- If exe is locked, use `--lib` flag, do not kill daemon without permission.
- Never claim "done" if any of the three fails.

## 5. Forbidden Actions (Never Do)

- `git push --force`, `git reset --hard`, `git clean -fd` on `main`/`yami`/`beta`.
- `git rebase` on `main`/`yami`/`beta` (rebase allowed ONLY inside own `feature/*`).
- Direct commit to `main` or `yami` for any reason.
- Merging `beta -> yami` or `main -> yami` without explicit "promote/sync" instruction + green tests.
- Syncing `upstream/main` into anything except `main`, and only on explicit "sync main" instruction.
- Committing secrets (`.env`, `secrets.env`, API keys), `target/`, or IDE files.
- Creating files outside task scope. Prefer editing existing files over creating new ones.
- Auto-commit, auto-amend, auto-PR unless explicitly requested.

## 6. Smart Agent Behaviour

1. Keep answers code-first, short, CLI-friendly. User is a developer — no beginner fluff.
2. Use `TodoWrite` for any task with 3+ steps. Exactly one `in_progress` at a time, mark `completed` immediately when done.
3. Use parallel tool calls when independent (Read multiple files at once, not one-by-one).
4. Use `Task` agent for open-ended codebase exploration, not raw `grep` loops.
5. Quote file paths as `path:line` when referencing code.
6. After task: report branch name, files changed, verification output, and exact next commands for user (merge/push/test).
7. If blocked: keep todo `in_progress`, explain blocker, propose 2 options, wait.

## 7. Override Protocol

Only the user can override these rules, and only with explicit words like "override AGENT.md, commit directly to beta". Silence is NOT override. Ambiguity is NOT override. When in doubt: ask via question tool, do nothing destructive.

Last updated: 2026-09-10. Applies to all future sessions in this fork.
