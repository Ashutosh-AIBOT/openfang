# EXCELLENCE Company — Full End-to-End Agent Workflow (FINAL v4)

> Company: **Excellence**. Fleet: **210 agents, 26 teams, 5 layers**.
> Authority: this file + `yami/AGENT.md` + `yami/git-instruction.md` + `docs/commit-convention.md` + `docs/pipeline-playbook.md` (when written).
> Keys in play: **NVIDIA primary → OpenRouter fallback → different NVIDIA model fallback-2**. Cerebras is saved but NOT used anywhere in this design.
> OpenFang components used ONLY (verified in repo): workflow engine (`crates/openfang-kernel/src/workflow.rs`, `docs/workflows.md`), fallback driver chain (`kernel.rs:5681-5758`), `[[fallback_models]]` (`agent.rs:407-411`), triggers (`kernel/src/triggers.rs`, 9 patterns), cron (`kernel/src/cron.rs`, `background.rs`), approvals (`openfang approvals` CLI + `kernel/src/approval.rs`), skills (`crates/openfang-skills/bundled/*`, `skills=[...]` in `agent.toml`), registry (`kernel/src/registry.rs`), metering (`kernel/src/metering.rs`).
> Gate literals (engine matches substrings, case-insensitive): `APPROVED` / `FAIL: <reasons>` / `HUMAN_REQUIRED: <why>`.

## 1. Naming convention (layer-coded, unique for workflow `agent_name` refs)

```
EXC-L<layer>-<Team>-<Function>[A/B…]
L1 = Founder/Gate · L2 = Managers/Stewards · L3 = Leads · L4 = Workers · L5 = QA/Verifiers
```

`EXC-L4-Backend-APIBuilderA` reads as: Excellence, worker layer, Backend team, API builder. Every agent.toml `workspace` lives under `~/Desktop/Project-Workshop/projects/<project>/agents/<name>/`; gate artifacts under `gates/<ticket-id>/`.

## 2. Model core (only these may be assigned)

NVIDIA (9): `lightning`=`nvidia/nemotron-3.5-lightning-30b-a3b`, `nano-3`=`nvidia/nemotron-nano-3-30b-a3b`, `diffusiongemma`=`google/diffusiongemma-26b-a4b-it`, `gpt-oss-20b`=`openai/gpt-oss-20b`, `laguna-xs`=`poolside/laguna-xs-2.1`, `glimmer`=`meta/muse-glimmer-30b` ⭐ mandatory vision, `gemma-4`=`google/gemma-4-31b-it`, `flash`=`deepseek-ai/deepseek-v4-flash-0731`, `super-120b`=`nvidia/nemotron-3-super-120b-a12b`.
OR-free (8): `nex-pro`=`openrouter/nex-agi/nex-n2.5-pro:free`, `inkling-small`=`openrouter/thinkingmachines/inkling-small:free`, `ling-vl`=`openrouter/inclusionai/ling-3.0-flash-vl:free`, `laguna-s`=`openrouter/poolside/laguna-s-2.1:free`, `nex-mini`=`openrouter/nex-agi/nex-n2.5-mini:free`, `north-mini`=`openrouter/cohere/north-mini-code:free`, `inkling`=`openrouter/thinkingmachines/inkling:free`, `or-lightning`=`openrouter/nvidia/nemotron-3.5-lightning:free`.
Every agent: `[model] NVIDIA-1` + `[[fallback_models]] OR` + `[[fallback_models]] NVIDIA-2 (different)`. Banned: all heavies (kimi, ultra-550b, inkling-975B, pro-0813, 405b, 340b), all non-tool tinies, Cerebras everywhere.

## 3. Overhead 5 (command layer)

| Agent | Work | Chain | Connects to |
|---|---|---|---|
| EXC-L1-Founder | Strategy, final sign-off, tie-breaks, SEV1 page receiver | super-120b → inkling → flash | Receives Gate D/E packets; pages via Circuit-Breaker |
| EXC-L2-MgrBuild | Delivery of teams 2–10, co-owns Gate A waivers | super-120b → inkling-small → flash | Leads 2–10 report up; joint calls with MgrQuality |
| EXC-L2-MgrQuality | Gates for teams 11–14/16–17, waiver authority (non-security) | super-120b → inkling-small → flash | QA leads report; blocks releases on quality |
| EXC-L2-MgrResearch | Teams 1/8/22 + release-flow coordination | super-120b → inkling-small → flash | Research/ML/Analytics leads; Release-Gate |
| EXC-L2-ReleaseGate | Cross-team E2E + Circuit-Breaker halt/page duty | flash → laguna-s → super-120b | All teams' Gate C outputs; Founder on SEV1 |

## 4. Teams 1–26 (195 agents: Lead L3 → workers L4 → QA L5; QA also runs Gate A+B + Prompt-Surgeon ≤3 retries)

