#!/usr/bin/env bash

# JDK : https://adoptium.net/fr
# Launcher : https://fabricmc.net/use/server/
# kill "$(cat mcserver.pid)"

LOG_FILE="mcserver-$(date '+%Y-%m-%d').log"
JAVA_CMD="../java-adoptium/jdk-21.0.9+10/bin/java"
JAR="fabric-server-launch.jar"
PID_FILE="mcserver.pid"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Vérifie si le serveur est déjà lancé
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  log "Serveur déjà en cours (PID $(cat "$PID_FILE"))"
  exit 0
fi

log "Démarrage du serveur Minecraft"
# nohup "$JAVA_CMD" -Xmx8G -jar "$JAR" nogui >> "$LOG_FILE" 2>&1 &
nohup "$JAVA_CMD" -Xmx8G -jar "$JAR" nogui &
PID=$!
echo "$PID" > "$PID_FILE"
sleep 1

if kill -0 "$PID" 2>/dev/null; then
  log "Serveur démarré avec succès (PID $PID)"
else
  log "ERREUR : le serveur n'a pas réussi à démarrer"
  rm -f "$PID_FILE"
fi



