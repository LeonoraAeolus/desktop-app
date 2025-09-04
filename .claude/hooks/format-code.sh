#!/bin/bash
# .claude/hooks/format-code.sh
# Auto-format JavaScript/TypeScript files after Claude writes them

set -e

FILE="$1"
HOOK_LOG=".claude/logs/hooks.log"

# Create logs directory if it doesn't exist
mkdir -p "$(dirname "$HOOK_LOG")"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] FORMAT: $1" >> "$HOOK_LOG"
}

# Check if file exists and is a JS/TS file
if [[ ! -f "$FILE" ]]; then
    log "File not found: $FILE"
    exit 0
fi

if [[ ! "$FILE" =~ \.(js|ts|jsx|tsx)$ ]]; then
    log "Skipping non-JS/TS file: $FILE"
    exit 0
fi

log "Formatting file: $FILE"

# Try Prettier first (most common)
if command -v npx >/dev/null 2>&1 && [ -f "package.json" ]; then
    # Check if prettier is in package.json
    if grep -q "prettier" package.json 2>/dev/null; then
        log "Running Prettier on $FILE"
        if npx prettier --write "$FILE" 2>/dev/null; then
            log "✅ Prettier formatting successful"
            # Stage the formatted file if we're in a git repo
            if git rev-parse --git-dir >/dev/null 2>&1; then
                git add "$FILE" 2>/dev/null || true
                log "Staged formatted file: $FILE"
            fi
            exit 0
        else
            log "⚠️ Prettier failed, trying alternatives"
        fi
    fi
fi

# Try ESLint with --fix
if command -v npx >/dev/null 2>&1 && [ -f ".eslintrc.*" -o -f "eslint.config.*" ]; then
    log "Running ESLint --fix on $FILE"
    if npx eslint --fix "$FILE" 2>/dev/null; then
        log "✅ ESLint fix successful"
        if git rev-parse --git-dir >/dev/null 2>&1; then
            git add "$FILE" 2>/dev/null || true
            log "Staged fixed file: $FILE"
        fi
        exit 0
    else
        log "⚠️ ESLint fix had issues (may still be partially successful)"
    fi
fi

# Basic syntax check
if command -v node >/dev/null 2>&1; then
    if [[ "$FILE" =~ \.js$ ]]; then
        if node -c "$FILE" 2>/dev/null; then
            log "✅ JavaScript syntax check passed"
        else
            log "❌ JavaScript syntax errors detected in $FILE"
            exit 1
        fi
    fi
fi

log "No formatting tools available or file already formatted"
exit 0