#!/bin/bash

# CreativeKit Claude Code Session Start Hook
# Initializes development environment and shows project status

set -e

echo "🚀 CreativeKit development session starting..."

# Create Claude logs directory if it doesn't exist
mkdir -p .claude/logs

# Log session start
{
    echo "========================================"
    echo "Session started: $(date)"
    echo "User: $(whoami)"
    echo "Directory: $(pwd)"
    echo "========================================"
} >> .claude/session.log

# Show project status
echo "📋 Project Status:"
echo "=================="

# Git status if available
if command -v git &> /dev/null && [ -d ".git" ]; then
    echo "📍 Git Status:"
    git status --short --branch
    
    # Show recent commits
    echo ""
    echo "📝 Recent Commits:"
    git log --oneline -5 2>/dev/null || echo "No recent commits"
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo ""
        echo "⚠️  Uncommitted changes detected"
    fi
    
    echo ""
fi

# Check Node.js dependencies
if [ -f "package.json" ]; then
    echo "📦 Frontend Status:"
    if [ -d "node_modules" ]; then
        echo "  ✅ Dependencies installed"
        # Check for outdated packages
        outdated=$(npm outdated 2>/dev/null | wc -l || echo "0")
        if [ "$outdated" -gt 1 ]; then
            echo "  ⚠️  $((outdated - 1)) packages may need updating"
        fi
    else
        echo "  ❌ Dependencies not installed - run 'npm install'"
    fi
    echo ""
fi

# Check Rust dependencies
if [ -f "src-tauri/Cargo.toml" ]; then
    echo "🦀 Rust Status:"
    if [ -d "src-tauri/target" ]; then
        echo "  ✅ Rust dependencies checked"
    else
        echo "  ⚠️  Run 'cargo check' to verify Rust setup"
    fi
    echo ""
fi

# Check Python service if exists
if [ -d "python-service" ] && [ -f "python-service/pyproject.toml" ]; then
    echo "🐍 Python Service Status:"
    if [ -d "python-service/.venv" ] || command -v uv &> /dev/null; then
        echo "  ✅ Python environment ready"
    else
        echo "  ⚠️  Run 'cd python-service && uv venv && uv sync'"
    fi
    echo ""
fi

# Show available development commands
echo "🛠️  Available Commands:"
echo "======================="
echo "  npm run dev          - Start development server"
echo "  cargo tauri dev      - Start Tauri development"
echo "  npm test             - Run frontend tests"
echo "  cargo test           - Run Rust tests (in src-tauri/)"
echo "  npm run lint         - Run frontend linting"
echo "  cargo clippy         - Run Rust linting (in src-tauri/)"
echo ""
echo "  ./scripts/dev-workflow.sh help  - More development commands"
echo ""

# Check for project-specific reminders
if [ -f ".claude/reminders.txt" ]; then
    echo "💡 Project Reminders:"
    echo "===================="
    cat .claude/reminders.txt
    echo ""
fi

# Show current branch and suggest next steps
if command -v git &> /dev/null && [ -d ".git" ]; then
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "🌟 Current branch: $current_branch"
    
    if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
        echo "💡 Tip: Create a feature branch for development"
        echo "   git checkout -b feature/your-feature-name"
    fi
fi

echo ""
echo "✅ Session initialized - Happy coding! 🎉"
echo ""