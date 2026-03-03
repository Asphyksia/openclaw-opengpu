# Available Models

OpenGPU Relay exposes models through two API endpoints, matching the native APIs of each provider.

## Anthropic Models (via `relaygpu-anthropic`)

Base URL: `https://relay.opengpu.network/v2/anthropic/v1/`

### Claude Opus 4-6
- **ID**: `anthropic/claude-opus-4-6`
- **Context window**: 400,000 tokens
- **Max output**: 128,000 tokens
- **Reasoning**: ✅
- **Best for**: Complex tasks, coding, analysis, creative work

### Claude Sonnet 4-6
- **ID**: `anthropic/claude-sonnet-4-6`
- **Context window**: 200,000 tokens
- **Max output**: 64,000 tokens
- **Reasoning**: ✅
- **Best for**: Balanced performance, everyday tasks

## OpenAI-compatible Models (via `relaygpu-openai`)

Base URL: `https://relay.opengpu.network/v2/openai/v1/`

### GPT-5.2
- **ID**: `openai/gpt-5.2`
- **Context window**: 128,000 tokens
- **Max output**: 65,536 tokens
- **Reasoning**: ✅
- **Best for**: General purpose, broad knowledge

### DeepSeek V3.1
- **ID**: `deepseek-ai/DeepSeek-V3.1`
- **Context window**: 128,000 tokens
- **Max output**: 65,536 tokens
- **Reasoning**: ✅
- **Best for**: Math, logic, code, reasoning tasks

## Switching Models

In chat, use the `/model` command:

```
/model relaygpu-anthropic/anthropic/claude-opus-4-6
/model relaygpu-anthropic/anthropic/claude-sonnet-4-6
/model relaygpu-openai/openai/gpt-5.2
/model relaygpu-openai/deepseek-ai/DeepSeek-V3.1
```

## Changing the Default Model

Edit `~/.openclaw/openclaw.json`:

```json
"agents": {
  "defaults": {
    "model": {
      "primary": "relaygpu-openai/openai/gpt-5.2"
    }
  }
}
```

Then restart: `docker compose restart openclaw-gateway`

## Cost

All models are available through OpenGPU Relay at pay-as-you-go rates, significantly cheaper than direct API access or subscription plans.

Check your usage at [relaygpu.com](https://relaygpu.com).
