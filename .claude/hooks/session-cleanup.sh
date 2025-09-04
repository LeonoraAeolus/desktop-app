#!/bin/bash
# .claude/hooks/session-cleanup.sh
# Clean up and log session end

set -e

HOOK_LOG=".claude/logs/hooks.log"
SESSION_LOG=".claude/logs/sessions.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CLEANUP: $1" >> "$HOOK_LOG"
}

session_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$SESSION_LOG"
}

log "Session cleanup started"
session_log "=== Claude Code Session Ended ==="

# Clean up temporary files
if [[ -d ".tmp" ]]; then
    log "Cleaning up .tmp directory"
    rm -rf .tmp 2>/dev/null || true
fi

# Clean up any .DS_Store files (macOS)
if command -v find >/dev/null 2>&1; then
    DSSTORE_COUNT=$(find . -name ".DS_Store" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$DSSTORE_COUNT" -gt 0 ]]; then
        log "Removing $DSSTORE_COUNT .DS_Store files"
        find . -name ".DS_Store" -type f -delete 2>/dev/null || true
    fi
fi

# Log session statistics
if [[ -f "$HOOK_LOG" ]]; then
    SESSION_COMMANDS=$(grep -c "$(date '+%Y-%m-%d')" "$HOOK_LOG" 2>/dev/null || echo "0")
    session_log "Commands executed today: $SESSION_COMMANDS"
fi

# Check git status and remind about uncommitted changes
if git rev-parse --git-dir >/dev/null 2>&1; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$UNCOMMITTED" -gt 0 ]]; then
        session_log "⚠️ $UNCOMMITTED uncommitted changes remaining"
        log "Reminder: $UNCOMMITTED files have uncommitted changes"
    else
        session_log "✅ Working directory clean"
        log "Working directory is clean"
    fi
    
    # Log current branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    session_log "Current branch: $CURRENT_BRANCH"
fi

# Rotate logs if they're getting large (keep last 1000 lines)
rotate_log() {
    local logfile="$1"
    if [[ -f "$logfile" ]] && [[ $(wc -l < "$logfile") -gt 1000 ]]; then
        tail -n 500 "$logfile" > "$logfile.tmp" && mv "$logfile.tmp" "$logfile"
        log "Rotated log file: $logfile"
    fi
}

rotate_log "$HOOK_LOG"
rotate_log "$SESSION_LOG"

# Generate a simple daily summary
SUMMARY_FILE=".claude/logs/daily-summary-$(date '+%Y-%m-%d').log"
if [[ ! -f "$SUMMARY_FILE" ]]; then
    {
        echo "Daily Summary - $(date '+%Y-%m-%d')"
        echo "================================"
        echo "Project: $(basename "$(pwd)")"
        echo "Started: $(date)"
        if git rev-parse --git-dir >/dev/null 2>&1; then
            echo "Git branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
            echo "Git status: $(git status --porcelain | wc -l | tr -d ' ') uncommitted files"
        fi
        if [[ -f "package.json" ]]; then
            echo "Node project: $(node -e "console.log(JSON.parse(require('fs').readFileSync('package.json', 'utf8')).name || 'unnamed')" 2>/dev/null)"
        fi
        echo ""
    } > "$SUMMARY_FILE"
fi

log "Session cleanup completed"
session_log "Session cleanup completed at $(date)"

exit 0