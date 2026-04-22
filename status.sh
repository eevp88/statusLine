#!/bin/bash
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input"   | jq -r '.workspace.current_dir')
PCT=$(echo "$input"   | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input"  | jq -r '.cost.total_cost_usd // 0')
TOKENS_IN=$(echo "$input"  | jq -r '.context_window.total_input_tokens // 0')
TOKENS_OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
RATE_5H=$(echo "$input"      | jq -r '.rate_limits.five_hour.used_percentage // empty')
RATE_5H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
if [ -z "$BRANCH" ] && [ -d "$DIR/modules" ]; then
  LATEST_MOD=0; LATEST_DIR=""
  for moddir in "$DIR/modules"/*/; do
    [ -d "$moddir/.git" ] || continue
    mod_time=$(stat -c %Y "$moddir/.git/index" 2>/dev/null)
    [ "${mod_time:-0}" -gt "$LATEST_MOD" ] && LATEST_MOD="$mod_time" && LATEST_DIR="$moddir"
  done
  [ -n "$LATEST_DIR" ] && BRANCH=$(git -C "$LATEST_DIR" branch --show-current 2>/dev/null)
fi

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[1;38;2;0;230;255m'
PINK='\033[1;38;2;255;60;200m'
YELLOW='\033[1;38;2;255;220;0m'
PURPLE='\033[1;38;2;160;100;255m'
WHITE='\033[1;38;2;255;255;255m'
ORANGE='\033[1;38;2;255;150;30m'

if   [ "$PCT" -ge 85 ]; then BAR_COLOR='\033[1;38;2;255;60;60m'
elif [ "$PCT" -ge 60 ]; then BAR_COLOR='\033[1;38;2;255;180;0m'
else BAR_COLOR='\033[1;38;2;0;255;120m'; fi

if   [ "$PCT" -ge 90 ]; then ENGRAM_ALERT="\033[1;38;2;255;60;60m\033[5m 💾 GUARDÁ EN ENGRAM \033[0m"
elif [ "$PCT" -ge 75 ]; then ENGRAM_ALERT="\033[1;38;2;255;180;0m 💾 pronto compacta \033[0m"
else ENGRAM_ALERT=""; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"
COST_FMT=$(printf '$%.2f' "$COST")

RATE_SUFFIX=""
if [ -n "$RATE_5H" ]; then
  RATE_REM=$((100 - ${RATE_5H%.*}))
  RESET_IN=""
  if [ -n "$RATE_5H_RESET" ]; then
    NOW=$(date +%s)
    SECS_LEFT=$(( RATE_5H_RESET - NOW ))
    if [ "$SECS_LEFT" -gt 0 ]; then
      HRS=$(( SECS_LEFT / 3600 ))
      MINS=$(( (SECS_LEFT % 3600) / 60 ))
      RESET_IN=" en ${HRS}h ${MINS}m"
    else
      RESET_IN=" ahora"
    fi
  fi
  RATE_SUFFIX="    ${ORANGE}🚧 (100%% - ${RATE_5H%.*}%%) => ${RATE_REM}%%${RESET_IN}${RESET}"
fi

printf "${CYAN}[ ${MODEL} ]${RESET}    ${PINK}👤 ${USER}${RESET}    ${YELLOW}📁 ${DIR##*/}${RESET}    ${PURPLE}🌿 ${BRANCH}${RESET}    ${BAR_COLOR}🧠 ${BAR} ${PCT}%%${RESET}    ${PINK}↑${TOKENS_IN}${RESET} ${CYAN}↓${TOKENS_OUT}${RESET}    ${WHITE}${COST_FMT}${RESET}${RATE_SUFFIX}${ENGRAM_ALERT}\n"
