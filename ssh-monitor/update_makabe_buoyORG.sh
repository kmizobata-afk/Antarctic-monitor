#!/bin/bash
set -e

REPO="$HOME/work/Antarctic-monitor"
LOG="$REPO/push.log"

cd "$REPO" || exit 1

echo "=== GitHub update started: $(date -u '+%Y-%m-%d %H:%M UTC') ===" >> "$LOG"
sleep 240

# 必ず最新生成物をステージ
git add makabe-buoy/MakabeBuoy_latest.png makabe-buoy/buoy_track.csv

# 変更がなくても commit
git commit --allow-empty -m "Auto update Makabe buoy ($(date -u '+%H:%M UTC'))" >> "$LOG" 2>&1

# 履歴競合を無視して強制 push（←ここが肝）
git push --force origin main >> "$LOG" 2>&1 || echo "git push failed" >> "$LOG"

echo "=== GitHub update finished ===" >> "$LOG"

