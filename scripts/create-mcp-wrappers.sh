#!/usr/bin/env bash
# =============================================================================
# MCP Singleton-Safe Wrappers
# =============================================================================
# Creates wrapper scripts at ~/.local/bin/ that ensure only ONE instance
# of each MCP server runs at a time. Prevents process accumulation when
# OpenCode restarts without killing old MCP children.
#
# Usage: bash create-mcp-wrappers.sh
# =============================================================================

set -euo pipefail

LOCAL_BIN="${HOME}/.local/bin"
mkdir -p "$LOCAL_BIN"

declare -A MCP_SERVERS=(
    ["agentmemory"]="agentmemory-mcp"
    ["chrome-devtools"]="chrome-devtools-mcp"
    ["playwright"]="playwright-mcp"
)

for name in "${!MCP_SERVERS[@]}"; do
    binary="${MCP_SERVERS[$name]}"
    wrapper="${LOCAL_BIN}/${binary}-safe"

    if [[ -f "$wrapper" ]]; then
        echo "[SKIP] $wrapper already exists"
        continue
    fi

    if ! command -v "$binary" &>/dev/null; then
        echo "[WARN] $binary not found on PATH — install it first:"
        echo "       npm install -g ${binary}"
        continue
    fi

    cat > "$wrapper" << 'SCRIPT_EOF'
#!/usr/bin/env bash
# Singleton-safe wrapper — kills old instance before starting new one.
# Uses pgrep to find OTHER instances (excludes self by PID).
BINARY_NAME="$(basename "${BASH_SOURCE[0]}" -safe)"
BINARY_PATH="$(command -v "${BINARY_NAME}")"

# Kill old instances (skip self)
for pid in $(pgrep -f "${BINARY_NAME}" 2>/dev/null || true); do
    [[ "$pid" == "$$" ]] && continue
    kill "$pid" 2>/dev/null || true
done
sleep 0.3
exec "${BINARY_PATH}" "$@"
SCRIPT_EOF

    chmod +x "$wrapper"
    echo "[OK]  $wrapper created"
done

echo ""
echo "Done. Verify wrappers exist:"
ls -la "$LOCAL_BIN"/*-mcp-safe 2>/dev/null || echo "  (no wrappers found)"
