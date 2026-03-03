# ─────────────────────────────────────────────────────────
#  OpenClaw + OpenGPU Relay — Quick Setup (Windows)
#  Uses the official OpenClaw Docker image (no build needed)
# ─────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Info($msg)    { Write-Host "  i " -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Write-Ok($msg)      { Write-Host "  ✓ " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn($msg)    { Write-Host "  ! " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err($msg)     { Write-Host "  x " -ForegroundColor Red -NoNewline; Write-Host $msg }

# ── Check Docker ────────────────────────────────────────
Write-Host ""
Write-Host "  OpenClaw + OpenGPU Relay — Quick Setup" -ForegroundColor Cyan
Write-Host ""

try {
    docker compose version | Out-Null
    Write-Ok "Docker + Compose detected"
} catch {
    Write-Err "Docker is not available."
    Write-Host "  Install Docker Desktop: https://docs.docker.com/desktop/install/windows-install/"
    Write-Host "  Make sure it's running before trying again."
    exit 1
}

# ── Directories ─────────────────────────────────────────
$ConfigDir  = if ($env:OPENCLAW_CONFIG_DIR)    { $env:OPENCLAW_CONFIG_DIR }    else { "$env:USERPROFILE\.openclaw" }
$WorkspaceDir = if ($env:OPENCLAW_WORKSPACE_DIR) { $env:OPENCLAW_WORKSPACE_DIR } else { "$env:USERPROFILE\.openclaw\workspace" }

New-Item -ItemType Directory -Force -Path $ConfigDir    | Out-Null
New-Item -ItemType Directory -Force -Path $WorkspaceDir | Out-Null

# ── Gateway token ───────────────────────────────────────
function New-Token {
    -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
}

# ── OpenGPU API Key ─────────────────────────────────────
Write-Host ""
Write-Host "  OpenGPU Relay API Key" -ForegroundColor Cyan
Write-Host "  Get yours at: https://relaygpu.com"
Write-Host ""

do {
    $ApiKey = Read-Host "  API Key"
    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        Write-Err "API key cannot be empty"
    }
} while ([string]::IsNullOrWhiteSpace($ApiKey))

Write-Ok "API key saved"

# ── Channel setup ───────────────────────────────────────
Write-Host ""
Write-Host "  Chat Channel" -ForegroundColor Cyan
Write-Host "  1) Telegram (recommended)"
Write-Host "  2) WhatsApp (QR code after setup)"
Write-Host "  3) Discord"
Write-Host "  4) Skip for now"
Write-Host ""

$Channel = ""
$ChannelToken = ""

do {
    $choice = Read-Host "  Choice [1]"
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

    switch ($choice) {
        "1" {
            $Channel = "telegram"
            Write-Host ""
            Write-Host "  Create a bot with @BotFather on Telegram, then paste the token:"
            $ChannelToken = Read-Host "  Bot Token"
            break
        }
        "2" {
            $Channel = "whatsapp"
            Write-Info "WhatsApp will show a QR code after setup"
            break
        }
        "3" {
            $Channel = "discord"
            Write-Host ""
            Write-Host "  Create a bot at https://discord.com/developers/applications"
            $ChannelToken = Read-Host "  Bot Token"
            break
        }
        "4" {
            break
        }
        default {
            Write-Err "Choose 1-4"
            $choice = ""
        }
    }
} while ($choice -eq "")

# ── Generate config ─────────────────────────────────────
$GatewayToken = New-Token

$ChannelsBlock = ""
switch ($Channel) {
    "telegram" {
        $ChannelsBlock = @"
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$ChannelToken",
      "dmPolicy": "allowlist",
      "allowFrom": [],
      "groupPolicy": "allowlist",
      "streaming": "partial"
    }
  },
"@
    }
    "discord" {
        $ChannelsBlock = @"
  "channels": {
    "discord": {
      "enabled": true,
      "botToken": "$ChannelToken",
      "dmPolicy": "allowlist",
      "allowFrom": [],
      "groupPolicy": "allowlist"
    }
  },
"@
    }
    "whatsapp" {
        $ChannelsBlock = @"
  "channels": {
    "whatsapp": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowFrom": []
    }
  },
"@
    }
}

$Config = @"
{
  "models": {
    "providers": {
      "relaygpu-anthropic": {
        "baseUrl": "https://relay.opengpu.network/v2/anthropic/v1/",
        "apiKey": "$ApiKey",
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
        "apiKey": "$ApiKey",
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
          },
          {
            "id": "Qwen/Qwen3-Coder",
            "name": "Qwen3 Coder (OpenGPU Relay)",
            "api": "openai-completions",
            "reasoning": true,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 128000,
            "maxTokens": 65536
          },
          {
            "id": "moonshotai/kimi-k2.5",
            "name": "Kimi K2.5 (OpenGPU Relay)",
            "api": "openai-completions",
            "reasoning": true,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 128000,
            "maxTokens": 65536
          },
          {
            "id": "qwen/qwen2.5-vl-72b-instruct",
            "name": "Qwen2.5 VL 72B (OpenGPU Relay)",
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
$ChannelsBlock
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "$GatewayToken"
    }
  }
}
"@

$Config | Set-Content -Path "$ConfigDir\openclaw.json" -Encoding UTF8
Write-Ok "Config created: $ConfigDir\openclaw.json"

# ── Write .env ──────────────────────────────────────────
@"
OPENCLAW_CONFIG_DIR=$ConfigDir
OPENCLAW_WORKSPACE_DIR=$WorkspaceDir
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_BRIDGE_PORT=18790
OPENCLAW_GATEWAY_BIND=loopback
OPENCLAW_GATEWAY_TOKEN=$GatewayToken
"@ | Set-Content -Path "$RootDir\.env" -Encoding UTF8

Write-Ok "Env file created: $RootDir\.env"

# ── Start ───────────────────────────────────────────────
Write-Host ""
Write-Host "  Starting OpenClaw" -ForegroundColor Cyan
Write-Info "Pulling official image..."

docker compose -f "$RootDir\docker-compose.yml" pull

Write-Info "Starting gateway..."
docker compose -f "$RootDir\docker-compose.yml" up -d openclaw-gateway

Write-Host ""
Write-Ok "OpenClaw is running!"
Write-Host ""
Write-Host "  Config:    $ConfigDir\openclaw.json"
Write-Host "  Workspace: $WorkspaceDir"
Write-Host "  Token:     $GatewayToken"
Write-Host ""

if ($Channel -eq "whatsapp") {
    Write-Host "  To link WhatsApp, run:"
    Write-Host "     docker compose run --rm openclaw-cli channels login"
    Write-Host ""
}

if ($Channel -ne "") {
    Write-Warn "Add your user ID to 'allowFrom' in the config to start chatting."
    Write-Host "     Then restart: docker compose restart openclaw-gateway"
    Write-Host ""
}

Write-Host "  Docs:    https://docs.openclaw.ai"
Write-Host "  Discord: https://discord.gg/clawd"
Write-Host ""
Write-Host "  Useful commands:"
Write-Host "     docker compose logs -f openclaw-gateway    # View logs"
Write-Host "     docker compose restart openclaw-gateway    # Restart"
Write-Host "     docker compose down                        # Stop"
Write-Host ""
