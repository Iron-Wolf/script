#!/usr/bin/env bash

# JDK : https://adoptium.net/fr
# Launcher : https://fabricmc.net/use/server/
# kill "$(cat mcserver.pid)"

LOG_FILE="mcserver-$(date '+%Y-%m-%d').log"
JAVA_CMD="./openjdk_25/jdk-25.0.2+10/bin/java"
JAR="fabric-server-mc.1.21.11-loader.0.18.4-launcher.1.1.1.jar"
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



