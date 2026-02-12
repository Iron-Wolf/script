#!/bin/bash

PID=$1
INTERVAL=5
HISTORY=40   # nombre de points affichés

if [ -z "$PID" ]; then
  echo "Usage: $0 <pid>"
  exit 1
fi

# Buffers historiques
declare -a USED_HISTORY
declare -a MAX_HISTORY
declare -a EDEN_HISTORY
declare -a SURVIVOR_HISTORY
declare -a OLD_HISTORY
declare -a META_HISTORY

function extract_value() {
  echo "$1" | grep "$2" | awk -F'=' '{print $2}' | awk '{print $1}'
}

function collect_metrics() {

  OUTPUT=$(jhsdb jmap --pid $PID --heap 2>/dev/null)

  # Heap total
  USED=$(echo "$OUTPUT" | grep "used =" | head -n 1 | awk '{print $3}')
  MAX=$(echo "$OUTPUT" | grep "MaxHeapSize" | awk '{print $3}')

  # Espaces mémoire (selon format JDK)
  EDEN=$(echo "$OUTPUT" | grep "Eden Space" -A4 | grep "used =" | awk '{print $3}')
  SURVIVOR=$(echo "$OUTPUT" | grep "Survivor Space" -A4 | grep "used =" | awk '{print $3}' | head -n 1)
  OLD=$(echo "$OUTPUT" | grep "Old Space" -A4 | grep "used =" | awk '{print $3}')
  META=$(echo "$OUTPUT" | grep "Metaspace" -A4 | grep "used =" | awk '{print $3}')

  USED_HISTORY+=($USED)
  MAX_HISTORY+=($MAX)
  EDEN_HISTORY+=(${EDEN:-0})
  SURVIVOR_HISTORY+=(${SURVIVOR:-0})
  OLD_HISTORY+=(${OLD:-0})
  META_HISTORY+=(${META:-0})

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

function draw_graph() {

  clear

  echo "JVM PID: $PID"
  echo "Interval: ${INTERVAL}s"
  echo ""

  CURRENT_USED=${USED_HISTORY[-1]}
  CURRENT_MAX=${MAX_HISTORY[-1]}
  PERCENT=$((100 * CURRENT_USED / CURRENT_MAX))

  echo "Heap Used: $((CURRENT_USED/1024/1024)) MB / $((CURRENT_MAX/1024/1024)) MB ($PERCENT%)"
  echo ""

  draw_series "TOTAL" "${USED_HISTORY[@]}" "$CURRENT_MAX"
  draw_series "EDEN" "${EDEN_HISTORY[@]}" "$CURRENT_MAX"
  draw_series "SURV" "${SURVIVOR_HISTORY[@]}" "$CURRENT_MAX"
  draw_series "OLD " "${OLD_HISTORY[@]}" "$CURRENT_MAX"
  draw_series "META" "${META_HISTORY[@]}" "$CURRENT_MAX"
}

function draw_series() {

  NAME=$1
  shift
  DATA=("$@")
  SCALE=$CURRENT_MAX

  printf "%-6s |" "$NAME"

  for value in "${DATA[@]}"; do
    HEIGHT=$((value * 20 / SCALE))
    if [ "$HEIGHT" -gt 20 ]; then HEIGHT=20; fi
    printf "%0.s#" $(seq 1 $HEIGHT)
    printf "."
  done

  echo ""
}

while true; do
  collect_metrics
  draw_graph
  sleep $INTERVAL
done
