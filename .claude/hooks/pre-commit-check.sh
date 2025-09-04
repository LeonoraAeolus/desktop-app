#!/bin/bash
# .claude/hooks/pre-commit-check.sh
# Run checks before git commit

set -e

HOOK_LOG=".claude/logs/hooks.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] PRE-COMMIT: $1" >> "$HOOK_LOG"
    echo "✋ $1"
}

log "Running pre-commit checks..."

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log "Not in a git repository, skipping pre-commit checks"
    exit 0
fi

# Get staged files
STAGED_FILES=$(git diff --cached --name-only)

if [[ -z "$STAGED_FILES" ]]; then
    log "No staged files found"
    exit 0
fi

log "Checking $(echo "$STAGED_FILES" | wc -l) staged files..."

ERRORS=0

# Check 1: Look for common issues in staged files
while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        # Check for TODO/FIXME comments in new additions
        if git diff --cached "$file" | grep -E "^\+.*\b(TODO|FIXME|XXX|HACK)\b" >/dev/null; then
            log "⚠️ Found TODO/FIXME in staged changes: $file"
        fi
        
        # Check for console.log in JavaScript files
        if [[ "$file" =~ \.(js|ts|jsx|tsx)$ ]]; then
            if git diff --cached "$file" | grep -E "^\+.*console\.(log|debug)" >/dev/null; then
                log "⚠️ Found console.log in staged changes: $file"
            fi
        fi
        
        # Check for large files (> 1MB)
        if [[ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0) -gt 1048576 ]]; then
            log "⚠️ Large file detected (>1MB): $file"
        fi
    fi
done <<< "$STAGED_FILES"

# Check 2: Run linting on staged JS/TS files if available
JS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(js|ts|jsx|tsx)$' || true)
if [[ -n "$JS_FILES" ]] && command -v npx >/dev/null 2>&1; then
    if [[ -f ".eslintrc.*" ]] || [[ -f "eslint.config.*" ]] || grep -q "eslint" package.json 2>/dev/null; then
        log "Running ESLint on staged files..."
        if echo "$JS_FILES" | xargs npx eslint --quiet 2>/dev/null; then
            log "✅ ESLint passed"
        else
            log "❌ ESLint found issues"
            ERRORS=$((ERRORS + 1))
        fi
    fi
fi

# Check 3: Run quick tests if test script exists
if [[ -f "package.json" ]] && grep -q '"test":' package.json; then
    TEST_SCRIPT=$(node -e "console.log(JSON.parse(require('fs').readFileSync('package.json', 'utf8')).scripts.test || '')" 2>/dev/null)
    
    if [[ "$TEST_SCRIPT" != *"no test specified"* ]] && [[ -n "$TEST_SCRIPT" ]]; then
        log "Running quick test check..."
        if timeout 30s npm test -- --passWithNoTests --silent 2>/dev/null; then
            log "✅ Tests passed"
        else
            log "⚠️ Tests failed or timed out"
            ERRORS=$((ERRORS + 1))
        fi
    fi
fi

# Check 4: Validate JSON files
JSON_FILES=$(echo "$STAGED_FILES" | grep '\.json$' || true)
if [[ -n "$JSON_FILES" ]]; then
    log "Validating JSON files..."
    while IFS= read -r json_file; do
        if [[ -f "$json_file" ]]; then
            if node -e "JSON.parse(require('fs').readFileSync('$json_file', 'utf8'))" 2>/dev/null; then
                log "✅ Valid JSON: $json_file"
            else
                log "❌ Invalid JSON: $json_file"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done <<< "$JSON_FILES"
fi

# Check 5: Ensure no .env files are being committed
ENV_FILES=$(echo "$STAGED_FILES" | grep -E '\.(env|environment)' || true)
if [[ -n "$ENV_FILES" ]]; then
    log "❌ Environment files detected in staging:"
    echo "$ENV_FILES" | while IFS= read -r env_file; do
        log "   - $env_file"
    done
    log "Remove these files from staging before committing"
    ERRORS=$((ERRORS + 1))
fi

# Summary
if [[ $ERRORS -eq 0 ]]; then
    log "✅ All pre-commit checks passed"
    exit 0
else
    log "❌ Pre-commit checks failed with $ERRORS errors"
    log "Fix the issues above before committing"
    exit 1
fi