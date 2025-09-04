#!/bin/bash
# .claude/hooks/log-session.sh
# Log user prompts and session activity

set -e

HOOK_LOG=".claude/logs/hooks.log"
ACTIVITY_LOG=".claude/logs/activity.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOGGER: $1" >> "$HOOK_LOG"
}

activity_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ACTIVITY_LOG"
}

# Log the session activity (this runs on every prompt)
activity_log "User prompt received"

# Track some basic statistics (only on first run of the day)
STATS_FILE=".claude/logs/stats-$(date '+%Y-%m-%d').json"

if [[ ! -f "$STATS_FILE" ]]; then
    # Initialize daily stats
    cat > "$STATS_FILE" << EOF
{
  "date": "$(date '+%Y-%m-%d')",
  "session_start": "$(date --iso-8601=seconds)",
  "prompts": 0,
  "project": "$(basename "$(pwd)")",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'not-git')"
}
EOF
    activity_log "=== New Claude Code Session Started ==="
    activity_log "Project: $(basename "$(pwd)")"
    if git rev-parse --git-dir >/dev/null 2>&1; then
        activity_log "Git branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    fi
    log "Daily stats initialized"
fi

# Increment prompt counter (simple approach)
if command -v node >/dev/null 2>&1; then
    node -e "
        const fs = require('fs');
        try {
            const stats = JSON.parse(fs.readFileSync('$STATS_FILE', 'utf8'));
            stats.prompts = (stats.prompts || 0) + 1;
            stats.last_prompt = new Date().toISOString();
            fs.writeFileSync('$STATS_FILE', JSON.stringify(stats, null, 2));
        } catch (e) {
            // Ignore errors
        }
    " 2>/dev/null || true
fi

# Quick project context check (only log interesting changes)
if [[ -f "package.json" ]]; then
    # Check if package.json was modified recently (within last minute)
    if [[ $(find package.json -mmin -1 2>/dev/null | wc -l) -gt 0 ]]; then
        activity_log "📦 package.json recently modified"
        log "Package.json change detected"
    fi
fi

# Check if we're in a git repo and log any recent commits
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Check for commits in the last hour
    RECENT_COMMITS=$(git log --since="1 hour ago" --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$RECENT_COMMITS" -gt 0 ]] && [[ ! -f ".claude/logs/.last-commit-logged-$(date '+%Y-%m-%d-%H')" ]]; then
        activity_log "📝 $RECENT_COMMITS recent commits found"
        touch ".claude/logs/.last-commit-logged-$(date '+%Y-%m-%d-%H')"
        log "Recent commits logged"
    fi
fi

log "Session activity logged"

# Keep activity log manageable (last 200 lines)
if [[ $(wc -l < "$ACTIVITY_LOG" 2>/dev/null || echo 0) -gt 200 ]]; then
    tail -n 100 "$ACTIVITY_LOG" > "$ACTIVITY_LOG.tmp" && mv "$ACTIVITY_LOG.tmp" "$ACTIVITY_LOG"
    log "Activity log rotated"
fi

exit 0