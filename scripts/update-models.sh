#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
#  Fetch models & pricing from OpenGPU Relay API and
#  regenerate docs/models.md with current data.
#
#  Usage: ./scripts/update-models.sh
#  Called by: GitHub Actions (weekly) or manually
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="$ROOT_DIR/docs/models.md"

MODELS_URL="https://relay.opengpu.network/v2/models"
PRICING_URL="https://relay.opengpu.network/v2/pricing"

echo "Fetching models from $MODELS_URL ..."
MODELS_JSON=$(curl -sf "$MODELS_URL")

echo "Fetching pricing from $PRICING_URL ..."
PRICING_JSON=$(curl -sf "$PRICING_URL")

echo "Generating docs/models.md ..."

python3 - "$MODELS_JSON" "$PRICING_JSON" "$OUT" <<'PYEOF'
import json, sys, datetime

models_raw = json.loads(sys.argv[1])
pricing_raw = json.loads(sys.argv[2])
out_path = sys.argv[3]

# Build pricing lookup: "provider.model_id" -> {input, output}
pricing = {}
for p in pricing_raw.get("pricing", []):
    if p.get("billing_type") == "per_token":
        pricing[p["model"]] = {
            "input": p.get("per_1m_input_tokens", 0),
            "output": p.get("per_1m_output_tokens", 0),
        }

# Collect text-to-text models from "auto" routing
auto = models_raw.get("auto", {})

anthropic_models = [m for m in auto.get("anthropic", []) if m["tag"] == "text-to-text"]
openai_models = [m for m in auto.get("openai", []) if m["tag"] == "text-to-text"]

lines = []
lines.append("# Available Models")
lines.append("")
lines.append(f"*Auto-generated from the [OpenGPU Relay API](https://relay.opengpu.network/v2/models) — last updated {datetime.date.today().isoformat()}*")
lines.append("")

# ── Anthropic ──
lines.append("## Anthropic Models (`relaygpu-anthropic`)")
lines.append("")
lines.append("Base URL: `https://relay.opengpu.network/v2/anthropic/v1/`")
lines.append("")
lines.append("| Model | ID | Input $/1M | Output $/1M |")
lines.append("|-------|----|-----------|------------|")

for m in anthropic_models:
    name = m["name"]
    key = f"anthropic.{name}"
    p = pricing.get(key, {"input": "—", "output": "—"})
    inp = f"${p['input']}" if isinstance(p['input'], (int, float)) else p['input']
    out = f"${p['output']}" if isinstance(p['output'], (int, float)) else p['output']
    lines.append(f"| **{name}** | `{name}` | {inp} | {out} |")

lines.append("")

# ── OpenAI-compatible ──
lines.append("## OpenAI-compatible Models (`relaygpu-openai`)")
lines.append("")
lines.append("Base URL: `https://relay.opengpu.network/v2/openai/v1/`")
lines.append("")
lines.append("| Model | ID | Input $/1M | Output $/1M |")
lines.append("|-------|----|-----------|------------|")

for m in openai_models:
    name = m["name"]
    key = f"openai.{name}"
    p = pricing.get(key, {"input": "—", "output": "—"})
    inp = f"${p['input']}" if isinstance(p['input'], (int, float)) else p['input']
    out = f"${p['output']}" if isinstance(p['output'], (int, float)) else p['output']
    lines.append(f"| **{name}** | `{name}` | {inp} | {out} |")

lines.append("")

# ── Usage ──
lines.append("## Switching Models")
lines.append("")
lines.append("In chat, use `/model`:")
lines.append("")
lines.append("```")
for m in anthropic_models:
    lines.append(f"/model relaygpu-anthropic/{m['name']}")
for m in openai_models:
    lines.append(f"/model relaygpu-openai/{m['name']}")
lines.append("```")
lines.append("")
lines.append("## Changing the Default")
lines.append("")
lines.append("Edit `~/.openclaw/openclaw.json`:")
lines.append("")
lines.append('```json')
lines.append('"agents": {')
lines.append('  "defaults": {')
lines.append('    "model": {')
lines.append('      "primary": "relaygpu-anthropic/anthropic/claude-opus-4-6"')
lines.append('    }')
lines.append('  }')
lines.append('}')
lines.append('```')
lines.append("")
lines.append("Then restart: `docker compose restart openclaw-gateway`")
lines.append("")
lines.append("## Pricing")
lines.append("")
lines.append("All pricing is pay-as-you-go via [relaygpu.com](https://relaygpu.com). No subscriptions.")
lines.append("")
lines.append("Live pricing: `curl https://relay.opengpu.network/v2/pricing`")

with open(out_path, "w") as f:
    f.write("\n".join(lines) + "\n")

print(f"Written to {out_path}")
print(f"  Anthropic models: {len(anthropic_models)}")
print(f"  OpenAI models:    {len(openai_models)}")
PYEOF

echo "Done ✓"