### T1 Research (12) — flash → nex-pro → nano-3 — skills: web-search,searxng,data-analyst,prompt-engineer
| Agent | Work |
|---|---|
| EXC-L3-Research-Lead | Splits research tickets, owns memo sign-off |
| EXC-L4-Research-ReqMiner | Requirement mining (nex-mini) |
| EXC-L4-Research-EvidenceHunter | Sources + citations (inkling-small) |
| EXC-L4-Research-CompetitorScout | Competitor/tech analysis (gemini-flash) |
| EXC-L4-Research-RiskAnalyst | Risk + feasibility notes (laguna-s) |
| EXC-L4-Research-FeasibilityProber | PoC spikes (north-mini) |
| EXC-L4-Research-EstimateScribe | Estimation sheets (gpt-oss-20b) |
| EXC-L4-Research-VisionResearcher | Screenshots/charts/docs (glimmer) |
| EXC-L4-Research-SourceVerifier | Claim re-checking (inkling-small) |
| EXC-L4-Research-MemoSmith | Memo assembly (lightning) |
| EXC-L4-Research-ConfidenceScorer | Confidence scores per claim (lfm) |
| EXC-L5-Research-QA | Gates + prompt surgery |

### T2 Architecture (8) — super-120b → inkling-small → lightning — skills: project-manager
Lead `EXC-L3-Architecture-Lead` (owns Gate A); workers `ContractWriter,SchemaDesigner,ADRscribe,BoundaryMapper,ScaleReviewer,DebtKeeper` (lightning); QA `EXC-L5-Architecture-QA`. Consuming-team leads review each RFC.

### T3 Backend (15) — laguna-xs → laguna-s → lightning — skills: rust-expert,python-expert,postgres-expert,redis-expert,api-tester,code-reviewer
Lead `EXC-L3-Backend-Lead`; workers `APIBuilderA,APIBuilderB,AuthKeeper,QueueRunner,CacheSmith,MigrationMaster,JobWatcher,Validator,EndpointTesterA,EndpointTesterB,PerfSpotter,DocScribe,RollbackPlanner`; QA `EXC-L5-Backend-QA`. Split 7+6 fan_out groups (engine has no per-group cap).

### T4 Frontend (12) — lightning → ling-vl → gemma-4 — skills: react-expert,nextjs-expert,css-expert,figma-expert,api-tester
Lead `EXC-L3-Frontend-Lead`; `PageBuilder,ComponentSmith,StateKeeper,FormValidator,StyleEnforcer,A11yChecker,TestWriter,StoryAuthor,PerfTrimmer,ErrorHandler`; QA `EXC-L5-Frontend-QA` (glimmer screenshot diffs).

### T5 Mobile (10) — lightning → ling-vl → nano-3
Lead `EXC-L3-Mobile-Lead`; `ScreenBuilder,Navigator,SyncEngineer,PushHandler,PermissionClerk,StorePacker,OfflineTester,CrashGuard`; QA `EXC-L5-Mobile-QA` (gemma-4).

### T6 API & Integrations (8) — lightning → nex-mini → nano-3 — skills: oauth-expert,api-tester
Lead `EXC-L3-API-Lead`; `OAuthClerk,WebhookWatcher,RetryWrapper,SandboxTester,ContractGuard,DocScribe`; QA `EXC-L5-API-QA`.

### T7 Data Engineering (8) — flash → inkling-small → nano-3 — skills: data-pipeline,sql-analyst
Lead `EXC-L3-Data-Lead`; `PipeBuilder,QualitySentinel,BackfillRunner,SchemaGuard,FreshnessWatcher,CostTracker`; QA `EXC-L5-Data-QA`.

### T8 ML & AI (10) — flash → inkling-small → super-120b — skills: ml-engineer,vector-db
Lead `EXC-L3-ML-Lead`; `FeatureMiner,RAGIndexer,EvalRunner,PromptLibrarian,RegressionWatcher,QualityScorer,DriftDetector,DatasetCurator`; QA `EXC-L5-ML-QA`.

### T9 UI/UX Design (6) — glimmer → ling-vl → gemma-4 — skills: figma-expert
Lead `EXC-L3-Design-Lead`; `SystemDesigner,PrototypeMaker,VisualSpecWriter,FlowMapper`; QA `EXC-L5-Design-QA`.

### T10 Platform & Tooling (6) — laguna-xs → north-mini → nano-3 — skills: shell-scripting,git-expert
Lead `EXC-L3-Platform-Lead`; `LibSmith,TemplateMaker,ScaffoldRunner,DXHelper`; QA `EXC-L5-Platform-QA`.

