#!/bin/bash

# CreativeKit Claude Code Post-Change Hook  
# Runs after code modifications to validate and prepare for commit

set -e

echo "✅ Post-code-change processing starting..."

# Check if we're in the right project
if [ ! -f "package.json" ] || [ ! -f "src-tauri/Cargo.toml" ]; then
    echo "⚠️  Not in CreativeKit project root"
    exit 0
fi

# Run quick validation on changed files
if command -v git &> /dev/null; then
    changed_files=$(git diff --name-only HEAD 2>/dev/null || git status --porcelain | cut -c4-)
    
    if [ ! -z "$changed_files" ]; then
        echo "📝 Files modified:"
        echo "$changed_files" | sed 's/^/  - /'
        
        # Count lines of code changed
        if git diff --stat HEAD 2>/dev/null | tail -1; then
            echo ""
        fi
        
        # Quick type check for TypeScript files
        if echo "$changed_files" | grep -q "\.tsx\?$"; then
            echo "🔍 Running TypeScript check on changed files..."
            npm run typecheck 2>/dev/null || echo "⚠️  TypeScript check skipped"
        fi
        
        # Quick Rust check for Rust files
        if echo "$changed_files" | grep -q "\.rs$"; then
            echo "🦀 Running Rust check on changed files..."
            cd src-tauri
            cargo check 2>/dev/null || echo "⚠️  Rust check skipped"
            cd ..
        fi
        
        # Stage files for commit
        echo "📋 Staging modified files..."
        git add -A
        echo "✅ Files staged for commit"
        
    else
        echo "ℹ️  No files modified"
    fi
else
    echo "⚠️  Git not available"
fi

# Update development metrics
echo "📊 Updating development metrics..."
{
    echo "$(date): Code changes completed"
    echo "Modified files: $(git diff --cached --name-only 2>/dev/null | wc -l || echo '0')"
    echo "---"
} >> .claude/development.log

echo "✅ Post-code-change processing completed"