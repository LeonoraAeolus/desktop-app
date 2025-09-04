# Git Status

Shows comprehensive git and project status information.

## Usage
```
/git-status
```

## What it shows
- **Git Status**: Modified, added, deleted files
- **Current Branch**: Active branch name
- **Recent Commits**: Last 5 commits
- **Hooks Status**: Claude Code configuration status
- **Project Status**: Frontend/Tauri setup and dependencies

## Perfect for
- Quick project overview
- Checking what needs to be committed
- Verifying project setup
- Understanding current development state

## Implementation
```bash
exec bash ".claude/hooks/slash-commands.sh" status
```