### T11 QA Automation (12) — glimmer → ling-vl → laguna-s — skills: api-tester
Lead `EXC-L3-QA-Lead`; `E2EAuthor,APITester,LoadRunner,SmokeSentry,FlakyHunter,CoverageReporter,ReproMaker,ScreenshotJudge(gemma-4),DataSeeder,ReportPublisher`; QA `EXC-L5-QA-QA` (rotation).

### T12 Security (8) — flash → inkling-small → super-120b — skills: security-audit,crypto-expert,compliance
Lead `EXC-L3-Security-Lead`; `ScanTriager,SecretSniffer,CVEAuditor,PentestProber(+red-team duty),PolicyChecker,RunbookWriter`; QA `EXC-L5-Security-QA`. Failures never waivable.

### T13 Performance & Scale (6) — lightning → north-mini → nano-3 — skills: prometheus
Lead `EXC-L3-Perf-Lead`; `BenchRunner,P95Watcher,Profiler,SoakTester`; QA `EXC-L5-Perf-QA`. Enforces P95/P99 budgets.

### T14 Accessibility & Compliance (4) — glimmer → ling-vl → gemma-4
Lead `EXC-L3-A11y-Lead`; `A11yAuditor,PolicyChecker`; QA `EXC-L5-A11y-QA`.

### T15 DevOps/CI-CD (10) — laguna-xs → north-mini → lightning — skills: ci-cd,docker,kubernetes,terraform,ansible
Lead `EXC-L3-DevOps-Lead`; `PipeWriter,EnvParityGuard,ArtifactKeeper,RollbackSmith,IaCReviewer,LogWatcher,SecretRotator,DeployAnnouncer`; QA `EXC-L5-DevOps-QA`.

### T16 SRE & Observability (8) — lightning → nex-mini → nano-3 — skills: prometheus,sentry,sysadmin
Lead `EXC-L3-SRE-Lead`; `DashboardBuilder,AlertTuner,IncidentResponder(+chaos drills),SLOTracker,PostmortemScribe,CapacityPlanner`; QA `EXC-L5-SRE-QA`. Owns Gate E T+1h/T+24h.

### T17 Database Reliability (6) — lightning → north-mini → laguna-xs — skills: postgres-expert,sqlite-expert
Lead `EXC-L3-DB-Lead`; `BackupDriller,MigrationGuard,SlowQueryHunter,ReplicaWatcher`; QA `EXC-L5-DB-QA`.

### T18 Release (5) — lightning → or-lightning → nano-3
Lead `EXC-L3-Release-Lead` (co-owns Gate D); `VersionTagger,FlagController,NotesWriter`; QA `EXC-L5-Release-QA`.

### T19 Documentation (6) — lightning → nex-mini → nano-3 — skills: technical-writer
Lead `EXC-L3-Docs-Lead`; `APIDocWriter,RunbookScribe,DiagramMaker,FreshnessChecker`; QA `EXC-L5-Docs-QA`. Stale docs block release.

### T20 Cloud FinOps (4) — lightning → nex-mini → gpt-oss-20b
Lead `EXC-L3-FinOps-Lead`; `SpendTracker,QuotaAlarmer`; QA `EXC-L5-FinOps-QA`. Owns gate metrics dashboards + weekly model-availability re-check (with Legal TermsWatcher).

### T21 Support Triage (8) — glimmer → ling-vl → lightning
Lead `EXC-L3-Support-Lead`; `TicketClusterer,ReproMaker,SeverityLabeler,WorkaroundDrafter,EscalationClerk,KBUpdater`; QA `EXC-L5-Support-QA`.

### T22 Analytics & Growth (6) — glimmer → ling-vl → flash — skills: data-analyst
Lead `EXC-L3-Analytics-Lead`; `FunnelTracker,ExperimentRunner,MetricReporter,InsightScribe` (learnings → next Phase 0); QA `EXC-L5-Analytics-QA`.

### T23 Localization (5) — glimmer → ling-vl → gemma-4
Lead `EXC-L3-Locale-Lead`; `StringExtractor,LocaleTester,GlossaryKeeper`; QA `EXC-L5-Locale-QA`.

### T24 Orchestration & Routing (12) — lightning → or-lightning → nano-3 — skills: project-manager
Lead `EXC-L3-Orchestrator-Lead`; `TaskRouter,WaveScheduler,FallbackMonitor,CostAccountant,HealthDashboard(+circuit-breaker duty),RetryQueueKeeper,DeadletterNurse,ThroughputTuner,PromptLibrarian,GateCLiaison`; QA `EXC-L5-Orchestrator-QA`. Duties: `KeySteward` (missing-key → WebChat ask → save → restart → resume), `ProgressReporter` (cron every 30m digest to WebChat).

