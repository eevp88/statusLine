#!/bin/bash
input=$(cat)
IFS=$'\t' read -r MODEL DIR PCT COST TOKENS_IN TOKENS_OUT RATE_5H RATE_5H_RESET < <(
  echo "$input" | jq -r '[
    .model.display_name,
    .workspace.current_dir,
    (.context_window.used_percentage // 0 | floor | tostring),
    (.cost.total_cost_usd // 0 | tostring),
    (.context_window.total_input_tokens // 0 | tostring),
    (.context_window.total_output_tokens // 0 | tostring),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // "")
  ] | @tsv'
)
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

CONF="${HOME}/.claude/statusline.conf"
[ -f "$CONF" ] && source "$CONF"
: "${SHOW_MODEL:=1}" "${SHOW_USER:=1}" "${SHOW_DIR:=1}" "${SHOW_BRANCH:=1}"
: "${SHOW_CONTEXT:=1}" "${SHOW_TOKENS:=1}" "${SHOW_COST:=1}"
: "${SHOW_RATE:=1}" "${SHOW_ALERTS:=1}"

RESET='\033[0m'
CYAN='\033[1;38;2;0;230;255m'
PINK='\033[1;38;2;255;60;200m'
YELLOW='\033[1;38;2;255;220;0m'
PURPLE='\033[1;38;2;160;100;255m'
WHITE='\033[1;38;2;255;255;255m'
ORANGE='\033[1;38;2;255;150;30m'

if   [ "$PCT" -ge 80 ]; then BAR_COLOR='\033[1;38;2;255;60;60m'
elif [ "$PCT" -ge 60 ]; then BAR_COLOR='\033[1;38;2;255;180;0m'
else BAR_COLOR='\033[1;38;2;0;255;120m'; fi

ALERT_TEXT=""
if [ "$SHOW_ALERTS" = "1" ]; then
  if   [ "$PCT" -ge 80 ]; then ALERT_TEXT="\033[1;38;2;255;60;60m\033[5m 💾 GUARDÁ EL CONTEXTO \033[0m"
  elif [ "$PCT" -ge 60 ]; then ALERT_TEXT="\033[1;38;2;255;180;0m 💾 contexto casi lleno \033[0m"
  fi
fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"
COST_FMT=$(printf '$%.2f' "$COST")

RATE_TEXT=""
if [ "$SHOW_RATE" = "1" ] && [ -n "$RATE_5H" ]; then
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
  RATE_TEXT="${ORANGE}🚧 (100%% - ${RATE_5H%.*}%%) => ${RATE_REM}%%${RESET_IN}${RESET}"
fi

SEP="    "
OUT=""
_add() { [ -n "$OUT" ] && OUT+="$SEP"; OUT+="$1"; }

[ "$SHOW_MODEL"   = "1" ] && _add "${CYAN}[ ${MODEL} ]${RESET}"
[ "$SHOW_USER"    = "1" ] && _add "${PINK}👤 ${USER}${RESET}"
[ "$SHOW_DIR"     = "1" ] && _add "${YELLOW}📁 ${DIR##*/}${RESET}"
[ "$SHOW_BRANCH"  = "1" ] && _add "${PURPLE}🌿 ${BRANCH}${RESET}"
[ "$SHOW_CONTEXT" = "1" ] && _add "${BAR_COLOR}🧠 ${BAR} ${PCT}%%${RESET}"
[ "$SHOW_TOKENS"  = "1" ] && _add "${PINK}↑${TOKENS_IN}${RESET} ${CYAN}↓${TOKENS_OUT}${RESET}"
[ "$SHOW_COST"    = "1" ] && _add "${WHITE}${COST_FMT}${RESET}"
[ -n "$RATE_TEXT"  ]      && _add "$RATE_TEXT"
[ -n "$ALERT_TEXT" ]      && _add "$ALERT_TEXT"

printf "${OUT}\n"
