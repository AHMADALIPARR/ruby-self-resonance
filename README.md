# Ruby Self-Resonance Stack

[![License: NON-AI MPL 2.0](https://img.shields.io/badge/License-NON--AI%20MPL%202.0-blue.svg)](LICENSE)
[![Ruby](https://img.shields.io/badge/Ruby-3.2-red.svg)](https://www.ruby-lang.org/)
[![Sinatra](https://img.shields.io/badge/Frontend-Sinatra%204-black.svg)](frontend/app.rb)
[![NASM](https://img.shields.io/badge/ASM-x86--64%20NASM-orange.svg)](ethical_guardrails.asm)

**TheVoidIntent Systems — a coherence-based permission layer in Ruby, with a live web dashboard.**

Instead of RBAC or OAuth, actions are permitted or denied by *thermodynamic alignment checks*: an intent core measures action coherence against a seeded intent vector, a resonance engine folds information into crystallization density, and a deterministic policy draws the final boundary. Two x86-64 NASM modules implement the ethical guardrails and network containment in fixed-point integer arithmetic — no floating point.

## The verbatim contract

Every file at the repo root is the author's code **exactly as supplied** — nothing rewritten, nothing "fixed," nothing redesigned. The only additions are SPDX license headers and this README/front end. Where the supplied code has observable behavior worth knowing (see Honesty notes), it is documented, not altered.

## Layout

| File | What it is |
|---|---|
| `ruby_self_resonance.rb` | The complete stack: `MathKernel`, `ActionVector`, `Decision`, `FieldDiary` (append-only), `IntentSimCore`, `MezquiaResonanceEngine`, `CoherencePolicy`, `PermissionRuntime` — plus the author's example run |
| `field_diary.rb` | `FieldDiary` (emotional-state creases), `HRRCalculator` (HRR = (ΔEntropy/ΔTime) × 1/13), `IntegratedIntentSimEngine` |
| `initialization_matrix.rb` | `ProgressiveInitializationMatrix` — the 44-stage boot sequence |
| `codex_absorber.rb` | `CodexAbsorber` — YAML intent-manifest ingestion → TypeScript/Python codegen |
| `git_locksmith.rb` | `GitImmutabilityLocksmith` — SHA-256 file scan + sovereign-anchor check |
| `resonance_repl.rb` | Interactive REPL (`init`, `fold`, `fold!`, `action`, `status`, `diary`, …) |
| `ethical_guardrails.asm` | x86-64 NASM ethical alignment monitor (fixed-point; EVT-001/002/003 demo) |
| `network_containment.asm` | x86-64 NASM containment module (WARNING → CONTAINMENT → TRUTHLOCK, exits 13) |
| `intent_manifest.yaml` | `void_nexus_override_01` sovereign alignment manifest |
| `Dockerfile`, `docker-compose.yml` | Multi-stage Ruby/Node build + isolated network service |
| `ARCHITECTURE.txt` | The module tree, as supplied |
| `frontend/` | **New:** Sinatra 4 dashboard wiring `PermissionRuntime` to the web |

## The front end

`frontend/` is new work, built for this repo: a Sinatra dashboard over the verbatim `RubySelfResonance::PermissionRuntime`.

- **Dashboard** (`GET /`) — live coherence score, emotional state, crystallization density vs the Σ = 44.0 threshold, sovereignty flag, diary event count, and the active policy bounds.
- **Authorize action** (`POST /authorize`) — submit name, vector, entropy cost, purpose, risk; the runtime returns a `Decision` (permitted/denied with coherence, entropy Δ, risk, reason).
- **Fold information** (`POST /fold`) — grow crystallization density by (purpose / entropy) × 1/13 per fold; below Σ the engine raises its designed `DissonanceOverride`, shown as a status, not an error.
- **Field diary** (`GET /diary`) — the full append-only event log.
- **Reset** (`POST /reset`) — reinitialize the runtime with the default intent.

Hand-authored CSS, no frameworks.

```bash
cd frontend
bundle install        # or: gem install sinatra rackup puma
rackup -p 4567        # → http://localhost:4567
```

Default intent is `[1.0, 0.8, 0.6, 0.9]` (4-dimensional, matching the module's example); action vectors must match its dimensionality.

## Verification record (measured 2026-10-02)

All six Ruby files pass `ruby -c`. The dashboard was booted and every route exercised:

- `GET /` → 200, dashboard renders live state
- `POST /authorize` with the example action → **PERMITTED** (`coherence_threshold_satisfied`)
- `POST /authorize` with a hostile vector (entropy 5.0, purpose 0.01, risk 0.99) → **DENIED**
- `POST /fold` ×3 → density accumulates; below Σ the designed dissonance status displays
- `GET /diary` → 200, events listed
- `POST /reset` → 303, runtime reinitialized, diary clean

Both NASM modules assemble clean (`nasm -f elf64`, `ld`) and run as their headers describe:

- `ethical_guardrails`: EVT-001 and EVT-002 clear the guardrails (under sovereign-override warning); EVT-003 (drift 1.32 > 1.13 max) is rejected → `[HALT]`, exit 1
- `network_containment`: WARNING → CONTAINMENT → TRUTHLOCK, exits 13

`CodexAbsorber` ingests `intent_manifest.yaml` (`void_nexus_override_01`); `GitImmutabilityLocksmith` scans and matches its sovereign anchor; `FieldDiary#record_crease` records and filters correctly.

## Honesty notes

- `ruby_self_resonance.rb` calls `Time#iso8601`, which lives in Ruby's `time` stdlib and is not loaded by default — running the file standalone raises `NoMethodError`. The front end requires `time` in *its own* file (`frontend/app.rb`); the supplied file is untouched.
- `IntegratedIntentSimEngine#process_agent_tick` references `RESONANCE_CONSTANT`, which is defined on `HRRCalculator`, not on the engine — calling it raises `NameError`. Preserved verbatim, as supplied.
- `GitImmutabilityLocksmith#fetch_latest_commit_hash` returns a hardcoded hash (its own comments say it is mocking the git layer); the SHA-256 file scan itself is real.
- The `Dockerfile` references `package.json`, `ethical_guardrails.ts`, `runtime_pipeline.ts`, and `network_alert.ts`, which were not part of the supplied material — preserved as written.

## License

NON-AI Mozilla Public License 2.0 — see [LICENSE](LICENSE). Section 3.6 prohibits using this software to train or improve machine-learning systems. No commercial license is offered; there is no dual licensing.
