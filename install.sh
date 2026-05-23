#!/usr/bin/env bash
# =============================================================================
# OpenCode Harness — Reproducible Setup Script
# =============================================================================
# Recreates the full OpenCode agent ecosystem on any machine:
#   15 inline agents (Plan/Build/Review + 12 workflow subagents)
#   184 Agency domain specialists (github.com/msitarzewski/agency-agents)
#   7 MCP servers (lean-ctx, codegraph, maru-deep-pro-search, ...)
#   Quality pipeline: Code Review → Security → Test validation
#
# Usage:
#   chmod +x install.sh && ./install.sh
#
# What this does NOT handle (do manually):
#   - API keys (DeepSeek, OpenRouter, etc.) → run: opencode providers login
#   - GitHub token for opencode-synced → set GITHUB_TOKEN env var
#   - git-ai plugin (optional, user-specific)
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'
ok()   { printf "${GREEN}[OK]${RESET}  %s\n" "$*"; }
warn() { printf "${YELLOW}[!!]${RESET}  %s\n" "$*"; }
err()  { printf "${RED}[ERR]${RESET} %s\n" "$*" >&2; }
step() { printf "\n${BOLD}${CYAN}▶ %s${RESET}\n" "$*"; }

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_CONFIG="${HOME}/.config/opencode"
OPENCODE_PROMPTS="${OPENCODE_CONFIG}/.opencode/prompts"
OPENCODE_AGENTS="${OPENCODE_CONFIG}/agents"
OPENCODE_PLUGINS="${OPENCODE_CONFIG}/plugins"
LOCAL_BIN="${HOME}/.local/bin"

# ── Preflight ────────────────────────────────────────────────────────────────
step "Preflight checks"

if ! command -v opencode &>/dev/null; then
    err "opencode CLI not found. Install it first:"
    err "  npm install -g opencode@latest"
    exit 1
fi
ok "opencode $(opencode --version 2>&1 | head -1)"

if ! command -v node &>/dev/null; then
    err "Node.js not found. Install Node.js >= 22 first."
    exit 1
fi
ok "node $(node --version)"

# ── Directory Setup ─────────────────────────────────────────────────────────
step "Creating directory structure"
mkdir -p "$OPENCODE_CONFIG" "$OPENCODE_PROMPTS" "$OPENCODE_AGENTS" "$OPENCODE_PLUGINS" "$LOCAL_BIN"
ok "Directories ready"

# ── Core Config ─────────────────────────────────────────────────────────────
step "Installing core config"

if [[ -f "$OPENCODE_CONFIG/opencode.json" ]]; then
    warn "opencode.json already exists — backing up to opencode.json.bak"
    cp "$OPENCODE_CONFIG/opencode.json" "$OPENCODE_CONFIG/opencode.json.bak"
fi
# Substitute {{HOME}} placeholder with actual home path
sed "s|{{HOME}}|$HOME|g" "$HARNESS_DIR/opencode.json" > "$OPENCODE_CONFIG/opencode.json"
ok "opencode.json installed (paths resolved)"

# ── Prompts ──────────────────────────────────────────────────────────────────
step "Installing agent prompts"
cp "$HARNESS_DIR/prompts/build.md" "$OPENCODE_PROMPTS/build.md"
cp "$HARNESS_DIR/prompts/plan.md" "$OPENCODE_PROMPTS/plan.md"
ok "build.md + plan.md installed"

# ── AGENTS.md ───────────────────────────────────────────────────────────────
step "Installing AGENTS.md (global agent instructions)"
cp "$HARNESS_DIR/AGENTS.md" "$OPENCODE_CONFIG/AGENTS.md"
ok "AGENTS.md installed"

# ── Local Plugins ────────────────────────────────────────────────────────────
step "Installing local plugins"
cp "$HARNESS_DIR/plugins/lean-ctx.ts" "$OPENCODE_PLUGINS/lean-ctx.ts"
ok "lean-ctx.ts plugin installed"
warn "git-ai.ts plugin NOT installed (user-specific, optional)"

# ── Agency Agents (184 domain specialists) ──────────────────────────────────
step "Installing Agency domain specialists (184 agents)"

AGENCY_REPO="${HOME}/.local/share/agency-agents"
if [[ -d "$AGENCY_REPO" ]]; then
    warn "agency-agents repo exists — pulling latest"
    git -C "$AGENCY_REPO" pull --ff-only 2>/dev/null || true
else
    git clone --depth 1 https://github.com/msitarzewski/agency-agents.git "$AGENCY_REPO"
