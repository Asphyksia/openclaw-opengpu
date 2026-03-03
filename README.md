# OpenClaw + OpenGPU Relay

Run your own AI assistant with [OpenClaw](https://github.com/openclaw/openclaw) powered by [OpenGPU Relay](https://opengpu.network/) — decentralized, affordable LLMs.

> **One command. No build. No subscriptions.**

## What you get

- **Claude Opus 4-6** · Claude Sonnet 4-6 · GPT-5.2 · DeepSeek V3.1
- **Pay-as-you-go** via OpenGPU Relay (~$2-5/mo vs $20-30/mo subscriptions)
- **Multi-channel**: Telegram, WhatsApp, Discord, Slack, Signal, and more
- Uses the **official OpenClaw Docker image** — always up to date

## Quick Start

```bash
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu
./setup.sh
```

The setup wizard will:
1. Ask for your **OpenGPU API key** ([get one here](https://relaygpu.com))
2. Configure your **chat channel** (Telegram/WhatsApp/Discord)
3. Pull the official OpenClaw image and start the gateway

That's it. You're running.

### Windows (WSL2)

1. Install [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) with Ubuntu
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) with WSL2 backend enabled
3. Open Ubuntu terminal and run the commands above

## Available Models

| Model | Provider | Context | Max Output |
|-------|----------|---------|------------|
| **Claude Opus 4-6** | Anthropic | 400K | 128K |
| Claude Sonnet 4-6 | Anthropic | 200K | 64K |
| GPT-5.2 | OpenAI | 128K | 65K |
| DeepSeek V3.1 | DeepSeek | 128K | 65K |

All models include reasoning capabilities. Default: **Claude Opus 4-6**.

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

## Project Structure

```
openclaw-opengpu/
├── setup.sh              # Interactive setup wizard
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
