# Claude Code Best Practices Templates

This directory contains templates for setting up Claude Code with best practices.
These files are copied by `streb init` to set up a new project.

## Structure

```
templates/
├── CLAUDE.md                      # Main project instructions
├── CLAUDE.local.md.template       # Template for personal preferences
├── .mcp.json                      # MCP server configuration
└── .claude/
    ├── .gitignore                 # Excludes local files from git
    ├── settings.json              # Permissions, hooks, safety rules
    ├── rules/
    │   ├── git-safety.md          # Git workflow rules
    │   └── security.md            # Security best practices
    ├── commands/
    │   ├── commit.md              # /commit - Create conventional commits
    │   ├── pr.md                  # /pr - Create pull requests
    │   ├── review.md              # /review - Code review
    │   ├── next.md                # /next - Find next task (beads)
    │   └── done.md                # /done - Complete work
    └── agents/
        ├── code-reviewer.md       # Code review specialist
        ├── test-writer.md         # Test writing specialist
        └── refactorer.md          # Refactoring specialist
```

## What's Included

### CLAUDE.md
Concise project instructions covering:
- Beads workflow integration
- Code quality expectations
- Git discipline
- Session close protocol

### Settings (settings.json)
- **Permissions**: Safe defaults for common dev commands
- **Deny rules**: Protect secrets and prevent destructive operations
- **Hooks**:
  - SessionStart: Initialize beads
  - PreToolUse: Block writes to sensitive files
  - Stop: Sync beads state

### Rules (.claude/rules/)
Modular instruction files:
- **git-safety.md**: Commit protocols, amend rules, branch workflow
- **security.md**: OWASP prevention, input validation, secret handling

### Slash Commands (.claude/commands/)
- **/commit**: Create well-formatted conventional commits
- **/pr**: Create pull requests with proper descriptions
- **/review**: Comprehensive code review
- **/next**: Find and claim next available task from beads
- **/done**: Complete work, commit, close task, sync

### Agents (.claude/agents/)
- **code-reviewer**: Quality, security, performance review
- **test-writer**: Comprehensive test creation
- **refactorer**: Safe code improvement

### MCP Servers (.mcp.json)
- Filesystem server for extended file operations

## Usage by streb

When `streb init` runs:
1. Copies all templates to the target project
2. Initializes beads if not present (`bd init`)
3. Installs official Claude Code plugins (ralph-loop, etc.)
4. Runs `bd prime` to load context

## Customization

After setup, teams can:
- Add project-specific rules to `.claude/rules/`
- Create custom commands in `.claude/commands/`
- Add domain-specific agents in `.claude/agents/`
- Extend CLAUDE.md with project overview and conventions