### T25 Legal/Privacy/Compliance (5) — gemma-4 → ling-vl → flash — skills: compliance
`EXC-L3-Legal-Lead`; `LicenseChecker` (16-model matrix), `PrivacySweeper` (PII redaction hard-gate before free endpoints), `TermsWatcher` (weekly ToS/availability); QA `EXC-L5-Legal-QA`. Gates every Gate A with new models/libs/data.

### T26 Product/Program (5) — lightning → nex-pro → nano-3 — skills: project-manager
`EXC-L3-Product-Lead`; `Prioritizer,ScopeGuard(says no),RoadmapKeeper`; QA `EXC-L5-Product-QA`. Owns Phase 0 sign-off.

**Count: 5 + 12+8+15+12+10+8+8+10+6+6+12+8+6+4+10+8+6+5+6+4+8+6+5+12+5+5 = 210 ✅**

## 5. How agents connect (all via OpenFang components only)

* **Inside a team:** Lead slices tickets → workers `fan_out` (same `{{input}}`) → `collect` joins with `---` → Lead bundle `sequential` (`output_var`) → QA `loop until APPROVED` (Prompt-Surgeon rewrites inside QA turn, ≤3) → handoff var. Prompts carry `{{input}}` + named vars only.
* **Across teams:** handoff artifacts in `projects/<name>/gates/<ticket>/`; next link triggered by workflow chain (master-sequential, 26 links) or event trigger on artifact write. No informal handoffs.
* **Up:** Lead 3-line status (done/next/blocked) to Health-Dashboard each wave; blockers >1 wave auto-escalate to Manager; Managers sample 10%; Founder signs Gate D/E packets only.
* **Approvals:** `HUMAN_REQUIRED:` → runbook step pages WebChat → `openfang approvals approve <id>` → `conditional` resumes run. Circuit-Breaker (all 3 tiers exhausted): freeze state, page human, Founder-override only to resume.
* **Waves:** 6 waves × 4 teams via cron, staggered 10 min; heavy Frontier (super/flash researchers) on night batch; per-agent caps (`max_tool_calls_per_minute`, hourly token caps, zero-cost stops).

## 6. Rules (must-follow, condensed from playbook v1+v4)

1. NVIDIA → OR-free → different-NVIDIA on every agent; Cerebras nowhere.
2. Gate literals mandatory in every Gate prompt; re-entry exactly one phase back, max 3× then Manager review.
3. Contracts frozen at Gate A; silent deviation forbidden (raise to Architecture).
4. Security findings never waivable; waivers otherwise Manager-Quality only, time-boxed, changelogged.
5. Peer conflicts → Managers jointly → Founder final; Security defaults to block under dispute.
6. SEV1–4 taxonomy; SEV1/2 mandatory blameless postmortems within 48h; learnings → next Phase 0.
7. Semver product + roster versions (`roster-v1…`) with changelog; high-risk changes need Legal+Security+Manager sign-off pre-Gate-A.
8. DoR/DoD checklist per phase (see playbook); ticket closes only after Gate E T+24h green + docs updated.
9. No raw secrets/PII to free endpoints — Privacy-Sweeper redaction is a hard gate.
10. Branch flow: work on `feature/new_models`-style branches from `beta`; no push/merge without explicit user word (per `yami/git-instruction.md`).

## 8. Start-of-work protocol ("start work on <project>")

`~/Desktop/Project-Workshop/START-WORK.sh`: daemon health → start if down → load project workflows → post ready-plan in WebChat → user approves (`openfang approvals approve`) → master run begins → Progress-Reporter digests every 30m. Key-Steward pauses waves on missing-key errors until keys are supplied.

## Appendix R — Full 210-name registry (every agent's EXC ID)

