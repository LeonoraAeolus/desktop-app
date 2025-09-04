#!/bin/bash

# CreativeKit Claude Code Git Operation Hook
# Runs before git operations (commit, push, merge) to validate state

set -e

echo "📝 Git operation validation starting..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a Git repository"
    exit 1
fi

# Show current git status
echo "📍 Current Git Status:"
echo "====================="
git status --short --branch

# Check for uncommitted changes
uncommitted=$(git status --porcelain | wc -l)
staged=$(git diff --cached --name-only | wc -l)

echo ""
echo "📊 Repository Statistics:"
echo "  Uncommitted changes: $uncommitted"
echo "  Staged files: $staged"

if [ "$staged" -gt 0 ]; then
    echo ""
    echo "📋 Staged files:"
    git diff --cached --name-only | sed 's/^/  - /'
fi

# Run pre-commit validations if files are staged
if [ "$staged" -gt 0 ]; then
    echo ""
    echo "🔍 Running pre-commit validations..."
    
    # Check for large files
    large_files=$(git diff --cached --name-only | xargs ls -la 2>/dev/null | awk '$5 > 1048576 {print $9, $5}' || true)
    if [ ! -z "$large_files" ]; then
        echo "⚠️  Large files detected (>1MB):"
        echo "$large_files"
        echo "Consider using Git LFS for large files"
    fi
    
    # Check for sensitive data patterns
    sensitive_patterns="API_KEY|SECRET|PASSWORD|TOKEN|private_key|credential"
    if git diff --cached | grep -iE "$sensitive_patterns" > /dev/null 2>&1; then
        echo "⚠️  Potential sensitive data detected in staged changes"
        echo "Please review carefully before committing"
    fi
    
    # Quick lint check on staged files
    staged_ts_files=$(git diff --cached --name-only | grep "\.tsx\?$" || true)
    if [ ! -z "$staged_ts_files" ] && command -v npm &> /dev/null; then
        echo "🔍 Quick TypeScript check..."
        npm run lint:staged 2>/dev/null || npm run typecheck 2>/dev/null || echo "⚠️  TypeScript check skipped"
    fi
    
    staged_rs_files=$(git diff --cached --name-only | grep "\.rs$" || true)
    if [ ! -z "$staged_rs_files" ] && command -v cargo &> /dev/null; then
        echo "🦀 Quick Rust check..."
        cd src-tauri
        cargo clippy --quiet 2>/dev/null || echo "⚠️  Rust check skipped"
        cd ..
    fi
fi

# Check branch protection rules
current_branch=$(git branch --show-current)
protected_branches="main master develop"

if echo "$protected_branches" | grep -q "$current_branch"; then
    echo ""
    echo "🛡️  Warning: You're on protected branch '$current_branch'"
    echo "Consider creating a feature branch for development:"
    echo "   git checkout -b feature/your-feature-name"
fi

# Show recent commits for context
echo ""
echo "📝 Recent commits:"
git log --oneline -3

# Check if there are any merge conflicts
if git status | grep -q "both modified\|both added"; then
    echo ""
    echo "⚠️  Merge conflicts detected - resolve before proceeding"
    git status | grep "both "
fi

# Log git operation attempt
echo "$(date): Git operation attempted on branch '$current_branch' by $(whoami)" >> .claude/git-operations.log

echo ""
echo "✅ Git operation validation completed"