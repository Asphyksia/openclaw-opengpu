---
title: "OpenGPU Relay Integration"
summary: "Use OpenGPU Network's decentralized LLM models with OpenClaw"
---

# OpenGPU Relay Integration 🦞🔗

OpenClaw now integrates with [OpenGPU Network](https://opengpu.network/)'s Relay API, giving you access to powerful, cost-effective decentralized LLM models.

## Why OpenGPU Relay?

| Feature | Traditional LLM APIs | OpenGPU Relay |
|---------|---------------------|---------------|
| **Cost** | $20-30/month (fixed) | ~$2-5/month (pay-as-you-go) |
| **Models** | Limited selection | Multiple open-source models |
| **Privacy** | Data sent to centralized servers | Decentralized network |
| **Reliability** | Single provider | Distributed GPU network |
| **Token Cost** | ~$0.03/1K tokens (GPT-4) | ~$0.003/1K tokens |

## Quick Start

### Prerequisites

- Docker with Docker Compose v2
- OpenGPU Relay API Key from [relaygpu.com](https://relaygpu.com)

### Installation (Linux/macOS/WSL2)

```bash
# 1. Clone OpenClaw repository
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 2. Run the OpenGPU configuration script
./scripts/configure-opengpu.sh

# 3. Follow the prompts:
#    - Enter your OpenGPU API key
#    - Select your default model
#    - Configuration is created automatically

# 4. Start OpenClaw
./docker-setup.sh
```

### Installation (Windows)

#### Recommended: WSL2 (Ubuntu)

```bash
# Run these commands inside your Ubuntu/WSL2 terminal
git clone https://github.com/openclaw/openclaw.git
cd openclaw

./scripts/configure-opengpu.sh
./docker-setup.sh
```

#### Alternative: PowerShell + Docker Desktop (advanced)

```powershell
# 1. Clone OpenClaw repository
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 2. Run the OpenGPU configuration script
.\scripts\configure-opengpu.ps1
```

Then, from Git Bash or your WSL2 terminal in the same directory, start OpenClaw:

```bash
./docker-setup.sh
```

## Available Models

OpenGPU Relay provides access to several powerful open-source models:

| Model | Parameters | Best For | Speed | Cost |
|-------|-----------|----------|-------|------|
| `opengpu/openai/gpt-oss-120b` | 120B | Complex reasoning, coding | Slower | Higher |
| `opengpu/openai/gpt-oss-20b` | 20B | General tasks, chat | Fast | Medium |
| `opengpu/llama-3.2-3b` | 3B | Quick responses, simple tasks | Very Fast | Lowest |
| `opengpu/deepseek-r1-8b` | 8B | Math, logic puzzles | Fast | Low |

### Model Selection Recommendation

- **Default Choice**: `gpt-oss-120b` - Best balance of capability and cost
- **Budget-Conscious**: `gpt-oss-20b` - Good performance, lower cost
- **Speed-Focused**: `llama-3.2-3b` - Instant responses, simple queries
- **Reasoning Tasks**: `deepseek-r1-8b` - Excellent for math/logic

## Configuration

### OpenClaw Config (`~/.openclaw/openclaw.json`)

The configuration script creates a secure default configuration:

```json5
{
  // OpenGPU Relay API Configuration
  env: {
    OPENGPU_API_KEY: "sk-...", // Your API key
  },

  // Agent configuration
  agents: {
    defaults: {
      model: {
        primary: "opengpu/openai/gpt-oss-120b", // Default model
      },
      // Security: Sandbox all tool execution
      sandbox: {
        mode: "all",
      },
      // Security: Require human approval for dangerous tools
      tools: {
        confirm: "always",
      },
      // Security: DM policy - pairing required
      dmPolicy: "pairing",
    },
  },
}
```

### Changing Models

You can change your default model by re-running the configuration script:

```bash
./scripts/configure-opengpu.sh
```

Or edit `~/.openclaw/openclaw.json` directly and restart:

```bash
# Edit config
nano ~/.openclaw/openclaw.json

# Restart gateway
cd ~/openclaw
docker compose restart openclaw-gateway
```

### Per-Agent Model Configuration

You can assign different models to different agents:

```json5
{
  agents: {
    defaults: {
      model: { primary: "opengpu/openai/gpt-oss-20b" },
    },
    list: [
      {
        agent: "coder",
        model: { primary: "opengpu/openai/gpt-oss-120b" }, // More powerful
        workspace: "~/.openclaw/workspace/coder",
      },
      {
        agent: "chat",
        model: { primary: "opengpu/llama-3.2-3b" }, // Faster
        workspace: "~/.openclaw/workspace/chat",
      },
    ],
  },
}
```

## Security Configuration

The OpenGPU integration includes **security by default**:

### 1. DM Policy (Pairing Mode)

Only approved users can DM your bot:

```json5
{
  channels: {
    telegram: { dmPolicy: "pairing" },
    discord: { dmPolicy: "pairing" },
    whatsapp: { dmPolicy: "pairing" },
  },
}
```

**Approving users:**
```bash
docker compose run --rm openclaw-cli pairing list telegram
docker compose run --rm openclaw-cli pairing approve telegram <user-id>
```

### 2. Tool Sandbox

All tool execution runs in isolated Docker containers:

```json5
{
  agents: {
    defaults: {
      sandbox: {
        mode: "all",        // All sessions sandboxed
        scope: "agent",     // One container per agent
        workspaceAccess: "none",  // No workspace access by default
      },
    },
  },
}
```

### 3. Human Approval

Dangerous commands require manual approval:

```json5
{
  agents: {
    defaults: {
      tools: {
        confirm: "always",  // Require approval for dangerous tools
      },
    },
  },
}
```

### 4. DM Pairing & Channel Allowlists

DM pairing is enabled by default so that unknown users cannot message your assistant directly without approval.

If you want to make it easier for **your own accounts** to talk to the assistant while keeping everyone else in pairing mode, you can add an allowlist for each channel:

```json5
{
  channels: {
    whatsapp: {
      dmPolicy: "pairing",
      allowFrom: ["+15555550123"], // your own phone number
    },
    telegram: {
      dmPolicy: "pairing",
      allowFrom: ["@your_telegram_username"],
    },
    discord: {
      dmPolicy: "pairing",
      allowFrom: ["123456789012345678"], // your Discord user ID
    },
  },
}
```

This keeps the **secure default** (pairing for everyone) while making it frictionless for your own accounts.

### 5. Security & Secrets

- Your OpenGPU API key is stored locally in:
  - the project root `.env` file (as `OPENGPU_API_KEY`)
  - your OpenClaw config at `~/.openclaw/openclaw.json`
- **Never commit these files to git.** Before pushing to GitHub, make sure:
  - `.env` and any `.env.backup.*` files are listed in your `.gitignore`
  - you have not staged or committed them.
- If an API key is ever pushed to a public repository:
  1. Revoke it from the [relaygpu.com](https://relaygpu.com) dashboard.
  2. Generate a new key.
  3. Re‑run the OpenGPU configuration script with the new key.

### 6. Gateway Binding & Remote Access

By default the Docker gateway binds to **loopback**, which means:

- the Control UI and WebSocket API are only accessible from the same machine
- this is the safest default for new users and single‑machine setups

To expose the gateway on your local network (LAN), you can:

1. Set `OPENCLAW_GATEWAY_BIND=lan` in your `.env` file.
2. Re‑run `./docker-setup.sh` to regenerate Docker Compose config.
3. Make sure you trust your local network and keep the gateway token secret.

For safe remote access across devices or the internet, prefer:

- [Tailscale Serve/Funnel](https://docs.openclaw.ai/gateway/tailscale)
- [SSH tunnels](https://docs.openclaw.ai/gateway/remote)

instead of exposing the gateway directly to the public internet.

## Channel Setup

After configuring OpenGPU, you can add chat channels:

### WhatsApp (QR Code)

```bash
docker compose run --rm openclaw-cli channels login
```

Scan the QR code with your phone. Session persists after restart.

### Telegram (Bot Token)

```bash
# 1. Create a bot at https://t.me/BotFather
# 2. Copy the bot token
docker compose run --rm openclaw-cli channels add --channel telegram --token "your-bot-token"
```

### Discord (Bot Token)

```bash
# 1. Create a bot at https://discord.com/developers/applications
# 2. Copy the bot token
docker compose run --rm openclaw-cli channels add --channel discord --token "your-bot-token"
```

## Testing Your Setup

### Test OpenGPU Connection

```bash
# Linux/macOS/WSL2
./scripts/configure-opengpu.sh
# From the menu, choose: 3) Test OpenGPU connection

# Windows
.\scripts\configure-opengpu.ps1
# From the menu, choose: 3) Test OpenGPU connection
```

### Test OpenClaw Gateway

```bash
# Check gateway health
docker compose exec openclaw-gateway node dist/index.js health --token "$OPENCLAW_GATEWAY_TOKEN"

# View logs
docker compose logs -f openclaw-gateway

# Send a test message (via your configured channel)
# Example: Send "Hello" to your Telegram bot
```

## Troubleshooting

### Invalid API Key

**Problem**: "Invalid OpenGPU API Key" error

**Solution**:
1. Verify your API key at https://relaygpu.com
2. Re-run the configuration script:
   ```bash
   ./scripts/configure-opengpu.sh
   ```
3. Select option 1 to re-enter your API key

### Connection Refused

**Problem**: Cannot connect to OpenGPU Relay

**Solution**:
1. Check your internet connection
2. Verify OpenGPU Relay status:
   ```bash
   curl https://relay.opengpu.network/health
   ```
3. Check Docker logs:
   ```bash
   docker compose logs openclaw-gateway | grep -i opengpu
   ```

### Model Not Found

**Problem**: "Model not found" error

**Solution**:
1. Verify the model name in your config
2. Re-run configuration script to select a different model
3. Check available models:
   ```bash
   curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://relay.opengpu.network/v1/models
   ```

### High Latency

**Problem**: Slow responses from OpenGPU

**Solution**:
1. Switch to a smaller/faster model (e.g., `llama-3.2-3b`)
2. Check OpenGPU network status
3. Consider using `gpt-oss-20b` as a balance

## Cost Management

### Monitor Your Usage

OpenGPU Relay provides pay-as-you-go billing. Check your usage at:
https://relaygpu.com/dashboard

### Cost-Saving Tips

1. **Use smaller models for simple tasks**: `llama-3.2-3b` for quick queries
2. **Reserve 120B for complex tasks**: Coding, analysis, reasoning
3. **Enable context windowing**: Reduces token usage
4. **Use memory system**: Avoids repeating context

### Estimated Monthly Costs

| Usage Pattern | Model | Est. Cost/Month |
|--------------|-------|-----------------|
| Light (100 msgs/day) | gpt-oss-20b | ~$2-3 |
| Medium (500 msgs/day) | gpt-oss-20b | ~$5-8 |
| Heavy (1000+ msgs/day) | gpt-oss-120b | ~$10-15 |
| Power user | gpt-oss-120b | ~$20-30 |

*Estimates vary based on message length and complexity*

## Advanced Configuration

### Multiple Providers

You can configure OpenGPU alongside other providers:

```json5
{
  env: {
    OPENGPU_API_KEY: "sk-...",
    ANTHROPIC_API_KEY: "sk-ant-...",
  },

  agents: {
    defaults: {
      model: {
        primary: "opengpu/openai/gpt-oss-120b",
        fallback: ["anthropic/claude-sonnet-4-5"],
      },
    },
  },
}
```

### Custom API Endpoint

If you have a custom OpenGPU Relay endpoint:

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "opengpu/openai/gpt-oss-120b",
        providerOptions: {
          opengpu: {
            baseURL: "https://your-custom-endpoint.com/v1",
          },
        },
      },
    },
  },
}
```

## Community & Support

- **OpenClaw Docs**: https://docs.openclaw.ai
- **OpenGPU Network**: https://opengpu.network
- **OpenGPU Relay**: https://relaygpu.com
- **Issues**: https://github.com/openclaw/openclaw/issues

## License

This integration follows the same license as OpenClaw (MIT).

---

**Enjoy powerful, affordable, and decentralized AI with OpenClaw + OpenGPU!** 🚀
