# YAMI — Git Instructions (Human + Agent — Must Follow)

> Source of truth for branches in this fork.
> `beta` is the working-main. `yami` is stable. `main` is pristine upstream mirror.
> Both humans and AI agents MUST follow this file.

## 1. Branch Hierarchy

```
upstream/main (RightNow-AI/openfang — original)
    |
    v (sync only, ff-only)
origin/main (Ashutosh-AIBOT/openfang — pristine mirror, NEVER commit directly)
    |
    v (merge main -> yami)
yami (YOUR stable — only merge from main or beta, NEVER direct work)
    |
    v (merge yami -> beta, branch from here)
beta (YOUR dev-main — all work branches off here, currently checked out)
    |
    v
feature/*, fix/*, hands/* (throwaway work branches)
    |
    v (merge back when working)
beta -> yami (promote only when beta is fully tested)
```

Current remotes:

- `origin` = `https://github.com/Ashutosh-AIBOT/openfang.git` (your fork)
- `upstream` = `https://github.com/RightNow-AI/openfang.git` (original)

Check anytime:

```bash
git remote -v
git branch -vv
git status
```

## 2. Golden Rules (Never Break)

1. `main` = mirror only. No edits, no commits, no direct push except upstream sync.
2. `yami` = stable you actually use. No direct coding on `yami`.
3. `beta` = dev-main. Treat it like `main` in a normal repo.
4. All new work = new branch FROM `beta`: `feature/<name>`, `fix/<name>`, `hands/<name>`.
5. Merge flow is one-way forward: `feature/* -> beta -> yami`. Never `yami -> feature/*` except to refresh, never `beta -> main`, never `yami -> main`.
6. Promote `beta -> yami` only after: build + clippy + tests pass.
7. Always `git pull` before branching or merging.

## 3. Daily Commands

### A. Start new work (from beta)

```bash
git checkout beta
git pull origin beta
git checkout -b feature/my-change
# ... code ...
git add -A
git commit -m "feat: my-change"
git push -u origin feature/my-change
```

### B. Finish work -> merge back to beta

```bash
git checkout beta
git pull origin beta
git merge feature/my-change
git push origin beta
# optional cleanup:
git branch -d feature/my-change
git push origin --delete feature/my-change
```

### C. Promote stable beta -> yami

```bash
# 1. verify beta is green first:
cargo build --workspace --lib
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace

# 2. promote:
git checkout yami
git pull origin yami
git merge beta
git push origin yami

# 3. refresh beta so they stay in sync:
git checkout beta
git merge yami
git push origin beta
```

### D. Sync main from original openfang (over time)

```bash
git checkout main
git fetch upstream
git merge upstream/main --ff-only
git push origin main
```

If `main` has diverged (ff-only fails), STOP. Do not force. Ask human:

```bash
git log --oneline origin/main..upstream/main
git diff origin/main..upstream/main --stat
```

### E. Update yami with latest upstream (smart update)

```bash
# first sync main (D), then:
git checkout yami
git pull origin yami
git merge main
# resolve conflicts in favour of keeping yami customizations, test, then:
git push origin yami
git checkout beta
git merge yami
git push origin beta
```

## 4. Conflict Safety

- Merge, never rebase `yami` or `beta` (preserves history, keeps them safe).
- Rebase is allowed ONLY inside your own `feature/*` before merging to `beta`:
  ```bash
  git checkout feature/my-change
  git fetch origin
  git rebase origin/beta
  ```
- If conflict during `beta -> yami`: keep `yami` custom logic, manually port `beta` fixes, run full health stack before pushing.

## 5. Instructions for AI Agents (MUST Follow)

You are working in Ashutosh's fork. The user is a developer.

1. **Always start by checking context:**
   ```bash
   git branch --show-current
   git status --short
   git remote -v
   ```
2. **Default working branch is `beta`.** If not on `beta` or a `feature/*` branched from `beta`, switch to `beta` first unless user explicitly says otherwise.
3. **Never commit directly to `main` or `yami`.** If asked to implement something while on `main`/`yami`, create `feature/<task>` from `beta` automatically and work there.
4. **New task flow:**
   - `git checkout beta && git pull origin beta`
   - `git checkout -b feature/<short-name>`
   - implement + verify
   - do NOT auto-merge to `beta` or auto-push unless user asks. Leave changes on feature branch and report.
5. **After every Rust change, run ALL THREE (per AGENTS.md / CLAUDE.md):**
   ```bash
   cargo build --workspace --lib
   cargo clippy --workspace --all-targets -- -D warnings
   cargo test --workspace
   ```
6. **Never run `git push --force`, `git reset --hard`, `git rebase` on `main`/`yami`/`beta`.** Only allowed inside `feature/*`.
7. **Never add `upstream` changes into `beta`/`yami` without explicit instruction.** `main` sync is a separate deliberate step.
8. **This file (`yami/git-instruction.md`) is the authority.** If user instruction conflicts with it, point out the conflict and follow this file unless user overrides explicitly.
9. **Do not delete or rename the `yami/` folder or this file.** It is documentation, not code. Exclude it from refactors.

## 6. Quick Status Check (copy-paste)

```bash
git branch --show-current && git status --short && git log --oneline -5 && git branch -vv
```

## 7. Visual Reminder

```
Work HERE: beta + feature/*
Use THERE: yami (stable)
Mirror ONLY: main <- upstream/main
```

Last verified: 2026-09-10, all three (`main`, `yami`, `beta`) at `acf2587 bump v0.6.9`, clean sync.
