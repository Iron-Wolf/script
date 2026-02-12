#!/usr/bin/env bash

PID="$1"

if [ -z "$PID" ]; then
  echo "Usage: $0 <PID>"
  exit 1
fi

JCMD="./java-adoptium/jdk-21.0.9+10/bin/jcmd"
CMD="$JCMD $PID GC.heap_info"

HISTORY_FILE="/tmp/java_heap_${PID}.hist"
MAX_POINTS=30

draw_bar() {
  local percent=$1
  local width=30
  local filled=$((percent * width / 100))
  local empty=$((width - filled))

  printf "["
  printf "%0.s#" $(seq 1 $filled)
  printf "%0.s-" $(seq 1 $empty)
  printf "] %3d%%" "$percent"
}

sparkline() {
  local values=("$@")
  local chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

  for v in "${values[@]}"; do
    idx=$((v * 7 / 100))
    printf "%s" "${chars[$idx]}"
  done
}

OUTPUT=$($CMD 2>/dev/null)

TOTAL_K=$(echo "$OUTPUT" | awk '/garbage-first heap/ {gsub(/K,?/,"",$4); print $4}')
USED_K=$(echo "$OUTPUT"  | awk '/garbage-first heap/ {gsub(/K,?/,"",$6); print $6}')
YOUNG_K=$(echo "$OUTPUT" | awk -F'[()]' '/young/ {gsub(/K/,"",$2); print $2}')
META_USED_K=$(echo "$OUTPUT"  | awk '/Metaspace/ {gsub(/K,?/,"",$3); print $3}')
META_COMMIT_K=$(echo "$OUTPUT" | awk '/Metaspace/ {gsub(/K,?/,"",$5); print $5}')

TOTAL_K=${TOTAL_K:-1}
USED_K=${USED_K:-0}
YOUNG_K=${YOUNG_K:-0}
META_USED_K=${META_USED_K:-0}
META_COMMIT_K=${META_COMMIT_K:-1}

HEAP_PERCENT=$((USED_K * 100 / TOTAL_K))
YOUNG_PERCENT=$((YOUNG_K * 100 / TOTAL_K))
META_PERCENT=$((META_USED_K * 100 / META_COMMIT_K))

TOTAL_MB=$((TOTAL_K / 1024))
USED_MB=$((USED_K / 1024))
YOUNG_MB=$((YOUNG_K / 1024))
META_MB=$((META_USED_K / 1024))
META_COMMIT_MB=$((META_COMMIT_K / 1024))

# =============================
# Historique Heap %
# =============================

echo "$HEAP_PERCENT" >> "$HISTORY_FILE"
tail -n $MAX_POINTS "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

mapfile -t HISTORY < "$HISTORY_FILE"

# =============================
# Affichage
# =============================

echo "Command executed:"
echo "$CMD"
echo
echo "Timestamp: $(date +"%Y-%m-%d %H:%M:%S")"
echo "PID: $PID"
echo "============================================================"
echo

printf "Heap Used     : %4d MB / %4d MB  " "$USED_MB" "$TOTAL_MB"
draw_bar $HEAP_PERCENT
echo

printf "Young Gen     : %4d MB            " "$YOUNG_MB"
draw_bar $YOUNG_PERCENT
echo

printf "Metaspace     : %4d MB / %4d MB  " "$META_MB" "$META_COMMIT_MB"
draw_bar $META_PERCENT
echo
echo
echo "Heap Trend (last $MAX_POINTS samples)"
sparkline "${HISTORY[@]}"
echo
