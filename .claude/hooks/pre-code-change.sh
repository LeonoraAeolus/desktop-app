#!/bin/bash

# CreativeKit Claude Code Pre-Change Hook
# Runs before any code modifications to ensure quality

set -e

echo "🔍 Pre-code-change validation starting..."

# Check if we're in the right project
if [ ! -f "package.json" ] || [ ! -f "src-tauri/Cargo.toml" ]; then
    echo "⚠️  Not in CreativeKit project root"
    exit 0
fi

# Quick lint check for staged files
if command -v npm &> /dev/null && [ -f "package.json" ]; then
    echo "📦 Running quick frontend checks..."
    npm run lint:fix 2>/dev/null || npm run lint 2>/dev/null || echo "⚠️  Frontend lint check skipped"
fi

# Check Rust formatting
if command -v cargo &> /dev/null && [ -f "src-tauri/Cargo.toml" ]; then
    echo "🦀 Checking Rust formatting..."
    cd src-tauri
    cargo fmt --check 2>/dev/null || {
        echo "🔧 Auto-formatting Rust code..."
        cargo fmt
    }
    cd ..
fi

# Check for common issues
echo "🔍 Checking for common issues..."

# Check for TODO/FIXME in critical files
critical_todos=$(find src src-tauri/src python-service/src 2>/dev/null | grep -E "\.(ts|tsx|rs|py)$" | xargs grep -l "TODO\|FIXME\|XXX" 2>/dev/null | wc -l || echo "0")
if [ "$critical_todos" -gt 10 ]; then
    echo "⚠️  Found $critical_todos files with TODOs/FIXMEs"
    echo "Consider resolving some before adding more code"
fi

# Check for large files
large_files=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.rs" -o -name "*.py" | xargs wc -l 2>/dev/null | awk '$1 > 500 {count++} END {print count+0}')
if [ "$large_files" -gt 0 ]; then
    echo "⚠️  Found $large_files files exceeding 500 lines"
    echo "Consider breaking down large files"
fi

echo "✅ Pre-code-change validation completed"