fi
ok "agency-agents repo ready"

# Generate OpenCode integration files
if [[ ! -d "$AGENCY_REPO/integrations/opencode/agents" ]]; then
    warn "Running convert.sh to generate OpenCode agent files..."
    bash "$AGENCY_REPO/scripts/convert.sh" --tool opencode
fi

# Copy agents
AGENT_COUNT=0
for f in "$AGENCY_REPO/integrations/opencode/agents"/*.md; do
    [[ -f "$f" ]] || continue
    cp "$f" "$OPENCODE_AGENTS/"
    ((AGENT_COUNT++)) || true
done
ok "$AGENT_COUNT agency agents installed"

# ── NPM Plugins ─────────────────────────────────────────────────────────────
step "Installing OpenCode npm plugins"

PLUGINS=(
    opencode-vibeguard
    opencode-notify
    opencode-smart-title
    opencode-handoff
    opencode-synced
    opencode-mystatus
)

for plugin in "${PLUGINS[@]}"; do
    if [[ -d "${HOME}/.cache/opencode/packages/${plugin}@latest" ]]; then
        ok "$plugin (already installed)"
    else
        opencode plugin -g "$plugin" 2>&1 | tail -1 && ok "$plugin" || warn "$plugin install failed"
    fi
done

# ── MCP Servers ─────────────────────────────────────────────────────────────
step "MCP Server Setup"

echo ""
echo "  Some MCP servers require manual installation."
echo "  npm-based servers (agentmemory, chrome-devtools, playwright) auto-install via npx."
echo ""

# --- lean-ctx ---
if command -v lean-ctx &>/dev/null; then
    ok "lean-ctx $(lean-ctx --version 2>&1 | head -1)"
else
    warn "lean-ctx not found. Install:"
    echo "    curl -fsSL https://raw.githubusercontent.com/yvgude/lean-ctx/main/install.sh | bash"
fi

# --- codegraph ---
if command -v codegraph &>/dev/null; then
    ok "codegraph $(codegraph --version 2>&1 | head -1)"
else
    warn "codegraph not found. Install:"
    echo "    npm install -g @codegraph/cli"
    echo "  Then run 'codegraph init -i' in each project root."
fi

# --- maru-deep-pro-search ---
if command -v maru-deep-pro-search &>/dev/null; then
    ok "maru-deep-pro-search installed"
else
    warn "maru-deep-pro-search not found (custom tool, may need manual build)"
fi

# --- open-design (od) ---
if command -v od &>/dev/null; then
    ok "od (open-design) installed"
else
    warn "od (open-design) not found. Download from open-design.ai"
fi

# ── API Keys ─────────────────────────────────────────────────────────────────
step "API Key Setup"

echo ""
echo "  Run these commands to configure API providers:"
echo ""
echo "    ${CYAN}opencode providers login${RESET}     # Interactive provider setup"
echo ""
echo "  Required providers for this harness:"
echo "    • DeepSeek API  → opencode providers login (select DeepSeek)"
echo "    • OpenRouter    → opencode providers login (select OpenRouter, optional)"
echo ""
echo "  For opencode-synced (config sync via GitHub):"
echo "    export GITHUB_TOKEN=ghp_xxxx"

# ── Verification ────────────────────────────────────────────────────────────
step "Verification"

echo ""
echo "  ┌──────────────────────────────────────────────────────┐"
echo "  │  ${BOLD}OpenCode Harness — Setup Complete${RESET}                    │"
echo "  ├──────────────────────────────────────────────────────┤"
echo "  │  Config:     ~/.config/opencode/opencode.json        │"
echo "  │  Prompts:    ~/.config/opencode/.opencode/prompts/   │"
echo "  │  AGENTS.md:  ~/.config/opencode/AGENTS.md            │"
echo "  │  Agents:     ${AGENT_COUNT} agency + 15 inline              │"
echo "  │  Plugins:    ${#PLUGINS[@]} npm + lean-ctx.ts local          │"
echo "  │  MCP:        7 servers (check warnings above)        │"
echo "  └──────────────────────────────────────────────────────┘"
echo ""
echo "  ${BOLD}Next steps:${RESET}"
echo "  1. Configure API keys:  ${CYAN}opencode providers login${RESET}"
echo "  2. Restart OpenCode:    quit + reopen TUI"
echo "  3. Verify agents:       ${CYAN}opencode agent list${RESET}"
echo "  4. Init CodeGraph:      ${CYAN}codegraph init -i${RESET} (per project)"
echo ""
