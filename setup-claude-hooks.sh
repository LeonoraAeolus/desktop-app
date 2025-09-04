#!/bin/bash
# setup-claude-hooks.sh
# Quick setup script for Claude Code hooks

set -e

echo "🚀 Setting up Claude Code hooks..."

# Create directory structure
mkdir -p .claude/hooks
mkdir -p .claude/logs
mkdir -p .claude/commands

# Make hook scripts executable
if [[ -d ".claude/hooks" ]]; then
    find .claude/hooks -name "*.sh" -exec chmod +x {} \;
    echo "✅ Made hook scripts executable"
fi

# Create a simple CLAUDE.md if it doesn't exist
if [[ ! -f "CLAUDE.md" ]]; then
    cat > CLAUDE.md << 'EOF'
# Project Context

This is a development project with Claude Code automation hooks configured.

## Development Setup
- Hooks are configured for code formatting, testing, and git workflow
- Logs are stored in `.claude/logs/`
- Check `.claude/settings.json` for hook configuration

## Code Standards
- Use consistent formatting (Prettier/ESLint when available)
- Write tests for new functionality
- Keep commits focused and descriptive
- Review changes before committing

## Available Commands
Use these slash commands in Claude Code:
- `/test` - Run tests
- `/format` - Format code
- `/commit` - Help with commit messages
- `/status` - Check project status
EOF
    echo "✅ Created CLAUDE.md with project context"
fi

# Create some useful slash commands
cat > .claude/commands/test.md << 'EOF'
# Test Command

Run tests for the specified files or run all tests if no arguments provided.

Test requirements:
- Use existing test framework (Jest, Mocha, etc.)
- Show clear output
- Report coverage if available

Arguments: $ARGUMENTS (optional file patterns)
EOF

cat > .claude/commands/format.md << 'EOF'
# Format Command

Format and lint the specified files using project's configured tools (Prettier, ESLint, etc.).

Format requirements:
- Use project's existing configuration
- Auto-fix issues where possible
- Stage formatted files for commit

Arguments: $ARGUMENTS (file patterns, defaults to all source files)
EOF

cat > .claude/commands/commit.md << 'EOF'
# Smart Commit

Help create a well-structured commit message based on staged changes.

Requirements:
- Use conventional commit format when possible
- Analyze staged changes to suggest appropriate type and scope
- Include brief description of changes
- Ensure commit message is clear and descriptive

Arguments: $ARGUMENTS (optional commit type override)
EOF

cat > .claude/commands/status.md << 'EOF'
# Project Status

Show current project status including:
- Git status and branch info
- Recent changes and commits
- Test results summary
- Dependency status
- Any outstanding issues or todos

Arguments: $ARGUMENTS (optional: 'full' for detailed status)
EOF

echo "✅ Created useful slash commands"

# Create .gitignore entries for logs and local settings
if [[ -f ".gitignore" ]]; then
    if ! grep -q ".claude/logs" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude Code logs and local settings" >> .gitignore
        echo ".claude/logs/" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
        echo "✅ Added Claude Code entries to .gitignore"
    fi
else
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/

# Logs
*.log

# Claude Code logs and local settings
.claude/logs/
.claude/settings.local.json

# Environment variables
.env
.env.local
.env.*.local

# OS generated files
.DS_Store
Thumbs.db
EOF
    echo "✅ Created .gitignore with Claude Code entries"
fi

# Test hook permissions and basic functionality
echo "🔧 Testing hook setup..."

if [[ -x ".claude/hooks/format-code.sh" ]]; then
    echo "✅ Format hook is executable"
else
    echo "❌ Format hook is not executable"
fi

if [[ -x ".claude/hooks/session-cleanup.sh" ]]; then
    echo "✅ Cleanup hook is executable"
else
    echo "❌ Cleanup hook is not executable"
fi

# Create initial log entry
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SETUP: Claude Code hooks initialized" >> .claude/logs/hooks.log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Claude Code Hooks Setup Completed ===" >> .claude/logs/activity.log

echo ""
echo "🎉 Claude Code hooks setup complete!"
echo ""
echo "Next steps:"
echo "1. Review .claude/settings.json configuration"
echo "2. Test hooks by running Claude Code in this directory"
echo "3. Customize CLAUDE.md with your project details"
echo "4. Try slash commands: /test, /format, /commit, /status"
echo ""
echo "Hook logs will be stored in .claude/logs/"
echo "Use 'tail -f .claude/logs/hooks.log' to monitor hook activity"
echo ""
echo "Happy coding with Claude! 🤖" '