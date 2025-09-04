#!/bin/bash
# .claude/hooks/git-workflow.sh
# Git workflow management and branch protection

set -e

HOOK_LOG=".claude/logs/hooks.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] GIT-WORKFLOW: $1" >> "$HOOK_LOG"
}

# Check if we're on main/master branch
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
main_branches=("main" "master" "production")

is_main_branch() {
    local branch="$1"
    for main_branch in "${main_branches[@]}"; do
        if [[ "$branch" == "$main_branch" ]]; then
            return 0
        fi
    done
    return 1
}

# Prevent direct commits to main branches (unless it's a merge)
check_main_branch_protection() {
    if is_main_branch "$current_branch"; then
        # Check if this is a merge commit
        if [[ -f ".git/MERGE_HEAD" ]]; then
            log "Merge commit to $current_branch allowed"
            return 0
        fi
        
        echo "🚫 Direct commits to '$current_branch' branch are not allowed"
        echo "💡 Please create a feature branch:"
        echo "   git checkout -b feature/your-feature-name"
        echo "   # Make your changes"
        echo "   # git add . && git commit -m 'your message'"
        echo "   # git push -u origin feature/your-feature-name"
        log "Blocked direct commit to $current_branch"
        exit 1
    fi
}

# Suggest creating PR when pushing feature branches
suggest_pr_creation() {
    if [[ "$current_branch" == feature/* ]] || [[ "$current_branch" == fix/* ]] || [[ "$current_branch" == feat/* ]]; then
        # Check if this branch exists on remote
        if git ls-remote --exit-code --heads origin "$current_branch" >/dev/null 2>&1; then
            echo "💡 Consider creating a PR for this feature branch:"
            echo "   gh pr create --title 'Title' --body 'Description'"
            log "Suggested PR creation for $current_branch"
        fi
    fi
}

# Check for uncommitted changes before switching branches
check_clean_working_tree() {
    if [[ -n $(git status --porcelain) ]]; then
        echo "⚠️  You have uncommitted changes. Consider committing them first."
        log "Uncommitted changes detected"
    fi
}

# Main workflow function
case "${1:-check}" in
    "protect-main")
        check_main_branch_protection
        ;;
    "suggest-pr")
        suggest_pr_creation
        ;;
    "check-clean")
        check_clean_working_tree
        ;;
    "check"|*)
        check_main_branch_protection
        ;;
esac

log "Git workflow check completed for branch: $current_branch"