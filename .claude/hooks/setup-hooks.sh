#!/bin/bash

# CreativeKit Hooks Setup Script
# Sets up all Git hooks and makes them executable

set -e

echo "🔧 Setting up CreativeKit development hooks..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a Git repository"
    echo "Please run this script from the CreativeKit project root"
    exit 1
fi

# Make sure hooks directory exists
if [ ! -d ".git/hooks" ]; then
    mkdir -p .git/hooks
    echo "📁 Created .git/hooks directory"
fi

# Make hooks executable (critical on Unix systems)
echo "🔑 Making hooks executable..."

hooks=(
    ".git/hooks/pre-commit"
    ".git/hooks/pre-push"
    ".git/hooks/post-checkout"
)

for hook in "${hooks[@]}"; do
    if [ -f "$hook" ]; then
        chmod +x "$hook"
        echo "✅ Made $hook executable"
    else
        echo "⚠️  Hook not found: $hook"
    fi
done

# Make build scripts executable
echo "🔧 Making build scripts executable..."

build_scripts=(
    "scripts/pre-build.sh"
    "scripts/post-build.sh"
    "scripts/setup-hooks.sh"
)

for script in "${build_scripts[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "✅ Made $script executable"
    else
        echo "⚠️  Script not found: $script"
    fi
done

# Test hooks by running a basic validation
echo "🧪 Testing hook installation..."

# Test pre-commit hook
if [ -f ".git/hooks/pre-commit" ] && [ -x ".git/hooks/pre-commit" ]; then
    echo "✅ pre-commit hook installed and executable"
else
    echo "❌ pre-commit hook issue"
fi

# Test pre-push hook
if [ -f ".git/hooks/pre-push" ] && [ -x ".git/hooks/pre-push" ]; then
    echo "✅ pre-push hook installed and executable"
else
    echo "❌ pre-push hook issue"
fi

# Test post-checkout hook
if [ -f ".git/hooks/post-checkout" ] && [ -x ".git/hooks/post-checkout" ]; then
    echo "✅ post-checkout hook installed and executable"
else
    echo "❌ post-checkout hook issue"
fi

# Create hook logs directory
mkdir -p .git/hooks/logs
echo "📁 Created hooks log directory"

# Add hook configuration to git config (optional settings)
echo "⚙️  Configuring Git settings..."

# Set up better commit message template
git config --local commit.template .gitmessage 2>/dev/null || true

# Set up push configuration
git config --local push.default current 2>/dev/null || true

# Enable helpful Git features
git config --local help.autocorrect 1 2>/dev/null || true
git config --local branch.autosetuprebase always 2>/dev/null || true

# Create a sample .gitmessage file if it doesn't exist
if [ ! -f ".gitmessage" ]; then
    cat > .gitmessage << 'EOF'
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>

# Type: feat|fix|docs|style|refactor|test|chore
# Scope: The area of the codebase affected
# Subject: Brief description (50 chars max)
# Body: Detailed explanation of what and why (72 chars per line)
# Footer: Issue references, breaking changes, etc.

# Example:
# feat(pdf): add batch merge functionality
#
# - Implement multi-file PDF merging with progress tracking
# - Add drag-and-drop support for multiple files
# - Include error handling for corrupted PDFs
#
# Closes #42
EOF
    echo "📝 Created commit message template (.gitmessage)"
fi

# Create development workflow script
cat > scripts/dev-workflow.sh << 'EOF'
#!/bin/bash

# CreativeKit Development Workflow Helper
# Quick commands for common development tasks

set -e

case "$1" in
    "setup")
        echo "🚀 Setting up CreativeKit development environment..."
        npm install
        cd src-tauri && cargo check && cd ..
        if [ -d "python-service" ]; then
            cd python-service && uv sync && cd ..
        fi
        echo "✅ Development environment ready"
        ;;
    "test")
        echo "🧪 Running all tests..."
        npm test
        cd src-tauri && cargo test && cd ..
        if [ -d "python-service" ]; then
            cd python-service && uv run pytest && cd ..
        fi
        echo "✅ All tests passed"
        ;;
    "lint")
        echo "🔍 Running all linters..."
        npm run lint
        npm run typecheck
        cd src-tauri && cargo clippy --all-targets --all-features -- -D warnings && cd ..
        if [ -d "python-service" ]; then
            cd python-service && uv run ruff check . && uv run mypy src/ && cd ..
        fi
        echo "✅ All linting passed"
        ;;
    "build")
        echo "🔨 Building CreativeKit..."
        ./scripts/pre-build.sh
        cargo tauri build
        ./scripts/post-build.sh
        echo "✅ Build completed"
        ;;
    "dev")
        echo "🚧 Starting development server..."
        cargo tauri dev
        ;;
    "clean")
        echo "🧹 Cleaning build artifacts..."
        rm -rf node_modules/.cache
        rm -rf src-tauri/target/debug
        npm run clean 2>/dev/null || true
        echo "✅ Cleaned build artifacts"
        ;;
    *)
        echo "CreativeKit Development Workflow"
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  setup  - Set up development environment"
        echo "  test   - Run all tests"
        echo "  lint   - Run all linters"
        echo "  build  - Build the application"
        echo "  dev    - Start development server"
        echo "  clean  - Clean build artifacts"
        ;;
esac
EOF

chmod +x scripts/dev-workflow.sh
echo "🛠️  Created development workflow helper"

# Summary
echo ""
echo "✅ CreativeKit hooks setup completed!"
echo ""
echo "📋 What was installed:"
echo "  • pre-commit hook (code quality checks)"
echo "  • pre-push hook (full test suite)"
echo "  • post-checkout hook (dependency management)"
echo "  • Build validation scripts"
echo "  • Development workflow helper"
echo ""
echo "🚀 Next steps:"
echo "  1. Make your first commit to test the pre-commit hook"
echo "  2. Use './scripts/dev-workflow.sh help' for development commands"
echo "  3. Check '.gitmessage' for commit message guidelines"
echo ""
echo "⚙️  Hook logs will be saved in:"
echo "  • .git/hooks/push.log"
echo "  • .git/hooks/checkout.log"
echo "  • .build.log"
echo ""
echo "🎊 Happy coding!"