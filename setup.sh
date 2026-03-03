#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
#  OpenClaw + OpenGPU Relay — Quick Setup
#  Uses the official OpenClaw Docker image (no build needed)
# ─────────────────────────────────────────────────────────

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${BLUE}ℹ ${NC}$1"; }
success() { echo -e "${GREEN}✓ ${NC}$1"; }
warn()    { echo -e "${YELLOW}⚠ ${NC}$1"; }
error()   { echo -e "${RED}✗ ${NC}$1"; }
header()  { echo -e "\n${BOLD}$1${NC}\n"; }

# ── Check dependencies ──────────────────────────────────
check_deps() {
    if ! command -v docker &>/dev/null; then
        error "Docker is not installed."
        echo "  Install it: https://docs.docker.com/get-docker/"
        exit 1
    fi
    if ! docker compose version &>/dev/null; then
        error "Docker Compose v2 is not available."
        echo "  Try: docker compose version"
        exit 1
    fi
    success "Docker + Compose detected"
}

# ── Directories ─────────────────────────────────────────
OPENCLAW_CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
OPENCLAW_WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"

mkdir -p "$OPENCLAW_CONFIG_DIR" "$OPENCLAW_WORKSPACE_DIR"

# ── Gateway token ───────────────────────────────────────
generate_token() {
    if command -v openssl &>/dev/null; then
        openssl rand -hex 32
    else
        python3 -c "import secrets; print(secrets.token_hex(32))"
    fi
}

# ── OpenGPU API Key ─────────────────────────────────────
prompt_api_key() {
    echo ""
    header "🔑 OpenGPU Relay API Key"
    echo "  Get yours at: https://relaygpu.com"
    echo ""

    while true; do
        echo -n "  API Key: "
        read -r OPENGPU_API_KEY
        if [[ -n "$OPENGPU_API_KEY" ]]; then
            break
        fi
        error "API key cannot be empty"
    done
    success "API key saved"
}

# ── Channel setup ───────────────────────────────────────
prompt_channel() {
    echo ""
    header "💬 Chat Channel"
    echo "  1) Telegram (recommended — easy bot setup)"
    echo "  2) WhatsApp (QR code pairing after setup)"
    echo "  3) Discord"
    echo "  4) Skip for now"
    echo ""

    while true; do
        echo -n "  Choice [1]: "
        read -r choice
        choice=${choice:-1}

        case $choice in
            1)
                CHANNEL="telegram"
                echo ""
                echo "  Create a bot with @BotFather on Telegram, then paste the token:"
                echo -n "  Bot Token: "
                read -r CHANNEL_TOKEN
                break
                ;;
            2)
                CHANNEL="whatsapp"
                CHANNEL_TOKEN=""
                info "WhatsApp will show a QR code after setup"
                break
                ;;
            3)
                CHANNEL="discord"
                echo ""
                echo "  Create a bot at https://discord.com/developers/applications"
                echo -n "  Bot Token: "
                read -r CHANNEL_TOKEN
                break
                ;;
            4)
                CHANNEL=""
                CHANNEL_TOKEN=""
                break
                ;;
            *)
                error "Choose 1-4"
                ;;
        esac
    done
}

# ── Generate OpenClaw config ────────────────────────────
generate_config() {
    local config_file="$OPENCLAW_CONFIG_DIR/openclaw.json"
    local gateway_token="$1"

    # Channel block
    local channels_block=""
    case "${CHANNEL:-}" in
        telegram)
            channels_block=$(cat <<EOF
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$CHANNEL_TOKEN",
      "dmPolicy": "allowlist",
      "allowFrom": [],
      "groupPolicy": "allowlist",
      "streaming": "partial"
    }
  },
EOF
)
            ;;
        discord)
            channels_block=$(cat <<EOF
  "channels": {
    "discord": {
      "enabled": true,
      "botToken": "$CHANNEL_TOKEN",
      "dmPolicy": "allowlist",
      "allowFrom": [],
      "groupPolicy": "allowlist"
    }
  },
EOF
)
            ;;
        whatsapp)
            channels_block=$(cat <<EOF
  "channels": {
    "whatsapp": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowFrom": []
    }
  },
