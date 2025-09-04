#!/bin/bash
# .claude/hooks/auto-workflow.sh
# Smart automated git workflow with AI-generated content

set -e

HOOK_LOG=".claude/logs/hooks.log"
mkdir -p "$(dirname "$HOOK_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] AUTO-WORKFLOW: $1" >> "$HOOK_LOG"
}

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() { echo -e "${BLUE}🔄 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${PURPLE}💡 $1${NC}"; }

# Detect project type and context
detect_project_context() {
    local context=""
    
    if [[ -f "src-tauri/Cargo.toml" ]]; then
        context="$context Tauri Desktop App"
    fi
    
    if [[ -f "package.json" ]]; then
        if grep -q "react" package.json; then
            context="$context React"
        fi
        if grep -q "typescript" package.json; then
            context="$context TypeScript"
        fi
    fi
    
    if [[ -f "CLAUDE.md" ]] && grep -q "CreativeKit" CLAUDE.md; then
        context="$context CreativeKit"
    fi
    
    echo "$context" | sed 's/^[[:space:]]*//'
}

# Generate smart commit message based on changes
generate_commit_message() {
    local changes_summary=""
    local commit_type="feat"
    local scope=""
    
    # Analyze changed files
    local changed_files=$(git diff --cached --name-only)
    local added_files=$(git diff --cached --name-status | grep "^A" | cut -f2 || true)
    local modified_files=$(git diff --cached --name-status | grep "^M" | cut -f2 || true)
    local deleted_files=$(git diff --cached --name-status | grep "^D" | cut -f2 || true)
    
    # Determine commit type based on changes
    if [[ -n "$deleted_files" ]]; then
        commit_type="refactor"
    elif echo "$changed_files" | grep -q "test\|spec"; then
        commit_type="test"
    elif echo "$changed_files" | grep -q "\.md$\|README\|docs/"; then
        commit_type="docs"
    elif echo "$changed_files" | grep -q "package\.json\|Cargo\.toml\|requirements\.txt"; then
        commit_type="chore"
    elif echo "$changed_files" | grep -q "bug\|fix" || git diff --cached | grep -i "fix\|bug"; then
        commit_type="fix"
    fi
    
    # Determine scope based on files
    if echo "$changed_files" | grep -q "src-tauri/"; then
        scope="tauri"
    elif echo "$changed_files" | grep -q "src/components/"; then
        scope="ui"
    elif echo "$changed_files" | grep -q "src/utils/\|src/services/"; then
        scope="core"
    elif echo "$changed_files" | grep -q "\.claude/"; then
        scope="config"
    elif echo "$changed_files" | grep -q "test\|spec"; then
        scope="test"
    fi
    
    # Generate description based on file patterns
    local description=""
    if echo "$changed_files" | grep -q "pdf"; then
        description="PDF processing functionality"
    elif echo "$changed_files" | grep -q "image\|png\|jpg"; then
        description="image processing features"
    elif echo "$changed_files" | grep -q "auth\|login"; then
        description="authentication system"
    elif echo "$changed_files" | grep -q "ui\|component"; then
        description="user interface components"
    elif echo "$changed_files" | grep -q "hook\|workflow"; then
        description="development workflow automation"
    elif echo "$changed_files" | grep -q "api\|service"; then
        description="API integration and services"
    else
        # Count changes for generic description
        local file_count=$(echo "$changed_files" | wc -l)
        if [[ $file_count -eq 1 ]]; then
            local filename=$(basename "$changed_files")
            description="update ${filename%.*}"
        else
            description="improve project functionality"
        fi
    fi
    
    # Construct commit message
    local message="${commit_type}"
    if [[ -n "$scope" ]]; then
        message="${message}(${scope})"
    fi
    message="${message}: ${description}"
    
    echo "$message"
}

