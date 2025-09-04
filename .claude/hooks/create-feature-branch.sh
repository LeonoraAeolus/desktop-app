#!/bin/bash
# .claude/hooks/create-feature-branch.sh
# Create feature branch with proper naming and setup

set -e

HOOK_LOG=".claude/logs/hooks.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CREATE-BRANCH: $1" >> "$HOOK_LOG"
}

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}🔄 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Get feature name
FEATURE_NAME="$1"
BRANCH_TYPE="${2:-feature}"

if [[ -z "$FEATURE_NAME" ]]; then
    echo "Usage: bash .claude/hooks/create-feature-branch.sh <feature-name> [branch-type]"
    echo ""
    echo "Examples:"
    echo "  bash .claude/hooks/create-feature-branch.sh pdf-merger"
    echo "  bash .claude/hooks/create-feature-branch.sh auth-bug fix"
    echo "  bash .claude/hooks/create-feature-branch.sh ui-improvements feat"
    echo ""
    echo "Branch types: feature (default), fix, feat, docs, refactor, test"
    exit 1
fi

# Validate branch type
valid_types=("feature" "fix" "feat" "docs" "refactor" "test" "chore")
if [[ ! " ${valid_types[*]} " =~ " ${BRANCH_TYPE} " ]]; then
    print_error "Invalid branch type: $BRANCH_TYPE"
    echo "Valid types: ${valid_types[*]}"
    exit 1
fi

# Clean feature name (lowercase, replace spaces/special chars with dashes)
CLEAN_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
BRANCH_NAME="${BRANCH_TYPE}/${CLEAN_NAME}"

print_status "Creating branch: $BRANCH_NAME"

# Check if we have uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    print_warning "You have uncommitted changes"
    echo "Options:"
    echo "  1. Commit them now"
    echo "  2. Stash them"
    echo "  3. Cancel"
    read -p "Choose (1/2/3): " choice
    
    case $choice in
        1)
            print_status "Staging and committing changes..."
            git add .
            echo "Enter commit message for current changes:"
            read -r commit_msg
            git commit -m "$commit_msg"
            ;;
        2)
            print_status "Stashing changes..."
            git stash push -m "Auto-stash before creating branch $BRANCH_NAME"
            ;;
        3)
            print_warning "Cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
fi

# Make sure we're on main/master
current_branch=$(git branch --show-current)
main_branch="main"
if git show-ref --verify --quiet refs/heads/master; then
    main_branch="master"
fi

if [[ "$current_branch" != "$main_branch" ]]; then
    print_status "Switching to $main_branch branch..."
    git checkout "$main_branch"
fi

# Pull latest changes
print_status "Pulling latest changes from origin..."
git pull origin "$main_branch"

# Create and switch to new branch
print_status "Creating and switching to branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

print_success "Branch created successfully!"
print_status "You're now on branch: $BRANCH_NAME"

# Log the action
log "Created branch: $BRANCH_NAME from $main_branch"

echo ""
print_status "Next steps:"
echo "  📝 Make your changes"
echo "  💾 Commit: bash .claude/hooks/smart-commit.sh 'your message'"
echo "  📤 Push: git push -u origin $BRANCH_NAME"
echo "  🔗 Create PR: gh pr create"

# Create a placeholder commit if requested
read -p "Create initial commit? (y/N): " create_commit
if [[ "$create_commit" =~ ^[Yy]$ ]]; then
    echo "# $FEATURE_NAME" > ".claude/logs/branch-$CLEAN_NAME.md"
    echo "" >> ".claude/logs/branch-$CLEAN_NAME.md"
    echo "## Description" >> ".claude/logs/branch-$CLEAN_NAME.md"
    echo "TODO: Describe the changes for this branch" >> ".claude/logs/branch-$CLEAN_NAME.md"
    echo "" >> ".claude/logs/branch-$CLEAN_NAME.md"
    echo "## Tasks" >> ".claude/logs/branch-$CLEAN_NAME.md"
    echo "- [ ] TODO: Add your tasks here" >> ".claude/logs/branch-$CLEAN_NAME.md"
    
    git add ".claude/logs/branch-$CLEAN_NAME.md"
    git commit -m "feat: initialize $BRANCH_TYPE branch for $FEATURE_NAME

    🚧 Generated with [Claude Code](https://claude.ai/code)
    
    Co-Authored-By: Claude <noreply@anthropic.com>"
    
    print_success "Initial commit created with branch documentation"
fi