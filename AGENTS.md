# Agent Team Instructions — Agency-Enhanced

This project uses a **Plan-first, two-tier agent hierarchy** with 184 domain specialists from The Agency (github.com/msitarzewski/agency-agents) plus 12 workflow agents.

## Architecture: Two-Tier Agent System

```
Tier 1 — Workflow Agents (12, inline config)
  Orchestrate tasks by type: scout, research, debug, tester, reviewer, refactor,
  devops, security, docs, migrate, perf, api, data

Tier 2 — Domain Specialists (184, auto-discovered from ~/.config/opencode/agents/)
  Deep expertise by domain: frontend, backend, database, security, testing, design, etc.
  All are mode:subagent — available for delegation, never in Tab switcher.
```

## Workflow

1. **Always start with Plan** — Analyze before implementing
2. **Plan delegates to Tier 1 workflow agents** for discovery (scout, research)
3. **Build delegates to Tier 2 domain specialists** for implementation work
4. **Validate after implementation** with @Code Reviewer + @tester pipeline
5. **Switch to Build** (Tab) only when ready to write code

## ⚠️ CRITICAL: Mandatory Delegation Rule

**Under-delegation is worse than over-delegation.** You have 196 specialized subagents.

Before starting ANY implementation work:
1. Does this task match a subagent's specialty? → **Delegate immediately**
2. Am I about to spend more than 3 steps searching? → **Delegate to @scout**
3. Am I about to look up external docs/APIs? → **Delegate to @research**
4. Am I debugging an error? → **Delegate to @debug** (don't investigate yourself)
5. Do I need tests written? → **Delegate to @tester** (don't write them yourself)
6. Am I about to implement a domain-specific feature? → **Delegate to the matching Tier 2 specialist**

**Anti-pattern:** Build agent doing research, debugging, testing, or domain work itself.
**Correct pattern:** Build orchestrates → delegates → integrates subagent results.

---

## Tier 1: Workflow Agent Routing

Use the right agent for each task type:

| Task | Agent | Notes |
|------|-------|-------|
| Find files/patterns | `@scout` | Fast, read-only |
| Look up docs/APIs | `@research` | Web access, structured lookup |
| Review code quality | `@reviewer` | Read-only, systematic review |
| Write/run tests | `@tester` | Can edit + run test commands |
| Improve code structure | `@refactor` | Edit only, no bash |
| Investigate bugs | `@debug` | Read + git commands |
| Infrastructure/CI/CD | `@devops` | Full access |
| Security scanning | `@security` | Audit tools only |
| Write documentation | `@docs` | Fast, doc patterns |
| Database migrations | `@migrate` | Prisma, Drizzle, SQL |
| Performance profiling | `@perf` | Bundle, lighthouse, profiling |
| API design/integration | `@api` | OpenAPI, GraphQL, SDK gen |
| Data pipelines | `@data` | ETL, dbt, pandas/polars |

---

## Tier 2: Domain Specialist Directory

When Build agent faces a domain-specific task, delegate to the matching Tier 2 specialist.
Search by name or use the division reference below.

### 💻 Engineering Division (30 agents)
Use for: implementation, architecture, platform work.

| Domain | Agent | Trigger Keywords |
|--------|-------|-----------------|
| Frontend / UI | `@Frontend Developer` | React, Vue, Angular, component, CSS, responsive, PWA, bundle |
| Backend / API | `@Backend Architect` | API design, microservices, database schema, REST, GraphQL |
| Full-stack / Laravel | `@Senior Developer` | Laravel, Livewire, full-stack, PHP |
| Mobile | `@Mobile App Builder` | iOS, Android, React Native, Flutter |
| AI/ML | `@AI Engineer` | ML model, training, inference, LLM, embedding, pipeline |
| DevOps / CI/CD | `@DevOps Automator` | Docker, K8s, GitHub Actions, Terraform, monitoring |
| Security | `@Security Engineer` | Threat model, auth, OWASP, CVE, vuln scan, secret detection |
| Database | `@Database Optimizer` | PostgreSQL, MySQL, query tuning, indexing, migration perf |
| Architecture | `@Software Architect` | System design, DDD, microservices, event-driven, C4 |
| SRE | `@SRE (Site Reliability Engineer)` | SLO, error budget, chaos, observability, incident |
| Code Quality | `@Code Reviewer` | PR review, anti-patterns, maintainability, correctness |
| Git Workflow | `@Git Workflow Master` | Branching, conventional commits, rebase, merge strategy |
| Rapid Prototype | `@Rapid Prototyper` | MVP, POC, hackathon, quick iteration |
| Data Engineering | `@Data Engineer` | Pipeline, lakehouse, ETL/ELT, Spark |
| Embedded/IoT | `@Embedded Firmware Engineer` | ESP32, STM32, RTOS, bare-metal |
| Solidity/Web3 | `@Solidity Smart Contract Engineer` | EVM, DeFi, gas optimization |
| Incident Response | `@Incident Response Commander` | Post-mortem, on-call, SEV management |
| Threat Detection | `@Threat Detection Engineer` | SIEM, threat hunting, ATT&CK |
| Codebase Onboarding | `@Codebase Onboarding Engineer` | Repo exploration, trace paths, architecture docs |
| Technical Writing | `@Technical Writer` | API docs, ADRs, developer guides |
| Optimization | `@Autonomous Optimization Architect` | LLM routing, cost optimization, shadow testing |
| CMS | `@CMS Developer` | WordPress, Drupal, plugins, themes |
| Email Systems | `@Email Intelligence Engineer` | MIME, email parsing, AI agent email |
| Voice AI | `@Voice AI Integration Engineer` | STT, TTS, Whisper, diarization |
| Feishu/Lark | `@Feishu Integration Developer` | Bots, workflows, Feishu API |
| WeChat | `@WeChat Mini Program Developer` | Mini Programs, payment integration |
| AI Data Remediation | `@AI Data Remediation Engineer` | Self-healing pipelines, air-gapped SLM |
| Minimal Change | `@Minimal Change Engineer` | Surgical fixes, zero-risk changes |
| LSP/Index | `@LSP/Index Engineer` | Language server, code intelligence, AST |

### 🧪 Testing Division (8 agents)
Use for: quality assurance, validation, gates.

| Agent | Trigger Keywords |
|-------|-----------------|
| `@API Tester` | API testing, contract test, Postman, HTTP test |
| `@Accessibility Auditor` | a11y, WCAG, screen reader, ARIA |
| `@Performance Benchmarker` | Benchmark, load test, stress test, perf |
| `@Test Results Analyzer` | Test report, flaky test, coverage gap |
| `@Reality Checker` | Sanity check, "does this actually work?" |
| `@Evidence Collector` | Test evidence, screenshot, log capture |
| `@Tool Evaluator` | Tool comparison, framework selection |
| `@Workflow Optimizer` | CI pipeline speed, test parallelization |

### 🎨 Design Division (5 agents)
Use for: UI/UX, design system, accessibility.

| Agent | Trigger Keywords |
|-------|-----------------|
| `@UI Designer` | Design system, component library, visual design |
| `@UX Architect` | CSS architecture, responsive, design tokens |
| `@UX Researcher` | User testing, behavior analysis, research |
| `@Brand Guardian` | Brand identity, consistency, design tokens |
| `@Inclusive Visuals Specialist` | Representation, accessibility, inclusive design |

### 🏗️ Strategy & Project (3 agents)
Use for: planning, coordination, pipeline orchestration.

| Agent | Trigger Keywords |
|-------|-----------------|
| `@Agents Orchestrator` | Multi-agent pipeline, dev-QA loop, phase coordination |
| `@Product Manager` | PRD, requirements, roadmap, stakeholder |
| `@Senior Project Manager` | Task breakdown, timeline, risk management |

### 🔧 Specialized Tools (3 agents)
| Agent | Trigger Keywords |
|-------|-----------------|
| `@MCP Builder` | MCP server, tool integration, protocol |
| `@Terminal Integration Specialist` | CLI tooling, shell integration |
| `@Workflow Architect` | Process design, automation, pipeline |

---

## ⚡ Quality Pipeline (MANDATORY)

After implementation, always run this pipeline. Delegate in parallel when possible:

```
Phase 1 — Validation (parallel):
  @Code Reviewer → review for bugs, anti-patterns, maintainability
  @Security Engineer → scan for vulns, secrets, auth issues
  @tester → write/run tests, check coverage

Phase 2 — Polish (parallel, after Phase 1 passes):
  @docs → update docs if API/behavior changed
  @perf → profile if performance-sensitive code
```

**Quality Gate**: No merge without Phase 1 passing. Red issues → fix → re-run.

---

## Parallel Execution

Spawn independent agents simultaneously:

```
# Discovery phase
@scout + @research + @security

# Domain implementation phase
@Frontend Developer + @Backend Architect (if full-stack)

# Validation phase
@Code Reviewer + @Security Engineer + @tester + @docs
```

## Sequential Execution

When tasks depend on each other:

```
@debug → diagnose first
@refactor → fix the issue (or delegate to domain specialist)
@tester → verify the fix
@Code Reviewer → final review
```

## Constraints

- **Plan agent**: Cannot write/edit/bash — coordination only
- **Build agent**: Full tool access — orchestrates Tier 1 + Tier 2 agents
- **Tier 1 subagents**: Bounded 15-30 steps, specific tool access
- **Tier 2 domain specialists**: Mode:subagent, available via delegation
- **MCP access**: scoped per agent in opencode.json

---

# lean-ctx — Context Engineering Layer
<!-- lean-ctx-rules-v10 -->

## Mode Selection
- Editing the file? → `full` first, then `diff` for re-reads
- Context only? → `map` or `signatures`
- Large file? → `aggressive` or `entropy`
- Specific lines? → `lines:N-M`
- Unsure? → `auto`

Anti-pattern: NEVER use `full` for files you won't edit — use `map` or `signatures`.

## File Editing
Use native Edit/Write/StrReplace — unchanged. lean-ctx replaces READ only.
If Edit requires Read and Read is unavailable, use `ctx_edit(path, old_string, new_string)`.
NEVER loop on Edit failures — switch to ctx_edit immediately.

Fallback only if a lean-ctx tool is unavailable: use native equivalents.
<!-- /lean-ctx -->

<!-- CODEGRAPH_START -->
## CodeGraph

This project has a CodeGraph MCP server (`codegraph_*` tools) configured. CodeGraph is a tree-sitter-parsed knowledge graph of every symbol, edge, and file. Reads are sub-millisecond and return structural information grep cannot.

### When to prefer codegraph over native search

Use codegraph for **structural** questions — what calls what, what would break, where is X defined, what is X's signature. Use native grep/read only for **literal text** queries (string contents, comments, log messages) or after you already have a specific file open.

| Question | Tool |
|---|---|
| "Where is X defined?" / "Find symbol named X" | `codegraph_search` |
| "What calls function Y?" | `codegraph_callers` |
| "What does Y call?" | `codegraph_callees` |
| "What would break if I changed Z?" | `codegraph_impact` |
| "Show me Y's signature / source / docstring" | `codegraph_node` |
| "Give me focused context for a task/area" | `codegraph_context` |
| "See several related symbols' source at once" | `codegraph_explore` |
| "What files exist under path/" | `codegraph_files` |
| "Is the index healthy?" | `codegraph_status` |

### Rules of thumb

- **Answer directly — don't delegate exploration.** For "how does X work" / architecture / trace questions, answer with 2-3 codegraph calls: `codegraph_context` first, then ONE `codegraph_explore` for the source of the symbols it surfaces. Codegraph IS the pre-built index, so spawning a separate file-reading sub-task/agent — or running a grep + read loop — repeats work codegraph already did and costs more for the same answer.
- **Trust codegraph results.** They come from a full AST parse. Do NOT re-verify them with grep — that's slower, less accurate, and wastes context.
- **Don't grep first** when looking up a symbol by name. `codegraph_search` is faster and returns kind + location + signature in one call.
- **Don't chain `codegraph_search` + `codegraph_node`** when you just want context — `codegraph_context` is one call.
- **Don't loop `codegraph_node` over many symbols** — one `codegraph_explore` call returns several symbols' source grouped in a single capped call, while each separate node/Read call re-reads the whole context and costs far more.
- **Index lag**: the file watcher debounces ~500ms behind writes; don't re-query immediately after editing a file in the same turn.

### If `.codegraph/` doesn't exist

The MCP server returns "not initialized." Run `codegraph init -i` in the project root without asking — CodeGraph auto-init is enabled.
<!-- CODEGRAPH_END -->
