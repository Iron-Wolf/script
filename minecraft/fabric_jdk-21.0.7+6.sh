#!/bin/bash

# Some links : 
#  - https://github.com/YouHaveTrouble/minecraft-optimization
#  - https://github.com/TheUsefulLists/UsefulMods


# move in folder
cd fabric_jdk-21.0.7+6

# custom location
JAVA_PATH="../jdk-21.0.7+6/bin/java"

# values should match
MEMORY_OPTS=(
  -Xms8192M                              # initial memory
  -Xmx8192M                              # max memory
)

# Module
MODULE_OPTS=(
  --add-modules=jdk.incubator.vector     # performance gains on vector computations
)

# Garbage Collector (G1GC)
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

# main options
SERVER_JAR="fabric-server-mc.1.21.1-loader.0.16.14-launcher.1.0.3.jar"
SERVER_OPTS="--nogui"

# Exec
"$JAVA_PATH" \
"${MEMORY_OPTS[@]}" \
"${MODULE_OPTS[@]}" \
"${GC_OPTS[@]}" \
"${AIKAR_OPTS[@]}" \
-jar $SERVER_JAR $SERVER_OPTS