Overhead: EXC-L1-Founder, EXC-L2-MgrBuild, EXC-L2-MgrQuality, EXC-L2-MgrResearch, EXC-L2-ReleaseGate.
T1-Research: EXC-L3-Research-Lead, EXC-L4-Research-ReqMiner, EXC-L4-Research-EvidenceHunter, EXC-L4-Research-CompetitorScout, EXC-L4-Research-RiskAnalyst, EXC-L4-Research-FeasibilityProber, EXC-L4-Research-EstimateScribe, EXC-L4-Research-VisionResearcher, EXC-L4-Research-SourceVerifier, EXC-L4-Research-MemoSmith, EXC-L4-Research-ConfidenceScorer, EXC-L5-Research-QA.
T2-Architecture: EXC-L3-Architecture-Lead, EXC-L4-Architecture-ContractWriter, EXC-L4-Architecture-SchemaDesigner, EXC-L4-Architecture-ADRscribe, EXC-L4-Architecture-BoundaryMapper, EXC-L4-Architecture-ScaleReviewer, EXC-L4-Architecture-DebtKeeper, EXC-L5-Architecture-QA.
T3-Backend: EXC-L3-Backend-Lead, EXC-L4-Backend-APIBuilderA, EXC-L4-Backend-APIBuilderB, EXC-L4-Backend-AuthKeeper, EXC-L4-Backend-QueueRunner, EXC-L4-Backend-CacheSmith, EXC-L4-Backend-MigrationMaster, EXC-L4-Backend-JobWatcher, EXC-L4-Backend-Validator, EXC-L4-Backend-EndpointTesterA, EXC-L4-Backend-EndpointTesterB, EXC-L4-Backend-PerfSpotter, EXC-L4-Backend-DocScribe, EXC-L4-Backend-RollbackPlanner, EXC-L5-Backend-QA.
T4-Frontend: EXC-L3-Frontend-Lead, EXC-L4-Frontend-PageBuilder, EXC-L4-Frontend-ComponentSmith, EXC-L4-Frontend-StateKeeper, EXC-L4-Frontend-FormValidator, EXC-L4-Frontend-StyleEnforcer, EXC-L4-Frontend-A11yChecker, EXC-L4-Frontend-TestWriter, EXC-L4-Frontend-StoryAuthor, EXC-L4-Frontend-PerfTrimmer, EXC-L4-Frontend-ErrorHandler, EXC-L5-Frontend-QA.
T5-Mobile: EXC-L3-Mobile-Lead, EXC-L4-Mobile-ScreenBuilder, EXC-L4-Mobile-Navigator, EXC-L4-Mobile-SyncEngineer, EXC-L4-Mobile-PushHandler, EXC-L4-Mobile-PermissionClerk, EXC-L4-Mobile-StorePacker, EXC-L4-Mobile-OfflineTester, EXC-L4-Mobile-CrashGuard, EXC-L5-Mobile-QA.
T6-API: EXC-L3-API-Lead, EXC-L4-API-OAuthClerk, EXC-L4-API-WebhookWatcher, EXC-L4-API-RetryWrapper, EXC-L4-API-SandboxTester, EXC-L4-API-ContractGuard, EXC-L4-API-DocScribe, EXC-L5-API-QA.
T7-Data: EXC-L3-Data-Lead, EXC-L4-Data-PipeBuilder, EXC-L4-Data-QualitySentinel, EXC-L4-Data-BackfillRunner, EXC-L4-Data-SchemaGuard, EXC-L4-Data-FreshnessWatcher, EXC-L4-Data-CostTracker, EXC-L5-Data-QA.
T8-ML: EXC-L3-ML-Lead, EXC-L4-ML-FeatureMiner, EXC-L4-ML-RAGIndexer, EXC-L4-ML-EvalRunner, EXC-L4-ML-PromptLibrarian, EXC-L4-ML-RegressionWatcher, EXC-L4-ML-QualityScorer, EXC-L4-ML-DriftDetector, EXC-L4-ML-DatasetCurator, EXC-L5-ML-QA.
T9-Design: EXC-L3-Design-Lead, EXC-L4-Design-SystemDesigner, EXC-L4-Design-PrototypeMaker, EXC-L4-Design-VisualSpecWriter, EXC-L4-Design-FlowMapper, EXC-L5-Design-QA.
T10-Platform: EXC-L3-Platform-Lead, EXC-L4-Platform-LibSmith, EXC-L4-Platform-TemplateMaker, EXC-L4-Platform-ScaffoldRunner, EXC-L4-Platform-DXHelper, EXC-L5-Platform-QA.
T11-QAAuto: EXC-L3-QA-Lead, EXC-L4-QA-E2EAuthor, EXC-L4-QA-APITester, EXC-L4-QA-LoadRunner, EXC-L4-QA-SmokeSentry, EXC-L4-QA-FlakyHunter, EXC-L4-QA-CoverageReporter, EXC-L4-QA-ReproMaker, EXC-L4-QA-ScreenshotJudge, EXC-L4-QA-DataSeeder, EXC-L4-QA-ReportPublisher, EXC-L5-QA-QA.
T12-Security: EXC-L3-Security-Lead, EXC-L4-Security-ScanTriager, EXC-L4-Security-SecretSniffer, EXC-L4-Security-CVEAuditor, EXC-L4-Security-PentestProber, EXC-L4-Security-PolicyChecker, EXC-L4-Security-RunbookWriter, EXC-L5-Security-QA.
T13-Perf: EXC-L3-Perf-Lead, EXC-L4-Perf-BenchRunner, EXC-L4-Perf-P95Watcher, EXC-L4-Perf-Profiler, EXC-L4-Perf-SoakTester, EXC-L5-Perf-QA.
T14-A11y: EXC-L3-A11y-Lead, EXC-L4-A11y-A11yAuditor, EXC-L4-A11y-PolicyChecker, EXC-L5-A11y-QA.
T15-DevOps: EXC-L3-DevOps-Lead, EXC-L4-DevOps-PipeWriter, EXC-L4-DevOps-EnvParityGuard, EXC-L4-DevOps-ArtifactKeeper, EXC-L4-DevOps-RollbackSmith, EXC-L4-DevOps-IaCReviewer, EXC-L4-DevOps-LogWatcher, EXC-L4-DevOps-SecretRotator, EXC-L4-DevOps-DeployAnnouncer, EXC-L5-DevOps-QA.
T16-SRE: EXC-L3-SRE-Lead, EXC-L4-SRE-DashboardBuilder, EXC-L4-SRE-AlertTuner, EXC-L4-SRE-IncidentResponder, EXC-L4-SRE-SLOTracker, EXC-L4-SRE-PostmortemScribe, EXC-L4-SRE-CapacityPlanner, EXC-L5-SRE-QA.
T17-DB: EXC-L3-DB-Lead, EXC-L4-DB-BackupDriller, EXC-L4-DB-MigrationGuard, EXC-L4-DB-SlowQueryHunter, EXC-L4-DB-ReplicaWatcher, EXC-L5-DB-QA.
T18-Release: EXC-L3-Release-Lead, EXC-L4-Release-VersionTagger, EXC-L4-Release-FlagController, EXC-L4-Release-NotesWriter, EXC-L5-Release-QA.
T19-Docs: EXC-L3-Docs-Lead, EXC-L4-Docs-APIDocWriter, EXC-L4-Docs-RunbookScribe, EXC-L4-Docs-DiagramMaker, EXC-L4-Docs-FreshnessChecker, EXC-L5-Docs-QA.
T20-FinOps: EXC-L3-FinOps-Lead, EXC-L4-FinOps-SpendTracker, EXC-L4-FinOps-QuotaAlarmer, EXC-L5-FinOps-QA.
T21-Support: EXC-L3-Support-Lead, EXC-L4-Support-TicketClusterer, EXC-L4-Support-ReproMaker, EXC-L4-Support-SeverityLabeler, EXC-L4-Support-WorkaroundDrafter, EXC-L4-Support-EscalationClerk, EXC-L4-Support-KBUpdater, EXC-L5-Support-QA.
T22-Analytics: EXC-L3-Analytics-Lead, EXC-L4-Analytics-FunnelTracker, EXC-L4-Analytics-ExperimentRunner, EXC-L4-Analytics-MetricReporter, EXC-L4-Analytics-InsightScribe, EXC-L5-Analytics-QA.
T23-Locale: EXC-L3-Locale-Lead, EXC-L4-Locale-StringExtractor, EXC-L4-Locale-LocaleTester, EXC-L4-Locale-GlossaryKeeper, EXC-L5-Locale-QA.
T24-Orchestration: EXC-L3-Orchestrator-Lead, EXC-L4-Orchestration-TaskRouter, EXC-L4-Orchestration-WaveScheduler, EXC-L4-Orchestration-FallbackMonitor, EXC-L4-Orchestration-CostAccountant, EXC-L4-Orchestration-HealthDashboard, EXC-L4-Orchestration-RetryQueueKeeper, EXC-L4-Orchestration-DeadletterNurse, EXC-L4-Orchestration-ThroughputTuner, EXC-L4-Orchestration-PromptLibrarian, EXC-L4-Orchestration-GateCLiaison, EXC-L5-Orchestrator-QA.
T25-Legal: EXC-L3-Legal-Lead, EXC-L4-Legal-LicenseChecker, EXC-L4-Legal-PrivacySweeper, EXC-L4-Legal-TermsWatcher, EXC-L5-Legal-QA.
T26-Product: EXC-L3-Product-Lead, EXC-L4-Product-Prioritizer, EXC-L4-Product-ScopeGuard, EXC-L4-Product-RoadmapKeeper, EXC-L5-Product-QA.

