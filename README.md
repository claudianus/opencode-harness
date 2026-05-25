# OpenCode Harness — Reproducible Agent Ecosystem

One-command setup that recreates a production-grade OpenCode environment on any machine.

```bash
chmod +x install.sh && ./install.sh
```

## What You Get

| Component | Count | Details |
|-----------|-------|---------|
| **Inline Agents** | 15 | Plan, Build, Reviewer (primaries) + 12 workflow subagents |
| **Agency Domain Specialists** | 184 | Tier 2 specialists from [agency-agents](https://github.com/msitarzewski/agency-agents) |
| **MCP Servers** | 7 | lean-ctx, codegraph, maru-deep-pro-search, agentmemory, chrome-devtools, playwright, open-design |
| **NPM Plugins** | 7 | vibeguard, notify, smart-title, handoff, synced, mystatus, DCP |
| **Context Pruning** | DCP | 250k soft limit, dedup + error purge, soft nudge force |
| **Agent Prompts** | 2 | build.md (orchestration) + plan.md (coordination) |
| **Quality Pipeline** | 4-phase | Runtime smoke → Validation → Polish → Merge gate |

## Architectures

### Agent Hierarchy

```
Tier 1 — Workflow Agents (15, inline config)
  Primaries: Plan (coordination), Build (implementation), Reviewer (quality)
  Subagents: scout, research, debug, tester, refactor, devops, security,
             docs, migrate, perf, api, data

Tier 2 — Domain Specialists (184, auto-discovered from ~/.config/opencode/agents/)
  Engineering (30), Testing (8), Design (5), Strategy (3), Specialized (3)
```

### MCP Tool Graph

```
agentmemory ─── memory persistence, session recall
lean-ctx ────── cached context compression (reads ~13 tok when unchanged)
codegraph ───── AST knowledge graph (sub-ms structural queries)
maru-deep-pro-search ── multi-engine research pipeline
chrome-devtools + playwright ── browser automation
open-design ─── design system integration
```

### Quality Pipeline

```
Phase 0 — Runtime Smoke      [integration/processing code — NOT OPTIONAL]
Phase 1 — Validation          [reviewer + security + tester, parallel]
Phase 2 — Polish              [docs + perf, after Phase 1 passes]
Gate   — No merge without Phase 1 passing
```

## Prerequisites

- **Node.js** >= 22
- **OpenCode CLI** (`npm install -g opencode@latest`)
- **git** (for agency-agents clone)

## What Gets Installed

```
~/.config/opencode/
├── opencode.json          # Agent config + MCP servers + permissions
├── dcp.jsonc              # Context pruning (250k soft limit)
├── AGENTS.md               # Global agent routing + quality rules
├── .opencode/prompts/
│   ├── build.md            # Build agent orchestration prompt
│   └── plan.md             # Plan agent coordination prompt
├── plugins/
│   └── lean-ctx.ts         # Local lean-ctx integration
└── agents/
    └── *.md                # 184 agency domain specialists

~/.local/share/agency-agents/   # Cloned agency-agents repo
~/.local/bin/*-mcp-safe         # Singleton-safe MCP wrappers
```

## Post-Install

```bash
# 1. API keys
opencode providers login

# 2. Restart OpenCode (quit + reopen TUI)

# 3. Verify
opencode agent list                    # → 15+ agents
ls ~/.config/opencode/agents/*.md | wc -l  # → 184

# 4. CodeGraph (per project)
codegraph init -i

# 5. Verify DCP pruning
cat ~/.config/opencode/dcp.jsonc | grep maxContextLimit
```

## Configuration Highlights

### Context Pruning (DCP)
- **250k max** — soft nudges above this threshold
- **100k min** — no nudges in normal zone  
- **Soft nudge force** — agent decides what to prune, not forced
- **Dedup** + **error purge** (after 3 turns)

### Permissions
- **Allow-all** by default — zero interruption workflow
- **Dangerous command deny list** — `rm -rf`, `dd`, `mkfs`, `diskutil erase`, `shutdown`, `reboot`
- **`doom_loop` stays `ask`** — safety net for infinite loops

### Model
- **Default**: `deepseek/deepseek-v4-pro` (1M context window)
- Change in one place: edit `model` field in `opencode.json`

## Optional Components

| Component | How to Remove |
|-----------|--------------|
| Agency agents | Delete `~/.config/opencode/agents/` directory |
| DCP context pruning | `opencode plugin -g @tarquinen/opencode-dcp@latest --remove` + delete `dcp.jsonc` |
| maru-deep-pro-search | Remove from `mcp` block in `opencode.json` |
| Specific subagent | Remove from `agent` block in `opencode.json` |

## Repo Structure

```
opencode-harness/
├── install.sh                     # Idempotent installer
├── opencode.json                  # Config template ({{HOME}} placeholders)
├── dcp.jsonc                      # Context pruning config
├── AGENTS.md                      # Agent routing + quality pipeline
├── README.md
├── prompts/
│   ├── build.md                   # Build agent prompt
│   └── plan.md                    # Plan agent prompt
├── plugins/
│   └── lean-ctx.ts                # Local lean-ctx plugin
└── scripts/
    └── create-mcp-wrappers.sh     # Singleton-safe MCP wrapper generator
```

## Vanilla OpenCode → This Harness

| Aspect | Vanilla | This Harness |
|--------|---------|-------------|
| Agents | 7 built-in | 15 custom + 184 agency |
| MCP servers | 0 | 7 configured |
| Plugins | 0 | 7 npm + 1 local |
| LSP | Off (default) | On |
| Auto-update | Off | On |
| Permissions | Ask-everything | Allow-all + deny list |
| Context pruning | None | DCP 250k soft |
| Agent prompts | None | build.md + plan.md |
| Quality pipeline | None | 4-phase mandatory gate |
| Model | Unset | deepseek/deepseek-v4-pro |
| AGENTS.md | Absent | Full routing + delegation rules |
