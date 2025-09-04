#!/bin/bash
# .claude/hooks/check-deps.sh
# Check dependencies when package.json is modified

set -e

HOOK_LOG=".claude/logs/hooks.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DEPS: $1" >> "$HOOK_LOG"
    echo "🔍 $1"
}

log "Checking dependencies after package.json change..."

# Check if package.json exists
if [[ ! -f "package.json" ]]; then
    log "No package.json found, skipping dependency check"
    exit 0
fi

# Install dependencies if node_modules is missing or package-lock.json is newer
if [[ ! -d "node_modules" ]] || [[ "package.json" -nt "node_modules" ]]; then
    log "Installing/updating dependencies..."
    if npm install; then
        log "✅ Dependencies installed successfully"
    else
        log "❌ Dependency installation failed"
        exit 1
    fi
fi

# Quick security audit (non-blocking)
log "Running security audit..."
if npm audit --audit-level=high 2>/dev/null; then
    log "✅ No high-severity vulnerabilities found"
else
    AUDIT_RESULT=$?
    if [[ $AUDIT_RESULT -eq 1 ]]; then
        log "⚠️ Security vulnerabilities found - run 'npm audit fix' to resolve"
        # Don't exit with error for vulnerabilities - just warn
    else
        log "⚠️ Could not run security audit"
    fi
fi

# Check for outdated packages (informational only)
log "Checking for outdated packages..."
OUTDATED_COUNT=$(npm outdated --parseable 2>/dev/null | wc -l | tr -d ' ')
if [[ "$OUTDATED_COUNT" -gt 0 ]]; then
    log "📦 $OUTDATED_COUNT packages have updates available"
    log "Run 'npm outdated' to see details"
else
    log "✅ All packages are up to date"
fi

# Validate package.json structure
log "Validating package.json structure..."
if node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" 2>/dev/null; then
    log "✅ package.json is valid JSON"
else
    log "❌ package.json has invalid JSON syntax"
    exit 1
fi

# Check for common issues
if grep -q '"main":.*"index.js"' package.json && [[ ! -f "index.js" ]]; then
    log "⚠️ package.json references index.js but file doesn't exist"
fi

if grep -q '"scripts"' package.json; then
    # Check if test script exists
    if ! grep -q '"test":.*".*"' package.json; then
        log "💡 Consider adding a test script to package.json"
    fi
    
    # Check if start script exists for apps
    if ! grep -q '"start":' package.json && [[ -f "src/index.js" || -f "src/app.js" ]]; then
        log "💡 Consider adding a start script to package.json"
    fi
fi

log "Dependency check completed"
exit 0