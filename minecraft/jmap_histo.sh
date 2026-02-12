#!/bin/bash

PID=$1
INTERVAL=5
HISTORY=40

if [ -z "$PID" ]; then
  echo "Usage: $0 <pid>"
  exit 1
fi

declare -a USED_HISTORY
declare -a MAX_HISTORY
declare -a EDEN_HISTORY
declare -a SURVIVOR_HISTORY
declare -a OLD_HISTORY
declare -a META_HISTORY

get_last() {
  local arr=("$@")
  local size=${#arr[@]}
  if [ $size -eq 0 ]; then
    echo 0
  else
    echo "${arr[$((size-1))]}"
  fi
}

collect_metrics() {

  OUTPUT=$(jhsdb jmap --pid "$PID" --heap 2>/dev/null)

  if [ -z "$OUTPUT" ]; then
    return
  fi

  # Heap used (première occurrence)
  USED=$(echo "$OUTPUT" | grep -m1 "used =" | awk '{print $3}')

  # Max heap (MaxHeapSize)
  MAX=$(echo "$OUTPUT" | grep "MaxHeapSize" | awk '{print $3}')

  # Fallback si parsing échoue
  USED=${USED:-0}
  MAX=${MAX:-0}

  # Espaces mémoire (tolérant aux variations JDK)
  EDEN=$(echo "$OUTPUT" | awk '/Eden Space/{f=1} f && /used =/{print $3; f=0}')
  SURVIVOR=$(echo "$OUTPUT" | awk '/Survivor Space/{f=1} f && /used =/{print $3; f=0}')
  OLD=$(echo "$OUTPUT" | awk '/Old Space/{f=1} f && /used =/{print $3; f=0}')
  META=$(echo "$OUTPUT" | awk '/Metaspace/{f=1} f && /used =/{print $3; f=0}')

  EDEN=${EDEN:-0}
  SURVIVOR=${SURVIVOR:-0}
  OLD=${OLD:-0}
  META=${META:-0}

  # Ignore si MAX invalide
  if ! [[ "$MAX" =~ ^[0-9]+$ ]] || [ "$MAX" -eq 0 ]; then
    return
  fi

  USED_HISTORY+=($USED)
  MAX_HISTORY+=($MAX)
  EDEN_HISTORY+=($EDEN)
  SURVIVOR_HISTORY+=($SURVIVOR)
  OLD_HISTORY+=($OLD)
  META_HISTORY+=($META)

  # Trim historique
  if [ ${#USED_HISTORY[@]} -gt $HISTORY ]; then
    USED_HISTORY=("${USED_HISTORY[@]:1}")
    MAX_HISTORY=("${MAX_HISTORY[@]:1}")
    EDEN_HISTORY=("${EDEN_HISTORY[@]:1}")
    SURVIVOR_HISTORY=("${SURVIVOR_HISTORY[@]:1}")
    OLD_HISTORY=("${OLD_HISTORY[@]:1}")
    META_HISTORY=("${META_HISTORY[@]:1}")
  fi
}

draw_series() {

  local name=$1
  shift
  local data=("$@")

  local current_max=$(get_last "${MAX_HISTORY[@]}")
  [ "$current_max" -eq 0 ] && return

  printf "%-6s |" "$name"

  for value in "${data[@]}"; do
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
      value=0
    fi
    height=$((value * 20 / current_max))
    [ "$height" -gt 20 ] && height=20

    for ((i=0;i<height;i++)); do printf "#"; done
    printf "."
  done
  echo ""
}

draw_graph() {

  clear

  CURRENT_USED=$(get_last "${USED_HISTORY[@]}")
  CURRENT_MAX=$(get_last "${MAX_HISTORY[@]}")

  if [ "$CURRENT_MAX" -eq 0 ]; then
    echo "Collecting data..."
    return
  fi

  PERCENT=$((100 * CURRENT_USED / CURRENT_MAX))

  echo "JVM PID: $PID"
  echo "Interval: ${INTERVAL}s"
  echo ""
  echo "Heap Used: $((CURRENT_USED/1024/1024)) MB / $((CURRENT_MAX/1024/1024)) MB ($PERCENT%)"
  echo ""

  draw_series "TOTAL" "${USED_HISTORY[@]}"
  draw_series "EDEN"  "${EDEN_HISTORY[@]}"
  draw_series "SURV"  "${SURVIVOR_HISTORY[@]}"
  draw_series "OLD"   "${OLD_HISTORY[@]}"
  draw_series "META"  "${META_HISTORY[@]}"
}

while true; do
  collect_metrics
  draw_graph
  sleep "$INTERVAL"
done