## Part 8 — Cosmic hierarchy (LIVE: 18 agents, all Running, verified 56 total)

Doctrine difference (locked per Yami): **CommsRelay** sees the *whole multiverse* (not only the company) and holds **executive power** — on Yami's order it gives work or research to any agent/place. **VoiceOfYami** holds **no dispatch power** — it automatically observes/tests over time and reports exactly as decided (30m digest + on-demand).

Real-world grounding (same information carried inside every workflow step prompt): our observable universe is 13.8 billion years old; the Milky Way is a real barred spiral of 100–400 billion stars with Sol in the Orion Arm; Andromeda is the real nearest spiral neighbor 2.5 million light-years away, merging with us in ~4.5 billion years; Sol is a real G-type star 4.6 billion years old with eight planets, Earth third; Earth is 4.54 billion years old with 8 billion people.

| Level | Agent | Function + real identity | Chain |
|---|---|---|---|
| C0 | Cosmos (existing) | Supreme overseer of the 56-agent Excellence fleet | (dashboard-managed) |
| C1 | COS-CommsRelay | Multiverse sight + executive dispatch on Yami's order only | lightning → or-lightning → nano-3 |
| C1 | COS-VoiceOfYami | Auto reports, read-only (no spawn/shell); per-seat digest lines | nano-3 → lfm → gpt-oss-20b |
| C1 | COS-TheOne | Reserved, duties TBD by Yami (dormant) | lightning → or-lightning → nano-3 |
| C1 | COS-TheVoid | Reserved, duties TBD by Yami (dormant) | lightning → or-lightning → nano-3 |
| C2 | COS-MVGod-Aion / COS-MVGod-Erebus | First/second multiverse branch overseers + relays | gpt-oss-20b → lfm → nano-3 |
| C3 | COS-UniversePrime | Relay of our observable universe (13.8B years old) | gpt-oss-20b → lfm → nano-3 |
| C4 | COS-Galaxy-MilkyWay / COS-Galaxy-Andromeda | Real-galaxy relays (Milky Way home spiral; Andromeda 2.5M ly away) | gpt-oss-20b → lfm → nano-3 |
| C5 | COS-SolGuardian | Real-Sol relay (G-type star, 4.6B years, 8 planets) | gpt-oss-20b → lfm → nano-3 |
| C6 | COS-EarthGod | Real-Earth guardian (4.54B years, 8B people); routes 7 named seats | nano-3 → ling-vl → gemma-4 |
| C7 | Earth-7 council (LIVE agents, one per person) | COS-Earth-Yami (you — country/situation: you confirm) + COS-Earth-Kai (Japan, ex-game-dev rebuilding after burnout, peak through craft) + COS-Earth-Zara (Nigeria, self-taught on low resources, origin-is-no-cap) + COS-Earth-Mateo (Brazil, freelancer supporting family, freedom-through-mastery) + COS-Earth-Anya (Ukraine, displaced student, rebuild-through-skill) + COS-Earth-Finn (Germany, corporate dropout, anti-mediocrity) + COS-Earth-Joon (South Korea, night-shift worker, sheer-hours). One goal: world top-1, the peak. EarthGod routes per-seat; Voice digests per-seat. | Yami: lightning → or-lightning → nano-3; six: nano-3 → lfm → gpt-oss-20b |

