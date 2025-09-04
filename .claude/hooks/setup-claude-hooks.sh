#!/bin/bash

# CreativeKit Claude Code Hooks Setup
# Sets up Claude Code specific hooks for development workflow

set -e

echo "🎯 Setting up Claude Code hooks for CreativeKit..."

# Create necessary directories
mkdir -p .claude/logs
mkdir -p scripts/claude-hooks

# Make all hook scripts executable
echo "🔑 Making hook scripts executable..."
find scripts/claude-hooks -name "*.sh" -exec chmod +x {} \;

# Update the Claude settings with proper paths
echo "⚙️  Updating Claude Code settings..."

# Create an updated settings file with absolute paths
project_dir=$(pwd)

cat > .claude/settings.json << EOF
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "^(Write|Edit|MultiEdit)$",
        "hooks": [
          {
            "type": "command",
            "command": "${project_dir}/scripts/claude-hooks/pre-code-change.sh"
          }
        ]
      },
      {
        "matcher": "^Bash$",
        "hooks": [
          {
            "type": "command", 
            "command": "echo '⚡ Bash command: \$CLAUDE_TOOL_ARGS' >> .claude/logs/bash-history.log"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit|MultiEdit)$",
        "hooks": [
          {
            "type": "command",
            "command": "${project_dir}/scripts/claude-hooks/post-code-change.sh"
          }
        ]
      },
      {
        "matcher": "^Bash.*build",
        "hooks": [
          {
            "type": "command",
            "command": "${project_dir}/scripts/post-build.sh"
          }
        ]
      },
      {
        "matcher": "^Bash.*(test|npm test|cargo test)",
        "hooks": [
          {
            "type": "command", 
            "command": "echo '🧪 Test completed: \$(date)' >> .claude/logs/test-history.log"
          }
        ]
      }
    ],
    "UserSubmitPrompt": [
      {
        "matcher": ".*(commit|push|merge).*",
        "hooks": [
          {
            "type": "command",
            "command": "${project_dir}/scripts/claude-hooks/git-operation.sh"
          }
        ]
      },
      {
        "matcher": ".*(build|deploy|release).*",
        "hooks": [
          {
            "type": "command",
            "command": "${project_dir}/scripts/pre-build.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "${project_dir}/scripts/claude-hooks/session-start.sh"
          }
        ]
      }
    ]
  },
  "project": {
    "name": "CreativeKit Desktop",
    "type": "tauri-desktop-app",
    "languages": ["typescript", "rust", "python"],
    "frameworks": ["react", "tauri", "fastapi"],
    "build_system": "tauri",
    "package_manager": {
      "frontend": "npm",
      "rust": "cargo", 
      "python": "uv"
    }
  },
  "development": {
    "max_file_lines": 500,
    "auto_format": true,
    "auto_lint": true,
    "require_tests": true,
    "git_hooks": true
  },
  "commands": {
    "dev": "cargo tauri dev",
    "build": "cargo tauri build",
    "test_all": "npm test && cd src-tauri && cargo test && cd ../python-service && uv run pytest",
    "lint_all": "npm run lint && cd src-tauri && cargo clippy && cd ../python-service && uv run ruff check .",
    "format_all": "npm run format && cd src-tauri && cargo fmt && cd ../python-service && uv run ruff format ."
  }
}
EOF

# Create project reminders file
cat > .claude/reminders.txt << 'EOF'
• Keep files under 500 lines (CLAUDE.md requirement)
• Use uv for Python, npm for frontend, cargo for Rust
• Run tests before committing (npm test && cargo test)
• Follow commit message format: type(scope): description
• Check CLAUDE.md for development guidelines
EOF

# Create package.json scripts if they don't exist
if [ -f "package.json" ] && ! grep -q '"lint:staged"' package.json; then
    echo "📦 Adding useful npm scripts..."
    
    # This would typically require jq or manual editing
    echo "⚠️  Manually add these npm scripts to package.json:"
    echo '  "lint:quick": "eslint --cache --max-warnings 0 src/",'
    echo '  "lint:staged": "lint-staged",'
    echo '  "typecheck": "tsc --noEmit"'
fi

# Create .gitignore entries for hook logs
if [ -f ".gitignore" ]; then
    if ! grep -q ".claude/logs" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude Code logs" >> .gitignore
        echo ".claude/logs/" >> .gitignore
        echo "*.log" >> .gitignore
    fi
fi

# Test hook setup
echo "🧪 Testing hook configuration..."

# Test if hooks directory exists and is accessible
if [ -d "scripts/claude-hooks" ] && [ -x "scripts/claude-hooks/session-start.sh" ]; then
    echo "✅ Claude Code hooks configured successfully"
else
    echo "❌ Hook setup may have issues"
fi

# Show hook status
echo ""
echo "📋 Hook Setup Summary:"
echo "====================="
echo "✅ Claude settings: .claude/settings.json"
echo "✅ Hook scripts: scripts/claude-hooks/"
echo "✅ Log directory: .claude/logs/"
echo "✅ Project reminders: .claude/reminders.txt"
echo ""

echo "🎯 Claude Code Hook Events:"
echo "=========================="
echo "• SessionStart: Project status and reminders"  
echo "• PreToolUse: Code quality checks before changes"
echo "• PostToolUse: Validation and staging after changes"
echo "• UserSubmitPrompt: Git operations and build validations"
echo ""

echo "📝 Next Steps:"
echo "=============="
echo "1. Restart Claude Code to load new hook configuration"
echo "2. Make a code change to test the hooks"
echo "3. Check .claude/logs/ for hook execution logs"
echo "4. Customize hooks in .claude/settings.json as needed"
echo ""

echo "✅ Claude Code hooks setup completed! 🎉"