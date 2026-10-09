#!/usr/bin/env bash
set -euo pipefail
cd /workspace/Gem-Blast
export XDG_CONFIG_HOME=/workspace/.config
export XDG_CACHE_HOME=/workspace/.cache
export XDG_DATA_HOME=/workspace/.local/share
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
godot --version
godot --headless --path . --editor --import --quit