EOF
)
            ;;
        *)
            channels_block=""
            ;;
    esac

    cat > "$config_file" <<EOF
{
  "models": {
    "providers": {
      "relaygpu-anthropic": {
        "baseUrl": "https://relay.opengpu.network/v2/anthropic/v1/",
        "apiKey": "$OPENGPU_API_KEY",
        "api": "anthropic-messages",
        "models": [
          {
            "id": "anthropic/claude-opus-4-6",
            "name": "Claude Opus 4-6 (OpenGPU Relay)",
            "api": "anthropic-messages",
            "reasoning": true,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 400000,
            "maxTokens": 128000
          },
          {
            "id": "anthropic/claude-sonnet-4-6",
            "name": "Claude Sonnet 4-6 (OpenGPU Relay)",
            "api": "anthropic-messages",
            "reasoning": true,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 200000,
            "maxTokens": 64000
          }
        ]
      },
      "relaygpu-openai": {
        "baseUrl": "https://relay.opengpu.network/v2/openai/v1/",
        "apiKey": "$OPENGPU_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "openai/gpt-5.2",
            "name": "GPT-5.2 (OpenGPU Relay)",
            "api": "openai-completions",
            "reasoning": true,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 128000,
            "maxTokens": 65536
          },
          {
            "id": "deepseek-ai/DeepSeek-V3.1",
            "name": "DeepSeek V3.1 (OpenGPU Relay)",
            "api": "openai-completions",
            "reasoning": true,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 128000,
            "maxTokens": 65536
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "relaygpu-anthropic/anthropic/claude-opus-4-6"
      },
      "workspace": "~/.openclaw/workspace"
    }
  },
$channels_block
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "$gateway_token"
    }
  }
}
EOF

    success "Config created: $config_file"
}

# ── Write .env ──────────────────────────────────────────
write_env() {
    local gateway_token="$1"
    cat > "$ROOT_DIR/.env" <<EOF
OPENCLAW_CONFIG_DIR=$OPENCLAW_CONFIG_DIR
OPENCLAW_WORKSPACE_DIR=$OPENCLAW_WORKSPACE_DIR
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_BRIDGE_PORT=18790
OPENCLAW_GATEWAY_BIND=loopback
OPENCLAW_GATEWAY_TOKEN=$gateway_token
EOF
    success "Env file created: $ROOT_DIR/.env"
}

# ── Main ────────────────────────────────────────────────
main() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  OpenClaw + OpenGPU Relay — Quick Setup  ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
    echo ""

    check_deps

    # Load existing .env if present
    if [[ -f "$ROOT_DIR/.env" ]]; then
        source "$ROOT_DIR/.env"
    fi

    GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-$(generate_token)}"

    prompt_api_key
    prompt_channel
    generate_config "$GATEWAY_TOKEN"
    write_env "$GATEWAY_TOKEN"

    header "🚀 Starting OpenClaw"
    info "Pulling official image..."
    docker compose -f "$ROOT_DIR/docker-compose.yml" pull

    info "Starting gateway..."
    docker compose -f "$ROOT_DIR/docker-compose.yml" up -d openclaw-gateway

    echo ""
    success "OpenClaw is running!"
    echo ""
    echo "  📋 Config:    $OPENCLAW_CONFIG_DIR/openclaw.json"
    echo "  📂 Workspace: $OPENCLAW_WORKSPACE_DIR"
    echo "  🔑 Token:     $GATEWAY_TOKEN"
    echo ""

    if [[ "${CHANNEL:-}" == "whatsapp" ]]; then
        echo "  📱 To link WhatsApp, run:"
        echo "     docker compose run --rm openclaw-cli channels login"
        echo ""
    fi

    if [[ -n "${CHANNEL:-}" ]]; then
        echo "  ⚠️  Add your user ID to 'allowFrom' in the config to start chatting."
        echo "     Then restart: docker compose restart openclaw-gateway"
        echo ""
    fi

    echo "  📖 Docs:    https://docs.openclaw.ai"
    echo "  💬 Discord: https://discord.gg/clawd"
    echo ""
    echo "  Useful commands:"
    echo "     docker compose logs -f openclaw-gateway    # View logs"
    echo "     docker compose restart openclaw-gateway    # Restart"
    echo "     docker compose down                        # Stop"
    echo ""
}

main "$@"
