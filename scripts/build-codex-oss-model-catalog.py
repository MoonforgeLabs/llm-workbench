#!/usr/bin/env python3
"""Build a small Codex model catalog for local Ollama models.

Codex needs model metadata for non-OpenAI model names. When an Ollama model is
missing from the catalog, Codex falls back to generic metadata and prints:
"Model metadata ... not found". This script copies the required instruction
fields from the installed Codex catalog and emits local Ollama model entries.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "codex_oss_models.json"

MODELS = [
    ("qwen3-coder:30b", "Qwen3 Coder 30B (Ollama)", 32768),
    ("qwen3-coder", "Qwen3 Coder (Ollama)", 32768),
    ("ornith:35b", "Ornith 35B (Ollama)", 32768),
    ("deepseek-r1", "DeepSeek R1 (Ollama)", 32768),
    ("deepseek-r1:32b", "DeepSeek R1 32B (Ollama)", 32768),
    ("qwen3", "Qwen3 (Ollama)", 32768),
    ("qwen3.6", "Qwen3.6 (Ollama)", 32768),
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
    catalog = json.loads(raw)
    models = catalog.get("models") or []
    if not models:
        raise RuntimeError("codex debug models returned no models")
    return models[0]


def build_model(base: dict, slug: str, display_name: str, context_window: int, priority: int) -> dict:
    model = {key: base[key] for key in COPIED_FIELDS if key in base}
    model.update(
        {
            "slug": slug,
            "display_name": display_name,
            "description": "Local Ollama model for Codex OSS mode.",
            "priority": priority,
            "supports_reasoning_summaries": False,
            "supports_parallel_tool_calls": False,
            "supports_image_detail_original": False,
            "input_modalities": ["text"],
            "supports_search_tool": False,
            "context_window": context_window,
            "max_context_window": context_window,
            "effective_context_window_percent": 85,
        }
    )
    return model


def main() -> int:
    base = load_base_model()
    catalog = {
        "models": [
            build_model(base, slug, display_name, context_window, priority)
            for priority, (slug, display_name, context_window) in enumerate(MODELS, start=20)
        ]
    }
    OUTPUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n")
    print(OUTPUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
