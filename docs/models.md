# Available Models

*Auto-generated from the [OpenGPU Relay API](https://relay.opengpu.network/v2/models) — last updated 2026-03-04*

## Anthropic Models (`relaygpu-anthropic`)

Base URL: `https://relay.opengpu.network/v2/anthropic/v1/`

| Model | ID | Input $/1M | Output $/1M |
|-------|----|-----------|------------|
| **anthropic/claude-opus-4-6** | `anthropic/claude-opus-4-6` | $5.0 | $25.0 |
| **anthropic/claude-sonnet-4-6** | `anthropic/claude-sonnet-4-6` | $3.0 | $15.0 |

## OpenAI-compatible Models (`relaygpu-openai`)

Base URL: `https://relay.opengpu.network/v2/openai/v1/`

| Model | ID | Input $/1M | Output $/1M |
|-------|----|-----------|------------|
| **openai/gpt-5.2** | `openai/gpt-5.2` | $1.75 | $14.0 |
| **deepseek-ai/DeepSeek-V3.1** | `deepseek-ai/DeepSeek-V3.1` | $0.55 | $1.66 |
| **Qwen/Qwen3-Coder** | `Qwen/Qwen3-Coder` | $1.3 | $5.0 |
| **moonshotai/kimi-k2.5** | `moonshotai/kimi-k2.5` | $0.55 | $2.95 |
| **qwen/qwen2.5-vl-72b-instruct** | `qwen/qwen2.5-vl-72b-instruct` | $2.1 | $6.7 |

## Switching Models

In chat, use `/model`:

```
/model relaygpu-anthropic/anthropic/claude-opus-4-6
/model relaygpu-anthropic/anthropic/claude-sonnet-4-6
/model relaygpu-openai/openai/gpt-5.2
/model relaygpu-openai/deepseek-ai/DeepSeek-V3.1
/model relaygpu-openai/Qwen/Qwen3-Coder
/model relaygpu-openai/moonshotai/kimi-k2.5
/model relaygpu-openai/qwen/qwen2.5-vl-72b-instruct
```

## Changing the Default

Edit `~/.openclaw/openclaw.json`:

```json
"agents": {
  "defaults": {
    "model": {
      "primary": "relaygpu-anthropic/anthropic/claude-opus-4-6"
    }
  }
}
```

Then restart: `docker compose restart openclaw-gateway`

## Pricing

All pricing is pay-as-you-go via [relaygpu.com](https://relaygpu.com). No subscriptions.

Live pricing: `curl https://relay.opengpu.network/v2/pricing`
