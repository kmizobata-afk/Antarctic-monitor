#!/bin/bash
set -e

REPO="$HOME/work/Antarctic-monitor"
LOG="$REPO/push.log"

PNG="$REPO/makabe-buoy/MakabeBuoy_latest.png"
CSV="$REPO/makabe-buoy/buoy_track.csv"

cd "$REPO" || exit 1

echo "=== GitHub update started: $(date -u '+%Y-%m-%d %H:%M UTC') ===" >> "$LOG"

# ---------- ここが肝 ----------
# PNG / CSV が「2分以内に更新されたか」を最大5分待つ
MAX_WAIT=300   # 秒
INTERVAL=10
WAITED=0

while true; do
  NOW=$(date +%s)
  PNG_TIME=$(stat -f %m "$PNG")
  CSV_TIME=$(stat -f %m "$CSV")

  if (( NOW - PNG_TIME < 120 && NOW - CSV_TIME < 120 )); then
    echo "Detected fresh PNG/CSV, proceeding." >> "$LOG"
    break
  fi

  if (( WAITED >= MAX_WAIT )); then
    echo "Timeout waiting for fresh PNG/CSV, proceeding anyway." >> "$LOG"
    break
  fi

  sleep $INTERVAL
  WAITED=$((WAITED + INTERVAL))
done
# --------------------------------

git add makabe-buoy/MakabeBuoy_latest.png makabe-buoy/buoy_track.csv index.html makabe-buoy/index.html

git commit --allow-empty \
  -m "Auto update Makabe buoy ($(date -u '+%H:%M UTC'))" \
  >> "$LOG" 2>&1

git push --force origin main >> "$LOG" 2>&1 || echo "git push failed" >> "$LOG"

echo "=== GitHub update finished ===" >> "$LOG"

