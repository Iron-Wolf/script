#!/usr/bin/env bash

# JDK : https://adoptium.net/fr
# Launcher : https://fabricmc.net/use/server/
# kill "$(cat mcserver.pid)"

# ================================================== #
#                  CONFIGURATION                     #
# ================================================== #
LOG_FILE="mcserver-$(date '+%Y-%m-%d').log"
JAVA_PATH="../java-adoptium/jdk-21.0.9+10/bin/java"
SERVER_JAR="fabric-server-launch.jar"
PID_FILE="mcserver.pid"

# values should match
MEMORY_OPTS=(
  -Xms8192M                              # initial memory
  -Xmx8192M                              # max memory
)

# Module
MODULE_OPTS=(
  --add-modules=jdk.incubator.vector     # performance gains on vector computations
)

# Use G1GC Garbage Collector (for Xmx <= 12G)
GC_OPTS=(
  -XX:+UseG1GC                           # low-latency Garbage-First (G1) GC, to optimize pause time
  -XX:+ParallelRefProcEnabled            # lets GC use multiple threads for weak reference checking
  -XX:MaxGCPauseMillis=200               # maximum amount of time the JVM can spend on GC
  -XX:+UnlockExperimentalVMOptions       # needed for some options
  -XX:+DisableExplicitGC                 # prevents bad plugin code from affecting the server
  -XX:+AlwaysPreTouch                    # preallocate all the memory at process start
  -XX:G1HeapWastePercent=5               # percentage of the heap that is wasted
  -XX:G1MixedGCCountTarget=4             # target number of mixed garbage collections
  -XX:InitiatingHeapOccupancyPercent=15  # percentage of heap used before triggering a mixed GC
  -XX:G1MixedGCLiveThresholdPercent=90   # percentage of live objects required to trigger a mixed GC
  -XX:G1RSetUpdatingPauseTimePercent=5   # percentage of time that is spent on updating the remembered set
  -XX:SurvivorRatio=32                   # ratio of the survivor space to the eden space
  -XX:+PerfDisableSharedMem              # disables shared memory
  -XX:MaxTenuringThreshold=1             # maximum tenuring threshold
  -XX:G1NewSizePercent=30                # percentage of the heap that is used for new objects
  -XX:G1MaxNewSizePercent=40             # maximum percentage of the heap that is used for new objects
  -XX:G1HeapRegionSize=8M                # size of the G1 heap region
  -XX:G1ReservePercent=20                # percentage of the heap that is reserved for G1
)

# Aikar flags
AIKAR_OPTS=(
  -Dusing.aikars.flags=https://mcflags.emc.gs
  -Daikars.new.flags=true
)


# ================================================== #
#                  START SCRIPT                      #
# ================================================== #
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if server is started
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  log "Serveur déjà en cours (PID $(cat "$PID_FILE"))"
  exit 0
fi

log "Démarrage du serveur..."
# nohup "$JAVA_PATH" -Xmx8G -jar "$SERVER_JAR" nogui >> "$LOG_FILE" 2>&1 &
#nohup "$JAVA_PATH" -Xmx8G -jar "$SERVER_JAR" nogui &
nohup "$JAVA_PATH" \
"${MEMORY_OPTS[@]}" \
"${MODULE_OPTS[@]}" \
"${GC_OPTS[@]}" \
"${AIKAR_OPTS[@]}" \
-jar "$SERVER_JAR" nogui &

PID=$!
echo "$PID" > "$PID_FILE"
sleep 1


if kill -0 "$PID" 2>/dev/null; then
  log "Serveur démarré avec PID = $PID"
else
  log "ERREUR : le serveur n'a pas réussi à démarrer"
  rm -f "$PID_FILE"
fi



