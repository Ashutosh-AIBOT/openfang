# Company Workflows — live definitions snapshot

Same 4 workflows registered on the main machine's daemon.
No secrets in here — prompts reference agents by name only.

| File | Workflow | Steps |
|---|---|---|
| `cosmos-down-decree.json` | Top-down decree across the cosmic hierarchy + 7 Earth seats | 22 |
| `cosmos-up-report.json` | Bottom-up report: seats → chain → Voice digest → Cosmos sign | 20 |
| `cosmos-drill-mini.json` | 3-step validation drill (Relay → Kai → Voice) | 3 |
| `exc-all-210-single.json` | Single end-to-end run over all 210 company agents | 269 |

## Register on another machine

```bash
openfang workflow create workflows/cosmos-down-decree.json
openfang workflow create workflows/cosmos-up-report.json
openfang workflow create workflows/cosmos-drill-mini.json
openfang workflow create workflows/exc-all-210-single.json
openfang workflow list
```

Note: fresh registrations get new IDs (IDs differ per machine).
Long runs: track via dashboard Workflows page or `/runs` API —
the CLI times out at 120s but runs continue server-side.
