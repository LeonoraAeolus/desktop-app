# Auto Branch

Creates a smart feature branch with automatic naming and setup.

## Usage
```
/auto-branch <feature-name> [branch-type]
```

## Parameters
- `feature-name` (required): Name of the feature/fix
- `branch-type` (optional): Type of branch (feature, fix, docs, etc.) - defaults to "feature"

## Examples
```
/auto-branch pdf-merger
/auto-branch auth-bug fix
/auto-branch api-docs docs
```

## What it does
1. Syncs with main branch
2. Creates clean branch name (feature/pdf-merger)
3. Switches to new branch
4. Logs the action

## Implementation
```bash
exec bash ".claude/hooks/auto-workflow.sh" branch "$@"
```