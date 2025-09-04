#!/bin/bash
# .claude/hooks/run-tests.sh
# Run tests when test files are modified

set -e

TEST_FILE="$1"
HOOK_LOG=".claude/logs/hooks.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] TEST: $1" >> "$HOOK_LOG"
    echo "🧪 $1"
}

log "Test file modified: $TEST_FILE"

# Check if we have a test script in package.json
if [[ -f "package.json" ]] && grep -q '"test":' package.json; then
    TEST_SCRIPT=$(node -e "console.log(JSON.parse(require('fs').readFileSync('package.json', 'utf8')).scripts.test || '')" 2>/dev/null)
    
    if [[ "$TEST_SCRIPT" == *"no test specified"* ]] || [[ -z "$TEST_SCRIPT" ]]; then
        log "No test script configured in package.json"
        exit 0
    fi
    
    # If the test file is specific, try to run just that test
    if [[ -n "$TEST_FILE" && "$TEST_FILE" =~ \.(test|spec)\.(js|ts|jsx|tsx)$ ]]; then
        log "Running specific test: $TEST_FILE"
        
        # Try Jest pattern first
        if echo "$TEST_SCRIPT" | grep -q "jest"; then
            if npx jest "$TEST_FILE" --passWithNoTests 2>/dev/null; then
                log "✅ Jest test passed: $TEST_FILE"
                exit 0
            else
                log "❌ Jest test failed: $TEST_FILE"
                # Don't exit with error - let user decide
                exit 0
            fi
        fi
        
        # Try running the file directly if it's a simple test
        if [[ "$TEST_FILE" =~ \.js$ ]]; then
            if node "$TEST_FILE" 2>/dev/null; then
                log "✅ Test executed successfully: $TEST_FILE"
                exit 0
            fi
        fi
    fi
    
    # Run all tests (with timeout and in silent mode)
    log "Running all tests..."
    if timeout 60s npm test -- --passWithNoTests --silent 2>/dev/null; then
        log "✅ All tests passed"
    else
        TEST_EXIT_CODE=$?
        if [[ $TEST_EXIT_CODE -eq 124 ]]; then
            log "⏰ Tests timed out after 60 seconds"
        else
            log "⚠️ Some tests failed - check manually with 'npm test'"
        fi
        # Don't exit with error - this is just a helpful check
    fi
    
else
    log "No test configuration found"
    
    # Try to detect and suggest test setup
    if [[ -d "src" ]] || [[ -f "index.js" ]]; then
        log "💡 Consider setting up tests:"
        log "   npm install --save-dev jest"
        log "   Add to package.json: \"test\": \"jest\""
    fi
fi

log "Test check completed"
exit 0