#!/usr/bin/env bash
# P10k-style Claude Code status line
# Matches Powerlevel10k lean style: space-separated, Nerd Font icons, 256-color

set -euo pipefail

# ── 256-color palette (from ~/.p10k.zsh) ──────────────────────────
C_CYAN='\033[38;5;31m'      # dir → model name
C_BLUE='\033[38;5;39m'      # anchors → labels/icons
C_GREEN='\033[38;5;76m'     # clean/ok
C_YELLOW='\033[38;5;178m'   # modified/warning
C_RED='\033[38;5;196m'      # conflicted/error
C_OLIVE='\033[38;5;101m'    # exec time → cost & duration
C_PURPLE='\033[38;5;103m'   # shortened → secondary info
C_GRAY='\033[38;5;244m'     # stale/dim
C_RESET='\033[0m'

# ── Read JSON from stdin ──────────────────────────────────────────
JSON=$(cat)

# ── Parse fields with jq (defaults for missing values) ────────────
MODEL=$(echo "$JSON" | jq -r '.model.display_name // empty')
CTX_PCT=$(echo "$JSON" | jq -r '.context_window.used_percentage // empty')
COST=$(echo "$JSON" | jq -r '.cost.total_cost_usd // empty')
DURATION_MS=$(echo "$JSON" | jq -r '.cost.total_duration_ms // empty')
LINES_ADD=$(echo "$JSON" | jq -r '.cost.total_lines_added // empty')
LINES_DEL=$(echo "$JSON" | jq -r '.cost.total_lines_removed // empty')
CWD=$(echo "$JSON" | jq -r '.cwd // empty')

segments=()

# ── Model name ────────────────────────────────────────────────────
if [[ -n "$MODEL" ]]; then
  segments+=("${C_CYAN}${MODEL}${C_RESET}")
fi

# ── Git branch + status ───────────────────────────────────────────
if [[ -n "$CWD" && -d "$CWD" ]]; then
  BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || true)
  if [[ -n "$BRANCH" ]]; then
    DIRTY_COUNT=$(git -C "$CWD" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$DIRTY_COUNT" -gt 0 ]]; then
      segments+=("${C_YELLOW} ${BRANCH} !${DIRTY_COUNT}${C_RESET}")
    else
      segments+=("${C_GREEN} ${BRANCH}${C_RESET}")
    fi
  fi
fi

# ── Context window bar ────────────────────────────────────────────
if [[ -n "$CTX_PCT" ]]; then
  # Pick color by threshold
  if (( $(echo "$CTX_PCT >= 90" | bc -l) )); then
    BAR_COLOR="$C_RED"
  elif (( $(echo "$CTX_PCT >= 70" | bc -l) )); then
    BAR_COLOR="$C_YELLOW"
  else
    BAR_COLOR="$C_GREEN"
  fi

  # Build 10-char progress bar
  FILLED=$(echo "$CTX_PCT / 10" | bc)
  EMPTY=$((10 - FILLED))
  BAR=""
  for ((i = 0; i < FILLED; i++)); do BAR+="█"; done
  for ((i = 0; i < EMPTY; i++)); do BAR+="░"; done

  # Round percentage for display
  PCT_DISPLAY=$(printf '%.0f' "$CTX_PCT")
  segments+=("${BAR_COLOR}${BAR} ${PCT_DISPLAY}%${C_RESET}")
fi

# ── Cost ──────────────────────────────────────────────────────────
if [[ -n "$COST" ]]; then
  COST_FMT=$(printf '$%.2f' "$COST")
  segments+=("${C_OLIVE}${COST_FMT}${C_RESET}")
fi

# ── Duration ──────────────────────────────────────────────────────
if [[ -n "$DURATION_MS" ]]; then
  TOTAL_SEC=$((DURATION_MS / 1000))
  if ((TOTAL_SEC >= 60)); then
    MINS=$((TOTAL_SEC / 60))
    SECS=$((TOTAL_SEC % 60))
    DUR="${MINS}m ${SECS}s"
  else
    DUR="${TOTAL_SEC}s"
  fi
  segments+=("${C_OLIVE}${DUR}${C_RESET}")
fi

# ── Lines delta ───────────────────────────────────────────────────
DELTA_PARTS=()
if [[ -n "$LINES_ADD" && "$LINES_ADD" != "0" ]]; then
  DELTA_PARTS+=("${C_GREEN}+${LINES_ADD}${C_RESET}")
fi
if [[ -n "$LINES_DEL" && "$LINES_DEL" != "0" ]]; then
  DELTA_PARTS+=("${C_RED}-${LINES_DEL}${C_RESET}")
fi
if [[ ${#DELTA_PARTS[@]} -gt 0 ]]; then
  segments+=("$(IFS=' '; echo "${DELTA_PARTS[*]}")")
fi

# ── Output ────────────────────────────────────────────────────────
if [[ ${#segments[@]} -gt 0 ]]; then
  echo -e "${segments[*]}"
fi
