#!/usr/bin/env bash
# =============================================================================
# OpenCode Harness — Reproducible Setup Script
# =============================================================================
# Recreates the full OpenCode agent ecosystem on any machine:
#   15 inline agents (Plan/Build/Review + 12 workflow subagents)
#   184 Agency domain specialists (github.com/msitarzewski/agency-agents)
#   7 MCP servers with official install methods
#   7 npm plugins (vibeguard, notify, smart-title, handoff, synced, mystatus, DCP)
#   DCP context pruning — 250k soft limit, dedup + error purge
#   Quality pipeline: 4-phase (Smoke → Validation → Polish → Gate)
#
# Usage:
#   chmod +x install.sh && ./install.sh
#
# Post-install (manual):
#   - API keys: opencode providers login
#   - GitHub token for opencode-synced: export GITHUB_TOKEN=...
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
    err "opencode CLI not found. Install: npm install -g opencode@latest"
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
sed "s|{{HOME}}|$HOME|g" "$HARNESS_DIR/opencode.json" > "$OPENCODE_CONFIG/opencode.json"
ok "opencode.json installed (paths resolved)"

# ── DCP Config ──────────────────────────────────────────────────────────────
step "Installing DCP context pruning config"

if [[ -f "$OPENCODE_CONFIG/dcp.jsonc" ]]; then
    warn "dcp.jsonc already exists — backing up to dcp.jsonc.bak"
    cp "$OPENCODE_CONFIG/dcp.jsonc" "$OPENCODE_CONFIG/dcp.jsonc.bak"
fi
cp "$HARNESS_DIR/dcp.jsonc" "$OPENCODE_CONFIG/dcp.jsonc"
ok "dcp.jsonc installed (250k soft limit, dedup + error purge)"

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
    @tarquinen/opencode-dcp@latest
)

for plugin in "${PLUGINS[@]}"; do
    pkg_name="${plugin%@*}"
    if [[ -d "${HOME}/.cache/opencode/packages/${pkg_name}@latest" ]] || \
       [[ -d "${HOME}/.cache/opencode/packages/${plugin}" ]]; then
        ok "$plugin (already installed)"
    else
        opencode plugin -g "$plugin" 2>&1 | tail -1 && ok "$plugin" || warn "$plugin install failed"
    fi
done

# ═══════════════════════════════════════════════════════════════════════════════
# MCP SERVER INSTALLATION — Official Methods
# ═══════════════════════════════════════════════════════════════════════════════

step "MCP Server Setup (official install methods)"

# ── 1. agentmemory (rohitg00/agentmemory) ──────────────────────────────────
echo ""
echo "  ${BOLD}1. agentmemory${RESET} — Persistent memory for AI agents"
echo "     Official: npm install -g @agentmemory/agentmemory"
echo "     Repo:     https://github.com/rohitg00/agentmemory"
echo ""

if command -v agentmemory &>/dev/null; then
    ok "agentmemory CLI found"
    # Check if daemon is running
    if curl -s http://localhost:3111/agentmemory/health &>/dev/null; then
        ok "agentmemory daemon running (port 3111)"
    else
        warn "agentmemory daemon NOT running — start it: agentmemory &"
        echo "     Viewer: http://localhost:3113"
    fi
else
    warn "agentmemory not installed"
    echo "     Install: npm install -g @agentmemory/agentmemory"
    echo "     Start:   agentmemory                    # daemon on :3111"
    echo "     Viewer:  http://localhost:3113"
    echo "     MCP:     @agentmemory/mcp (auto-bridged by harness config)"
fi

# ── 2. chrome-devtools (ChromeDevTools/chrome-devtools-mcp) ─────────────────
echo ""
echo "  ${BOLD}2. chrome-devtools${RESET} — Browser DevTools for agents"
echo "     Official: https://developer.chrome.com/docs/devtools/agents/get-started"
echo "     Repo:     https://github.com/ChromeDevTools/chrome-devtools-mcp"
echo ""

# Check Chrome
CHROME_PATH=""
if [[ -d "/Applications/Google Chrome.app" ]]; then
    CHROME_PATH="/Applications/Google Chrome.app"
    ok "Google Chrome found"
elif command -v google-chrome &>/dev/null; then
    CHROME_PATH="$(command -v google-chrome)"
    ok "Google Chrome found at $CHROME_PATH"
else
    warn "Google Chrome not found — required for chrome-devtools MCP"
    echo "     Download: https://www.google.com/chrome/"
fi

if command -v chrome-devtools-mcp &>/dev/null; then
    ok "chrome-devtools-mcp CLI found"
else
    warn "chrome-devtools-mcp not installed"
    echo "     Install: npm install -g chrome-devtools-mcp"
    echo "     Or use npx: npx chrome-devtools-mcp@latest"
fi

# ── 3. playwright (microsoft/playwright-mcp) ────────────────────────────────
echo ""
echo "  ${BOLD}3. playwright${RESET} — Browser automation via accessibility tree"
echo "     Official: https://github.com/microsoft/playwright-mcp"
echo "     Package:  @playwright/mcp (33k stars)"
echo ""

if command -v playwright-mcp &>/dev/null; then
    ok "playwright-mcp CLI found"
else
    warn "@playwright/mcp not globally installed"
    echo "     Install: npm install -g @playwright/mcp"