Down-channel: Founder decree → CommsRelay fan-out → acknowledgements collected. Up-channel: fleet → Cosmos → VoiceOfYami → WebChat digest to Yami. TheOne/TheVoid wire in when Yami defines duties. No Cerebras anywhere; no new Rust code — all 11 are `agent.toml` registrations (kernel auto-spawn).

## Part 9 — Pipeline hardening: map, gates, trust, never-do (added 2026-09-12, verified live)

> Why this part exists: the PinNotes-v2 probe proved the fleet works but exposed exactly where it breaks.
> Every rule below traces to a live incident. Nothing here is theory.

### §A. Pipeline map — how work actually flows (measured)

```
Order (chat VoiceOfYami / workflow run / cron)
  → Founder (L1) splits into SLICES (see §B, slice-budget gate)
  → L2 managers assign → L3 leads own → L4 workers execute → L5 QA verdicts
  → gate literals bubble up (APPROVED / FAIL: / HUMAN_REQUIRED:)
  → VoiceOfYami bottom-up report → digest to Yami
```

Measured hop budgets (do not design against faster numbers):
| Hop | Budget | Evidence |
|---|---|---|
| Front-door turn (HTTP `/message`, cron `agent_turn`) | **120s hard cap** | `TOOL_TIMEOUT_SECS=120` (`agent_loop.rs:47`); cron run `timed out after 120s` |
| `agent_send` chain (one delegation hop, full downstream loop) | **600s** | `AGENT_TOOL_TIMEOUT_SECS=600` (`agent_loop.rs:54`) |
| Simple ping turn (glimmer/laguna, warm) | 5–30s | measured: Voice 9s, Backend-Lead 13s, Design-Lead 30s, Founder 7s |
| Cold / big-context turn | 120s+ (times out) | Founder delegate turn died at cap twice |

Consequence (locked): **no single turn may carry more than ~100s of work.** Everything bigger is sliced.

### §B. Gate catalog — where checks sit

