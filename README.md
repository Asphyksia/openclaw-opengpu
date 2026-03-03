# OpenClaw + OpenGPU Relay

Run your own AI assistant with [OpenClaw](https://github.com/openclaw/openclaw) powered by [OpenGPU Relay](https://opengpu.network/) — decentralized, affordable LLMs.

> **One command. No build. No subscriptions.**

## What you get

- **Claude Opus 4-6** · Claude Sonnet 4-6 · GPT-5.2 · DeepSeek V3.1
- **Pay-as-you-go** via OpenGPU Relay (~$2-5/mo vs $20-30/mo subscriptions)
- **Multi-channel**: Telegram, WhatsApp, Discord, Slack, Signal, and more
- Uses the **official OpenClaw Docker image** — always up to date

## Quick Start

### Linux / macOS / WSL2

```bash
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu
./setup.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu
.\setup.ps1
```

> **Requires**: [Docker Desktop](https://www.docker.com/products/docker-desktop/) running. WSL2 backend recommended.

The setup wizard will:
1. Ask for your **OpenGPU API key** ([get one here](https://relaygpu.com))
2. Configure your **chat channel** (Telegram/WhatsApp/Discord)
3. Pull the official OpenClaw image and start the gateway

That's it. You're running.

## Available Models

| Model | ID | Input $/1M | Output $/1M |
|-------|----|-----------|------------|
| **Claude Opus 4-6** | `anthropic/claude-opus-4-6` | $5.00 | $25.00 |
| **Claude Sonnet 4-6** | `anthropic/claude-sonnet-4-6` | $3.00 | $15.00 |
| **GPT-5.2** | `openai/gpt-5.2` | $1.75 | $14.00 |
| **DeepSeek V3.1** | `deepseek-ai/DeepSeek-V3.1` | $0.55 | $1.66 |
| **Qwen3 Coder** | `Qwen/Qwen3-Coder` | $1.30 | $5.00 |
| **Kimi K2.5** | `moonshotai/kimi-k2.5` | $0.55 | $2.95 |
| **Qwen2.5 VL 72B** | `qwen/qwen2.5-vl-72b-instruct` | $2.10 | $6.70 |

All models include reasoning. Default: **Claude Opus 4-6**. Pricing auto-updates from the [OpenGPU Relay API](https://relay.opengpu.network/v2/pricing).

Switch models anytime in chat:
```
/model relaygpu-openai/openai/gpt-5.2
```

## Cost Comparison

| Provider | Monthly Cost | Model |
|----------|-------------|-------|
| Claude Pro | $20-30 | Claude Sonnet/Opus |
| ChatGPT Plus | $20 | GPT-4o |
| **OpenGPU Relay** ⭐ | **~$2-5** | All of the above |

## After Setup

```bash
# View logs
docker compose logs -f openclaw-gateway

# Restart
docker compose restart openclaw-gateway

# Stop
docker compose down

# Update to latest OpenClaw
docker compose pull && docker compose up -d
```

### Add your user to allowFrom

After setup, edit `~/.openclaw/openclaw.json` and add your user ID:

```json
"allowFrom": ["YOUR_USER_ID"]
```

Then restart: `docker compose restart openclaw-gateway`

**How to find your ID:**
- **Telegram**: Send a message to your bot, check the logs for your user ID
- **Discord**: Enable Developer Mode → right-click your name → Copy User ID

## Already have OpenClaw installed?

If you already have OpenClaw running and just want to add OpenGPU Relay as a provider, add this to your `openclaw.json` under `"models"`:

```json
{
  "models": {
    "providers": {
      "relaygpu-anthropic": {
        "baseUrl": "https://relay.opengpu.network/v2/anthropic/v1/",
        "apiKey": "YOUR_OPENGPU_API_KEY",
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
        "apiKey": "YOUR_OPENGPU_API_KEY",
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
  }
}
```

Then set your default model:

```json
"agents": {
  "defaults": {
    "model": {
      "primary": "relaygpu-anthropic/anthropic/claude-opus-4-6"
    }
  }
}
```

Restart your gateway and you're good to go. Get your API key at [relaygpu.com](https://relaygpu.com).

## Project Structure

```
openclaw-opengpu/
├── setup.sh              # Setup wizard (Linux/macOS/WSL2)
├── setup.ps1             # Setup wizard (Windows PowerShell)
├── docker-compose.yml    # Uses official OpenClaw image
├── .env.example          # Environment template
├── docs/
│   └── models.md         # Model details & configuration
├── LICENSE
└── README.md
```

No Dockerfile. No build step. No fork of OpenClaw. Just config.

## Troubleshooting

**"Cannot connect to Docker"**
→ Make sure Docker Desktop is running (Windows/macOS) or the Docker daemon is active (Linux)

**"Port 18789 already in use"**
→ Change `OPENCLAW_GATEWAY_PORT` in `.env` or stop the other service

**Bot doesn't respond**
→ Check `allowFrom` in your config includes your user ID
→ Check logs: `docker compose logs -f openclaw-gateway`

**Model errors**
→ Verify your API key at [relaygpu.com](https://relaygpu.com)
→ Check OpenGPU Relay status

## Links

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenGPU Network](https://opengpu.network)
- [Get API Key](https://relaygpu.com)
- [Community Discord](https://discord.gg/clawd)

## License

MIT — see [LICENSE](LICENSE)

---

**OpenClaw + OpenGPU — Personal AI for everyone** 🚀
