# 🦞 OpenClaw + OpenGPU — Personal AI Assistant (10x Cheaper)

<p align="center">
    <picture>
        <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/openclaw/openclaw/main/docs/assets/openclaw-logo-text-dark.png">
        <img src="https://raw.githubusercontent.com/openclaw/openclaw/main/docs/assets/openclaw-logo-text.png" alt="OpenClaw" width="500">
    </picture>
</p>

<p align="center">
  <strong>EXFOLIATE! EXFOLIATE!</strong>
</p>

<p align="center">
  <a href="https://github.com/openclaw/openclaw/actions/workflows/ci.yml?branch=main"><img src="https://img.shields.io/github/actions/workflow/status/openclaw/openclaw/ci.yml?branch=main&style=for-the-badge" alt="CI status"></a>
  <a href="https://github.com/openclaw/openclaw/releases"><img src="https://img.shields.io/github/v/release/openclaw/openclaw?include_prereleases&style=for-the-badge" alt="GitHub release"></a>
  <a href="https://discord.gg/clawd"><img src="https://img.shields.io/discord/1456350064065904867?label=Discord&logo=discord&logoColor=white&color=5865F2&style=for-the-badge" alt="Discord"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
</p>

**OpenClaw + OpenGPU** is a personal AI assistant that runs on your own devices, integrated with **[OpenGPU Relay](https://opengpu.network/)** to make LLM usage **~10x more affordable**.

It responds on the channels you already use: WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, WebChat, and more.

> 💡 **Why OpenGPU?** Instead of paying $20-30/month for Claude Pro or ChatGPT Plus, OpenGPU costs ~$2-5/month with models like GPT-OSS 120B, Llama 3.2, and DeepSeek R1.

---

## 📦 Recommended Installation (Docker + OpenGPU)

The simplest way to get started. You only need Docker installed.

**Linux / macOS / WSL2:**

```bash
# 1. Clone the repository
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu

# 2. Run the setup wizard
./docker-setup.sh
```

The script automatically:
- ✅ Builds the OpenClaw Docker image
- ✅ Guides you through OpenGPU Relay configuration
- ✅ Configures your channels (WhatsApp, Telegram, etc.)
- ✅ Starts the onboarding wizard

**First time with OpenGPU?** Get your API key at [relaygpu.com](https://relaygpu.com)

<details>
<summary><b>Windows (WSL2)</b></summary>

1. Install [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) with Ubuntu
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) with WSL2 enabled
3. Open the Ubuntu/WSL2 terminal
4. Run the same commands as in Linux/macOS
</details>

---

## 🚀 Advanced Installation (npm + OpenGPU)

If you prefer more control or already have Node.js ≥22 installed:

```bash
# 1. Install OpenClaw globally
npm install -g openclaw@latest
# or: pnpm add -g openclaw@latest

# 2. Configure OpenGPU
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu
./scripts/configure-opengpu.sh  # Linux/macOS
# or: .\scripts\configure-opengpu.ps1  # Windows

# 3. Run the onboarding wizard
openclaw onboard --install-daemon
```

---

## 💰 Why OpenGPU?

| Provider | Monthly Cost | Models |
|-----------|--------------|--------|
| Anthropic Claude Pro | $20-30 | Claude Sonnet/Opus |
| OpenAI ChatGPT Plus | $20 | GPT-4 |
| **OpenGPU Relay** ⭐ | **~$2-5** | **GPT-OSS 120B, Llama 3.2, DeepSeek R1** |

**OpenGPU advantages:**
- 💸 **~10x cheaper** than traditional subscriptions
- 🔄 Pay-as-you-go (only pay for what you use)
- 🌍 Decentralized GPU network
- 🚀 Same models as big providers

---

## ⚡ Basic Usage

Once installed:

```bash
# Start the gateway
openclaw gateway --port 18789 --verbose

# Send a message
openclaw message send --to +1234567890 --message "Hello from OpenClaw"

# Talk to the assistant (can send back to any connected channel)
openclaw agent --message "Make a project checklist" --thinking high
```

---

## 📚 Full Documentation

- [OpenClaw official documentation](https://docs.openclaw.ai)
- [OpenGPU Relay guide](docs/opengpu-integration.md)
- [Getting Started](https://docs.openclaw.ai/start/getting-started)
- [FAQ](https://docs.openclaw.ai/start/faq)
- [Community Discord](https://discord.gg/clawd)

---

## 🌟 Key Features

- **Multi-channel**: WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, Matrix, Zalo, WebChat
- **Multi-agent**: Route different channels to isolated agents
- **Voice**: Voice Wake + Talk Mode on macOS/iOS/Android
- **Live Canvas**: Agent-driven visual workspace
- **Tools**: Browser automation, Canvas, Nodes, Cron, Sessions
- **Companion apps**: macOS menu bar + iOS/Android

---

## 🛡️ Security

OpenClaw connects to real messaging platforms. DMs from unknown senders require **explicit approval**:

- Default: `dmPolicy="pairing"` (unknown senders receive a pairing code)
- Approve with: `openclaw pairing approve <channel> <code>`
- For public DMs: use `dmPolicy="open"` with `"*"` in allowlist

Run `openclaw doctor` to check DM policies.

More info: [Security](https://docs.openclaw.ai/gateway/security)

---

## 🔄 Updating

```bash
# From Docker
docker-compose pull
docker-compose up -d

# From npm
openclaw update
```

---

## 🏗️ Development

```bash
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu

pnpm install
pnpm ui:build
pnpm build
pnpm openclaw onboard
```

---

## 📝 License

MIT License - see [LICENSE](LICENSE)

---

<p align="center">
  <i>OpenClaw + OpenGPU — Personal AI for everyone</i>
  <br>
  <a href="https://discord.gg/clawd">Join Discord</a> •
  <a href="https://docs.openclaw.ai">Documentation</a> •
  <a href="https://github.com/Asphyksia/openclaw-opengpu">GitHub</a>
</p>
