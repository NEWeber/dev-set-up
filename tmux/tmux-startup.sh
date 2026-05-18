#!/bin/bash

set -euo pipefail

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is not installed or not on PATH"
  exit 1
fi

SESSION_CONFIG="${TMUX_STARTUP_CONFIG:-$HOME/code/tmux-startup.config.sh}"

if [[ ! -f "${SESSION_CONFIG}" ]]; then
  echo "Missing tmux startup config at ${SESSION_CONFIG}"
  echo "Create it from tmux-startup.config.example.sh"
  exit 1
fi

# shellcheck source=/dev/null
source "${SESSION_CONFIG}"

if [[ -z "${SESSION:-}" ]]; then
  echo "SESSION must be set in ${SESSION_CONFIG}"
  exit 1
fi

if ! declare -F bootstrap_session >/dev/null; then
  echo "bootstrap_session() must be defined in ${SESSION_CONFIG}"
  exit 1
fi

tmux has-session -t "${SESSION}" 2>/dev/null || bootstrap_session

tmux attach-session -t "${SESSION}"
