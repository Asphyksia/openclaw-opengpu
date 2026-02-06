# 🦞 OpenClaw + OpenGPU — Personal AI Assistant (10x más económico)

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

**OpenClaw + OpenGPU** es un asistente de IA personal que se ejecuta en tus propios dispositivos, integrado con **[OpenGPU Relay](https://opengpu.network/)** para hacer **~10x más económico** el uso de LLMs.

Responde en los canales que ya usas: WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, WebChat, y más.

> 💡 **¿Por qué OpenGPU?** En lugar de pagar $20-30/mes por Claude Pro o ChatGPT Plus, OpenGPU cuesta ~$2-5/mes con modelos como GPT-OSS 120B, Llama 3.2, y DeepSeek R1.

---

## 📦 Instalación Recomendada (Docker + OpenGPU)

La forma más simple de comenzar. Solo necesitas Docker instalado.

**Linux / macOS / WSL2:**

```bash
# 1. Clonar el repositorio
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu

# 2. Ejecutar el asistente de configuración
./docker-setup.sh
```

El script automáticamente:
- ✅ Construye la imagen Docker de OpenClaw
- ✅ Te guía en configurar OpenGPU Relay
- ✅ Configura tus canales (WhatsApp, Telegram, etc.)
- ✅ Inicia el asistente

**¿Primera vez con OpenGPU?** Obtén tu API key en [relaygpu.com](https://relaygpu.com)

<details>
<summary><b>Windows (WSL2)</b></summary>

1. Instala [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) con Ubuntu
2. Instala [Docker Desktop](https://www.docker.com/products/docker-desktop/) con WSL2 habilitado
3. Abre la terminal de Ubuntu/WSL2
4. Ejecuta los mismos comandos que en Linux/macOS
</details>

---

## 🚀 Instalación Avanzada (npm + OpenGPU)

Si prefieres más control o ya tienes Node.js ≥22 instalado:

```bash
# 1. Instalar OpenClaw globalmente
npm install -g openclaw@latest
# o: pnpm add -g openclaw@latest

# 2. Configurar OpenGPU
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu
./scripts/configure-opengpu.sh  # Linux/macOS
# o: .\scripts\configure-opengpu.ps1  # Windows

# 3. Ejecutar el asistente
openclaw onboard --install-daemon
```

---

## 💰 ¿Por qué OpenGPU?

| Proveedor | Costo mensual | Modelos |
|-----------|---------------|---------|
| Anthropic Claude Pro | $20-30 | Claude Sonnet/Opus |
| OpenAI ChatGPT Plus | $20 | GPT-4 |
| **OpenGPU Relay** ⭐ | **~$2-5** | **GPT-OSS 120B, Llama 3.2, DeepSeek R1** |

**Ventajas de OpenGPU:**
- 💸 **~10x más barato** que suscripciones tradicionales
- 🔄 Pay-as-you-go (solo pagas por lo que usas)
- 🌍 Red descentralizada de GPUs
- 🚀 Mismos modelos que las grandes empresas

---

## ⚡ Uso Básico

Una vez instalado:

```bash
# Iniciar el gateway
openclaw gateway --port 18789 --verbose

# Enviar un mensaje
openclaw message send --to +1234567890 --message "Hola desde OpenClaw"

# Hablar con el asistente (se puede enviar de vuelta a cualquier canal conectado)
openclaw agent --message "Haz un checklist del proyecto" --thinking high
```

---

## 📚 Documentación Completa

- [Documentación oficial de OpenClaw](https://docs.openclaw.ai)
- [Guía de OpenGPU Relay](docs/opengpu-integration.md)
- [Getting Started](https://docs.openclaw.ai/start/getting-started)
- [FAQ](https://docs.openclaw.ai/start/faq)
- [Discord de la comunidad](https://discord.gg/clawd)

---

## 🌟 Características Principales

- **Multi-canal**: WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, Matrix, Zalo, WebChat
- **Multi-agente**: Enruta canales diferentes hacia agentes aislados
- **Voz**: Voice Wake + Talk Mode en macOS/iOS/Android
- **Live Canvas**: Espacio de trabajo visual controlado por el agente
- **Herramientas**: Browser automation, Canvas, Nodes, Cron, Sesiones
- **Apps companion**: macOS menu bar + iOS/Android

---

## 🛡️ Seguridad

OpenClaw se conecta a plataformas de mensajería reales. Los DMs de desconocidos requieren **aprobación explícita**:

- Por defecto: `dmPolicy="pairing"` (los desconocidos reciben un código de emparejamiento)
- Aprobar con: `openclaw pairing approve <canal> <código>`
- Para DMs públicos: usa `dmPolicy="open"` con `"*"` en la allowlist

Ejecuta `openclaw doctor` para verificar políticas de DM.

Más información: [Security](https://docs.openclaw.ai/gateway/security)

---

## 🔄 Actualización

```bash
# Desde Docker
docker-compose pull
docker-compose up -d

# Desde npm
openclaw update
```

---

## 🏗️ Desarrollo

```bash
git clone https://github.com/Asphyksia/openclaw-opengpu.git
cd openclaw-opengpu

pnpm install
pnpm ui:build
pnpm build
pnpm openclaw onboard
```

---

## 📝 Licencia

MIT License - ver [LICENSE](LICENSE)

---

<p align="center">
  <i>OpenClaw + OpenGPU — IA personal accesible para todos</i>
  <br>
  <a href="https://discord.gg/clawd">Únete al Discord</a> •
  <a href="https://docs.openclaw.ai">Documentación</a> •
  <a href="https://github.com/Asphyksia/openclaw-opengpu">GitHub</a>
</p>
