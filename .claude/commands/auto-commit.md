# Auto Commit

Automatically stages, commits, and pushes changes with AI-generated commit messages.

## Usage
```
/auto-commit [custom-message]
```

## Parameters
- `custom-message` (optional): Override the AI-generated commit message

## Examples
```
/auto-commit
/auto-commit "feat: add special PDF processing feature"
```

## What it does
1. Stages all changes (`git add .`)
2. Analyzes changed files to determine commit type and scope
3. Generates smart commit message following conventional commits format
4. Runs pre-commit quality checks
5. Creates commit with generated/custom message
6. Pushes to origin branch

## AI Message Generation
- Detects commit type: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`
- Determines scope: `ui`, `core`, `tauri`, `config`, `test`
- Creates descriptive message based on file patterns

## Implementation
```bash
exec bash ".claude/hooks/auto-workflow.sh" commit "$@"
```