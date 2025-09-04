# Auto PR

Creates a pull request with AI-generated title and description.

## Usage
```
/auto-pr [custom-title] [custom-description]
```

## Parameters
- `custom-title` (optional): Override the AI-generated PR title
- `custom-description` (optional): Override the AI-generated PR description

## Examples
```
/auto-pr
/auto-pr "Add PDF Merger Feature"
/auto-pr "Custom Title" "Custom description with details"
```

## What it does
1. Analyzes current branch name and commits
2. Detects project context (Tauri, React, TypeScript, etc.)
3. Generates professional PR title based on branch type
4. Creates comprehensive PR description with:
   - Summary of changes
   - List of commits
   - Testing checklist
   - Review checklist
5. Creates GitHub PR using `gh pr create`
6. Returns PR URL

## AI Content Generation
- **Title**: Generated from branch name (feature/pdf-merger → "Feature: PDF Merger")
- **Description**: Includes summary, changes, testing checklist, and metadata
- **Type Detection**: Detects if it's a feature, bug fix, docs, refactor, etc.

## Implementation
```bash
exec bash ".claude/hooks/auto-workflow.sh" pr "$@"
```