| # | Gate | Fires when | Owner | Evidence lands in |
|---|---|---|---|---|
| G0 Entry | Mission shape wrong (no location, no acceptance, no stack) | Founder | Rejected back to sender, no dispatch |
| G1 Slice-budget | Any slice estimated >100s or >6 tool calls | L2-Router (§D) | Slice split plan in ticket |
| G2 State-to-disk | Slice ends without writing progress file | Worker | `FAIL:` back, slice re-queued once |
| G3 Approval tier | Tool risk High/Critical (shell, file_write/delete) | Kernel policy + Yami dashboard | `/api/approvals` card; 300s timeout → auto-deny (fail-safe) |
| G4 Evidence | `APPROVED` without linked diff/test/log/screenshot | L5-Evidence-Auditor (§C) | `FAIL:` back to sender, no bubble-up |
| G5 Digest-freshness | Reporter counts vs live registry differ >5% | Reporter cron + auditor | `HUMAN_REQUIRED` + auto-recount |
| G6 QA verdict | UI/latency/acceptance unmet | Team L5 QA | `FAIL:` + diagnosis, ≤3 prompt-surgery retries |
| G7 Escalation | 3rd retry fails, security FAIL, missing secret | Healer → Yami | `HUMAN_REQUIRED` with full trail |
| G8 Promote | `beta→yami` without build+clippy+test green | git-instruction §C | Merge blocked, human decides |

Approval tiers (live config `~/.openfang/config.toml [approval]`): auto = chat/reads/web_fetch/browser
(Low/Medium); dashboard = `shell_exec`, `file_write`, `file_delete` (High/Critical). Agents: batch shell
into few commands, never request approval for auto-tier, one click per card context.

### §C. Trust batch (build FIRST — ordered by Yami)

1. **L5-Evidence-Auditor** (new agent, per-team QA attach): rule — any `APPROVED` lacking evidence
   (diff, test output, log line, screenshot path) is rewritten to `FAIL: no evidence` and returned.
   No evidence ever bubbles up.
2. **Digest-freshness gate** (reporter cron + check): before each digest, compare reported
   Running count vs `GET /api/agents` length; mismatch >5% → auto-recount once, still stale →
   `HUMAN_REQUIRED` (known incident: digest said 49 with 272 live).
3. **Ops-Janitor** (new agent + 15-min cron): watches `/tmp` pressure (>80% → clear stale ownerless
   dumps, never touch open fds), disk, daemon liveness (`/api/health`); pages Yami BEFORE builds
   break. (Known incident: 326 × 13.7MB Electron dumps filled `/tmp` twice in one day.)
4. **Model-Paramedic rule** (all agents, codified): on LLM 400-class driver errors
   (`reasoning_content` duplication and kin) → switch to next fallback model immediately, log
   incident line to workspace, continue. Never retry the same model twice in one turn.
   (Known incident: 42 glimmer agents tool-dead until `openai.rs` NVIDIA single-field fix.)

### §D. Throughput batch (build SECOND)

1. **L2-Router dispatcher** (new agent): owns slicing only. Input: mission. Output: slices ≤100s each
   with state-file paths, dispatched detached (one-shot cron jobs), never holding the 120s front door.
   Founder approves slice plans; Router executes fan-out; leads never wait on Founder's turn.
2. **State-to-disk gate** (protocol): every slice declares `STATE_FILE` first; every completion appends
   one line (done/fail + evidence path). Poll state files, never turns. (`~/.cache/audit/`, never `/tmp`.)
3. **Approval-batching rule**: workers group shell/file ops per slice into ≤2 approval cards; cards carry
   full command text so one Yami click decides.
4. **Front-door workaround note** (upstream): deep `agent_send` chains always outrun the 120s HTTP/cron
   cap — that is a platform limit, not an agent failure. Route around via Router + detached jobs until
   upstream raises the cap or streams progress.

### §E. Never-do list (unified — inspector + agents, violations escalate to Yami)

Inspector (the checker role):
1. NEVER write project code, run user workloads, or hold user ports — verify only (`curl`, GETs, logs).
2. NEVER broad `pkill` — daemon lifecycle via `systemd-run --user` unit + `systemctl --user` only.
3. NEVER stage work in `/tmp` (fills + wipes) — `~/.cache/audit/`; NEVER `~` inside tool args — absolute paths.
4. NEVER force turns past platform caps — slice ≤100s, poll state, respect 120s/600s budgets.
5. Audit is read-only on git (`ls-files`, `ls-tree`, `log`); no checkout/add/commit during checks.
6. NEVER approve on Yami's behalf — dashboard approvals are the human's explicit gate.

Agents (all 210 + cosmic):
7. Gate literals mandatory on every completion; `APPROVED` without evidence is a violation (G4).
8. Never wait silently — if blocked >3 min, emit `HUMAN_REQUIRED` with trail; never spin.
9. Never request approval for auto-tier tools; batch High/Critical with full context.
10. Never hold the front door — delegate via detached slices; Router owns fan-out.
11. exc-evolve logging on every task (private + shared tracks); repeat-questions-to-Yami count must stay zero.
12. Secrets never in logs, lessons, commits, or chat — key names only.

Last verified: 2026-09-12. Daemon `0.6.9` via `openfang-daemon` user unit, 272 agents, policy hot-applied.