# Generate PR title and description
generate_pr_content() {
    local branch_name="$1"
    local commits_info="$2"
    local project_context="$3"
    
    # Generate title from branch name
    local title=$(echo "$branch_name" | sed 's/^[^/]*\///' | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
    
    # Determine PR type from branch prefix
    local pr_type="Feature"
    if [[ "$branch_name" == fix/* ]]; then
        pr_type="Bug Fix"
    elif [[ "$branch_name" == docs/* ]]; then
        pr_type="Documentation"
    elif [[ "$branch_name" == refactor/* ]]; then
        pr_type="Refactor"
    elif [[ "$branch_name" == test/* ]]; then
        pr_type="Testing"
    fi
    
    title="$pr_type: $title"
    
    # Generate description
    local description="## 🎯 Summary

This PR implements $title for the $project_context project.

## 📝 Changes Made

$commits_info

## 🧪 Testing

- [ ] Code builds successfully
- [ ] All existing tests pass
- [ ] New functionality tested manually
- [ ] No breaking changes introduced

## 🔍 Checklist

- [x] Code follows project style guidelines
- [x] Self-review completed
- [x] Documentation updated (if needed)
- [x] No sensitive data exposed

## 🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    echo "$title|$description"
}

# Main workflow functions
create_smart_branch() {
    local feature_name="$1"
    local branch_type="${2:-feature}"
    
    if [[ -z "$feature_name" ]]; then
        print_error "Feature name required"
        echo "Usage: /auto-branch <feature-name> [type]"
        return 1
    fi
    
    print_status "Creating smart branch for: $feature_name"
    
    # Clean and create branch name
    local clean_name=$(echo "$feature_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    local branch_name="${branch_type}/${clean_name}"
    
    # Switch to main and pull latest
    local main_branch="main"
    if git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    fi
    
    print_status "Syncing with $main_branch..."
    git checkout "$main_branch"
    git pull origin "$main_branch"
    
    # Create and switch to new branch
    git checkout -b "$branch_name"
    print_success "Created branch: $branch_name"
    
    log "Created smart branch: $branch_name"
    echo "$branch_name"
}

auto_commit_and_push() {
    local custom_message="$1"
    
    print_status "Preparing smart commit..."
    
    # Stage all changes
    git add .
    
    # Check if there are changes
    if git diff --cached --quiet; then
        print_warning "No changes to commit"
        return 0
    fi
    
    # Generate or use custom commit message
    local commit_message
    if [[ -n "$custom_message" ]]; then
        commit_message="$custom_message"
    else
        print_status "Generating smart commit message..."
        commit_message=$(generate_commit_message)
    fi
    
    print_info "Commit message: $commit_message"
    
    # Run pre-commit checks
    print_status "Running quality checks..."
    if bash ".claude/hooks/pre-commit-check.sh"; then
        print_success "Quality checks passed"
    else
        print_error "Quality checks failed - fix issues before committing"
        return 1
    fi
    
    # Make commit
    git commit -m "$commit_message"
    print_success "Committed changes"
    
    # Push to origin
    local current_branch=$(git branch --show-current)
    print_status "Pushing to origin..."
    git push -u origin "$current_branch"
    print_success "Pushed to GitHub"
    
    log "Auto-commit completed: $commit_message"
    echo "$commit_message"
}

create_smart_pr() {
    local custom_title="$1"
    local custom_body="$2"
    
    local current_branch=$(git branch --show-current)
    local project_context=$(detect_project_context)
    
    print_status "Creating smart PR for branch: $current_branch"
    
    # Get commits for this branch
    local main_branch="main"
    if git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    fi
    
    local commits_info=$(git log "$main_branch..$current_branch" --pretty=format:"- %s" | head -10)
    
    # Generate PR content
    local pr_content
    if [[ -n "$custom_title" ]]; then
        local title="$custom_title"
        local body="$custom_body"
        if [[ -z "$body" ]]; then
            body="Changes made in branch: $current_branch

$commits_info

🤖 Generated with [Claude Code](https://claude.ai/code)"
        fi
    else
        pr_content=$(generate_pr_content "$current_branch" "$commits_info" "$project_context")
        local title=$(echo "$pr_content" | cut -d'|' -f1)
        local body=$(echo "$pr_content" | cut -d'|' -f2)
    fi
    
    print_info "PR Title: $title"
    
    # Create PR
    gh pr create --title "$title" --body "$body"
    local pr_url=$(gh pr view --json url -q .url)
    
    print_success "PR created: $pr_url"
    log "Smart PR created: $title"
    
    echo "$pr_url"
}

# All-in-one workflow
full_auto_workflow() {
    local feature_name="$1"
    local branch_type="${2:-feature}"
    local commit_message="$3"
    
    if [[ -z "$feature_name" ]]; then
        print_error "Feature name required"
        echo "Usage: /auto-flow <feature-name> [branch-type] [commit-message]"
        return 1
    fi
    
    print_status "🚀 Starting full automated workflow..."
    
    # Step 1: Create branch
    local branch_name=$(create_smart_branch "$feature_name" "$branch_type")
    
    # Step 2: Wait for user to make changes
    print_info "Branch created: $branch_name"
    print_warning "Make your changes now, then press Enter to continue..."
    read -r
    
    # Step 3: Auto commit and push
    local actual_commit_message=$(auto_commit_and_push "$commit_message")
    
    # Step 4: Create PR
    local pr_url=$(create_smart_pr)
    
    print_success "🎉 Full workflow completed!"
    print_info "Branch: $branch_name"
    print_info "Commit: $actual_commit_message"  
    print_info "PR: $pr_url"
    
    log "Full auto-workflow completed for: $feature_name"
}

# Command routing
case "${1:-help}" in
    "branch")
        create_smart_branch "$2" "$3"
        ;;
    "commit")
        auto_commit_and_push "$2"
        ;;
    "pr")
        create_smart_pr "$2" "$3"
        ;;
    "flow")
        full_auto_workflow "$2" "$3" "$4"
        ;;
    "help"|*)
        echo "Auto Workflow Commands:"
        echo ""
        echo "  branch <name> [type]     - Create smart branch"
        echo "  commit [message]         - Auto commit with smart message"
        echo "  pr [title] [description] - Create PR with auto content"
        echo "  flow <name> [type] [msg] - Full workflow (branch->commit->PR)"
        echo ""
        echo "Examples:"
        echo "  bash .claude/hooks/auto-workflow.sh branch pdf-merger"
        echo "  bash .claude/hooks/auto-workflow.sh commit"
        echo "  bash .claude/hooks/auto-workflow.sh pr"
        echo "  bash .claude/hooks/auto-workflow.sh flow pdf-merger feature"
        ;;
esac