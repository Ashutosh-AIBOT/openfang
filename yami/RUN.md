# RUN — Copy-Paste Commands (Verified Working)

> Verified: 2026-09-10 on `beta` @ `acf2587`.
> Build: `cargo build --workspace --lib` — SUCCESS in 6m42s.
> Daemon: health `{"status":"ok","version":"0.6.9"}`, home `200`.
> No env setup needed — `~/.openfang/` + keys already exist.

## Website (open after `start`)

```
http://127.0.0.1:4200/
```

- API health: `http://127.0.0.1:4200/api/health`
- WebChat UI: `http://127.0.0.1:4200/`

## 1. Fastest Run (installed binary, no build)

```bash
openfang start
```

## 2. Dev Run From Source (recommended on beta)

```bash
cargo run -p openfang-cli -- start
```

## 3. Build Once, Run Many Times

```bash
cargo build -p openfang-cli
./target/debug/openfang start
```

## 4. Verify It Is Running (new terminal)

```bash
curl -s http://127.0.0.1:4200/api/health
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:4200/
openfang status
openfang doctor
```

## 5. Stop

```bash
# in daemon terminal: Ctrl+C
# or from anywhere:
curl -X POST http://127.0.0.1:4200/api/shutdown
```

## 6. Full Health Check (after code changes)

```bash
cargo build --workspace --lib
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
```

## 7. If You Add a New LLM Key

```bash
openfang config set-key GROQ_API_KEY gsk_xxx
# restart daemon after this
```

---
Branch: created `feature/run-setup` from `beta` after successful run. Merge to `beta` when ready:
`git checkout beta && git merge feature/run-setup && git push origin beta`
