#!/usr/bin/env python3
"""Build a Codex model catalog for LiteLLM proxy model aliases."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "codex_litellm_models.json"

MODELS = [
    ("free-auto", "Free Auto (LiteLLM)", "Free routing: domestic free APIs → OpenRouter free → local Ollama."),
    ("sf-deepseek-r1", "SiliconFlow DeepSeek R1 Distill", "Domestic free/credit routing via SiliconFlow."),
    ("sf-qwen2.5-72b", "SiliconFlow Qwen2.5 72B", "Domestic free/credit routing via SiliconFlow."),
    ("glm-4-flash", "GLM-4 Flash", "Zhipu free model."),
    ("glm-4.7-flash", "GLM-4.7 Flash", "Zhipu free model."),
    ("qwen3-coder-free", "Qwen3 Coder Free", "OpenRouter free model."),
    ("nemotron-ultra-free", "Nemotron Ultra Free", "OpenRouter free model."),
    ("gpt-oss-120b-free", "GPT OSS 120B Free", "OpenRouter free model."),
    ("gemma4-free", "Gemma 4 Free", "OpenRouter free model."),
    ("llama3.3-70b-free", "Llama 3.3 70B Free", "OpenRouter free model."),
    ("gpt-5.5", "GPT-5.5 via LiteLLM", "Paid model via LiteLLM."),
    ("claude-sonnet", "Claude Sonnet via LiteLLM", "Paid model via OpenRouter."),
    ("claude-opus", "Claude Opus via LiteLLM", "Paid model via OpenRouter."),
    ("claude-haiku", "Claude Haiku via LiteLLM", "Paid model via OpenRouter."),
    ("gemini-flash", "Gemini Flash via LiteLLM", "Paid model via OpenRouter."),
    ("gemini-pro", "Gemini Pro via LiteLLM", "Paid model via OpenRouter."),
    ("llama4-maverick", "Llama 4 Maverick via LiteLLM", "Paid model via OpenRouter."),
]

COPIED_FIELDS = [
    "base_instructions",
    "model_messages",
    "default_reasoning_level",
    "supported_reasoning_levels",
    "shell_type",
    "visibility",
    "supported_in_api",
    "supports_reasoning_summaries",
    "default_reasoning_summary",
    "support_verbosity",
    "default_verbosity",
    "apply_patch_tool_type",
    "web_search_tool_type",
    "truncation_policy",
    "supports_parallel_tool_calls",
    "supports_image_detail_original",
    "context_window",
    "max_context_window",
    "effective_context_window_percent",
    "experimental_supported_tools",
    "input_modalities",
    "supports_search_tool",
]


def load_base_model() -> dict:
    raw = subprocess.check_output(["codex", "debug", "models"], text=True)
    models = json.loads(raw).get("models") or []
    if not models:
        raise RuntimeError("codex debug models returned no models")
    return models[0]


def build_model(base: dict, slug: str, display_name: str, description: str, priority: int) -> dict:
    model = {key: base[key] for key in COPIED_FIELDS if key in base}
    model.update(
        {
            "slug": slug,
            "display_name": display_name,
            "description": description,
            "priority": priority,
            "supports_reasoning_summaries": False,
            "supports_parallel_tool_calls": False,
            "supports_image_detail_original": False,
            "input_modalities": ["text"],
            "supports_search_tool": False,
            "context_window": 32768,
            "max_context_window": 32768,
            "effective_context_window_percent": 85,
        }
    )
    return model


def main() -> int:
    base = load_base_model()
    catalog = {
        "models": [
            build_model(base, slug, display_name, description, priority)
            for priority, (slug, display_name, description) in enumerate(MODELS, start=10)
        ]
    }
    OUTPUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n")
    print(OUTPUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
