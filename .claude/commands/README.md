# Claude Code Slash Commands

Custom slash commands for automated git workflow with AI-generated content.

## 🚀 Auto Workflow Commands

### `/auto-branch <name> [type]`
Creates a smart feature branch with automatic setup.
```bash
/auto-branch pdf-merger          # Creates feature/pdf-merger
/auto-branch auth-bug fix        # Creates fix/auth-bug
/auto-branch docs-update docs    # Creates docs/docs-update
```

### `/auto-commit [message]`
AI-powered commit with smart message generation.
```bash
/auto-commit                     # AI generates commit message
/auto-commit "feat: custom msg"  # Use custom message
```

**AI Features:**
- Analyzes changed files to determine commit type (`feat`, `fix`, `docs`, etc.)
- Detects scope based on file locations (`ui`, `core`, `tauri`, etc.) 
- Creates conventional commit messages
- Runs quality checks before committing

### `/auto-pr [title] [description]`
Creates pull requests with AI-generated titles and descriptions.
```bash
/auto-pr                                    # Full AI generation
/auto-pr "Custom Title"                     # Custom title, AI description  
/auto-pr "Custom Title" "Custom desc"       # Both custom
```

**AI Features:**
- Generates professional PR titles from branch names
- Creates comprehensive descriptions with checklists
- Includes commit summaries and testing guidelines
- Detects project context (Tauri, React, TypeScript, etc.)

### `/auto-flow <name> [type] [message]`
Complete automated workflow: branch → commit → PR.
```bash
/auto-flow pdf-merger                       # Full automation
/auto-flow auth-bug fix                     # Bug fix workflow
/auto-flow ui-update feature "Custom msg"  # With custom commit
```

**Workflow Steps:**
1. Creates smart branch
2. Waits for you to make changes
3. Auto-commits with AI message
4. Creates PR with AI content
5. Shows summary with URLs

## 📋 Utility Commands

### `/git-status`
Shows comprehensive project status.
```bash
/git-status
```

**Shows:**
- Git status (modified files)
- Current branch and recent commits
- Hooks configuration status
- Project setup status

## 🎯 Quick Start Examples

**New Feature Development:**
```bash
/auto-flow pdf-merger
# Make your changes...
# Press Enter when ready
# Gets: branch + commit + PR automatically
```

**Bug Fix:**
```bash
/auto-branch memory-leak fix
# Fix the bug...
/auto-commit
/auto-pr
```

**Quick Commit:**
```bash
# Made some changes...
/auto-commit
# AI analyzes files and creates smart commit message
```

## 🧠 AI Intelligence Features

### Smart Commit Messages
- **File Analysis**: Detects what types of files changed
- **Pattern Recognition**: Recognizes PDF, image, auth, UI patterns  
- **Conventional Commits**: Follows `type(scope): description` format
- **Context Aware**: Understands project structure

### Smart PR Content
- **Title Generation**: Converts branch names to professional titles
- **Type Detection**: Determines if it's Feature, Bug Fix, Docs, etc.
- **Description Templates**: Includes summary, changes, testing checklist
- **Project Context**: Mentions Tauri, React, TypeScript when relevant

### Smart Branch Management
- **Clean Naming**: Converts any input to valid branch names
- **Auto Sync**: Always syncs with main before creating branches  
- **Type Prefixes**: Automatically adds feature/, fix/, docs/ prefixes
- **Conflict Prevention**: Checks for existing branches

## 🔧 Command Structure

Each command has:
- **`.md` file**: Documentation and usage examples
- **`.sh` file**: Executable script that calls the auto-workflow system
- **Help text**: Built-in help accessible via `/command --help`

## 📁 File Organization
```
.claude/commands/
├── README.md           # This file
├── auto-branch.md/.sh  # Smart branch creation
├── auto-commit.md/.sh  # AI-powered commits
├── auto-pr.md/.sh      # Smart pull requests
├── auto-flow.md/.sh    # Complete workflow
└── git-status.md/.sh   # Project status
```

## 🎯 Best Practices

1. **Use `/auto-flow`** for complete features
2. **Use `/auto-commit`** for quick changes
3. **Use `/auto-branch`** when you want manual control
4. **Use `/git-status`** to check project state
5. **Let AI generate content** - it's usually better than manual

## 🛠️ Customization

All commands call `.claude/hooks/auto-workflow.sh` which you can customize:
- Modify AI prompt templates
- Add new file pattern recognition
- Change commit message formats
- Customize PR description templates

## 🚨 Quality Assurance

All commands include:
- ✅ Pre-commit hooks (linting, testing, formatting)
- ✅ Branch protection (prevents direct commits to main)
- ✅ File size validation
- ✅ Sensitive data checking
- ✅ TypeScript validation

---

**💡 Pro Tip**: Use `/auto-flow` for 90% of your development work. It handles everything automatically while maintaining high code quality standards.