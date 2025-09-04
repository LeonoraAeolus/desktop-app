# Auto Flow

Complete automated workflow: creates branch → waits for changes → commits → creates PR.

## Usage
```
/auto-flow <feature-name> [branch-type] [commit-message]
```

## Parameters
- `feature-name` (required): Name of the feature/fix
- `branch-type` (optional): Type of branch (feature, fix, docs, etc.) - defaults to "feature"  
- `commit-message` (optional): Custom commit message (otherwise AI-generated)

## Examples
```
/auto-flow pdf-merger
/auto-flow auth-bug fix
/auto-flow pdf-merger feature "feat: implement PDF merge functionality"
```

## Complete Workflow Steps
1. **Create Branch**: Syncs with main, creates feature branch
2. **Wait for Changes**: Pauses for you to make code changes
3. **Auto Commit**: Stages, commits, and pushes with smart message
4. **Auto PR**: Creates PR with AI-generated title and description
5. **Summary**: Shows branch, commit message, and PR URL

## Perfect for
- Quick feature development
- Bug fixes
- Documentation updates
- When you want full automation

## Implementation
```bash
exec bash ".claude/hooks/auto-workflow.sh" flow "$@"
```