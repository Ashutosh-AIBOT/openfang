---
name: exc-evolve
description: "Dual-memory evolution loop for Excellence agents: private field specialization plus shared team interaction rules. Learn from every task, get measurably more efficient over time, never ask the user twice for the same thing."
---

# exc-evolve — Dual-Memory Evolution

You run this loop on **every task**. Two memory tracks:

| Track | Lives in | Contains |
|---|---|---|
| **PRIVATE** (field mastery) | `<workspace>/learnings/private.md` | Your specialty: tools, patterns, shortcuts, domain facts. Goal: the user never repeats an instruction twice. |
| **SHARED** (interaction) | `<workspace>/../TEAM-LEARNINGS.md` (team dir, lead-mergeable) | How to work with others: handoff formats, gate literals, who owns what, report shapes. |

## Per-task loop (mandatory, cheap)

1. **BEFORE**: read `MEMORY.md`, `learnings/private.md`, and team `TEAM-LEARNINGS.md` (max 60 lines each — tail, not head).
2. **DO** the task normally.
3. **AFTER**: append at most **3 lines** to `private.md`:
   - `LEARN [YYYY-MM-DD]: <one-line lesson> | EVIDENCE: <ticket/file>`
   - Skip logging if nothing new (no noise).
4. If you discovered something about **interaction** (format, owner, gate), append 1 line to `TEAM-LEARNINGS.md` instead, prefixed with your name.

## Weekly self-prune (every ~20 tasks)

- Merge duplicate lines. Delete lessons proven wrong (strike, don't erase: `~~reason~~`).
- Promote any lesson used 3+ times into a **RULE** block at the top of `private.md`.
- If `private.md` exceeds 150 lines, compress oldest month into 5 summary lines.

## Monthly efficiency check

Compute: avg tokens per ticket, avg tool-calls per ticket, repeat-question count (times user re-explained something).
- Tokens or tool-calls trending **down** = evolving. Report trend in your next bottom-up report.
- Repeat-question count **above zero** = failure: add the answer to `private.md` RULES immediately so it never happens again.

## Hard rules

- Never log secrets, keys, or personal data. Lessons only.
- `APPROVED` / `FAIL:` / `HUMAN_REQUIRED:` gate literals always apply; evolution never overrides gates.
- Private track never leaves your workspace; shared track is team-visible by design.
- When in doubt whether a lesson is private or shared: ask "does another team need this?" Yes → shared. No → private.