fi

# Check Playwright browsers
if npx playwright install --dry-run 2>/dev/null | grep -q "chromium"; then
    ok "Playwright browser binaries found"
else
    warn "Playwright browsers not installed"
    echo "     Install: npx playwright install chromium"
    echo "     (Required for browser automation to work)"
fi

# ── 4. lean-ctx (yvgude/lean-ctx) ──────────────────────────────────────────
echo ""
echo "  ${BOLD}4. lean-ctx${RESET} — Cognitive context layer (2.2k stars)"
echo "     Official: https://github.com/yvgude/lean-ctx"
echo "     Install:  curl -fsSL https://leanctx.com/install.sh | sh"
echo ""

if command -v lean-ctx &>/dev/null; then
    ok "lean-ctx $(lean-ctx --version 2>&1 | head -1)"
    # Check if setup has been run
    if lean-ctx doctor &>/dev/null; then
        ok "lean-ctx health check passed"
    else
        warn "lean-ctx needs setup: lean-ctx setup && lean-ctx doctor"
    fi
else
    warn "lean-ctx not installed"
    echo "     curl -fsSL https://leanctx.com/install.sh | sh"
    echo "     # or: brew tap yvgude/lean-ctx && brew install lean-ctx"
    echo "     # or: npm install -g lean-ctx-bin"
    echo ""
    echo "     After install: lean-ctx setup && lean-ctx doctor"
fi

# ── 5. codegraph (@colbymchenry/codegraph) ─────────────────────────────────
echo ""
echo "  ${BOLD}5. codegraph${RESET} — Semantic code intelligence (tree-sitter AST)"
echo "     Official: https://www.npmjs.com/package/@colbymchenry/codegraph"
echo "     Install:  curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh"
echo ""

if command -v codegraph &>/dev/null; then
    ok "codegraph $(codegraph --version 2>&1 | head -1)"
else
    warn "codegraph not installed"
    echo "     # Auto-installer (recommended — auto-detects agents):"
    echo "     curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh"
    echo ""
    echo "     # Or npm:"
    echo "     npm install -g @colbymchenry/codegraph"
    echo "     codegraph install --yes"
    echo ""
    echo "     Per-project: cd <project> && codegraph init -i"
fi

# ── 6. maru-deep-pro-search (custom research pipeline) ─────────────────────
echo ""
echo "  ${BOLD}6. maru-deep-pro-search${RESET} — Multi-engine research MCP"
echo "     Custom tool — not publicly distributed"
echo ""

if command -v maru-deep-pro-search &>/dev/null; then
    ok "maru-deep-pro-search installed"
else
    warn "maru-deep-pro-search not found"
    echo "     This is a custom tool. Remove from opencode.json#mcp if not needed."
fi

# ── 7. open-design (nexu-io/open-design) ───────────────────────────────────
echo ""
echo "  ${BOLD}7. open-design${RESET} — Local-first design generation (51k stars)"
echo "     Official: https://github.com/nexu-io/open-design"
echo "     Website:  https://open-design.ai"
echo ""

if command -v od &>/dev/null; then
    ok "od CLI found"
else
    warn "od (open-design) CLI not found"
    echo "     Download from: https://open-design.ai"
    echo "     macOS: download .dmg, install to /Applications"
    echo "     After install, create a shim so 'od' doesn't shadow POSIX od:"
    echo "       ln -sf '/Applications/Open Design.app/Contents/MacOS/od' ~/.local/bin/od"
fi

# ── Singleton-Safe MCP Wrappers ────────────────────────────────────────────
echo ""
echo "  ${BOLD}MCP Process Safety${RESET}"
echo "  The harness uses singleton-safe wrappers to prevent process accumulation."
echo "  If you installed agentmemory/chrome-devtools/playwright globally, run:"
echo ""
echo "    bash ${HARNESS_DIR}/scripts/create-mcp-wrappers.sh"
echo ""

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
echo "  │  DCP:        ~/.config/opencode/dcp.jsonc            │"
echo "  │  Prompts:    ~/.config/opencode/.opencode/prompts/   │"
echo "  │  AGENTS.md:  ~/.config/opencode/AGENTS.md            │"
echo "  │  Agents:     ${AGENT_COUNT} agency + 15 inline              │"
echo "  │  Plugins:    ${#PLUGINS[@]} npm + lean-ctx.ts local          │"
echo "  │  MCP:        7 servers (check warnings above)        │"
echo "  └──────────────────────────────────────────────────────┘"
echo ""
echo "  ${BOLD}Post-install checklist:${RESET}"
echo "  1. API keys:      ${CYAN}opencode providers login${RESET}"
echo "  2. Restart:       quit + reopen OpenCode TUI"
echo "  3. Verify agents: ${CYAN}opencode agent list${RESET}"
echo "  4. CodeGraph:     ${CYAN}codegraph init -i${RESET} (per project)"
echo "  5. lean-ctx:      ${CYAN}lean-ctx setup && lean-ctx doctor${RESET}"
echo "  6. agentmemory:   ${CYAN}agentmemory &${RESET} (start daemon on :3111)"
echo "  7. MCP wrappers:  ${CYAN}bash ${HARNESS_DIR}/scripts/create-mcp-wrappers.sh${RESET}"
echo ""
