# Claude Code Configuration

This folder contains Claude Code configurations, agents, commands, and automation scripts installed by **streb**.

## What's Included

### Agents (`agents/`)

Specialized AI agents for different tasks:

| Agent | Purpose |
|-------|---------|
| `automation-engineer` | CI/CD and automation tasks |
| `code-reviewer` | Code quality and best practices review |
| `fixer` | Bug fixes tracked in Beads |
| `implementer` | Implements code changes for Beads tasks |
| `integration-architect` | System integration design |
| `investigator` | Analyzes code and gathers information |
| `qa-specialist` | Quality assurance and testing |
| `refactorer` | Refactors Go code for clarity |
| `reviewer` | Reviews code quality for Beads tasks |
| `technical-writer` | Documentation and technical writing |
| `test-writer` | Writes comprehensive tests |
| `tester` | Runs tests and reports results |

### Commands (`commands/`)

Slash commands organized by complexity:

#### Micro Commands (Quick, atomic tasks)
| Command | Usage |
|---------|-------|
| `/micro/build` | Build the project |
| `/micro/claim` | Claim a specific Beads task |
| `/micro/commit` | Create a well-formatted commit |
| `/micro/done` | Complete work, run quality gates, close task |
| `/micro/format` | Format code files |
| `/micro/lint` | Run linter with optional auto-fix |
| `/micro/next` | Find and start working on next available task |
| `/micro/review` | Quick code review |
| `/micro/status` | Check project, Beads, and git status |
| `/micro/test` | Run tests with optional coverage |

#### Mid Commands (Multi-step workflows)
| Command | Usage |
|---------|-------|
| `/mid/done` | Complete work, close Beads task, commit |
| `/mid/investigate` | Investigate a topic, bug, or codebase area |
| `/mid/pr` | Create a well-formatted pull request |
| `/mid/refactor` | Safely refactor code while preserving behavior |
| `/mid/review` | Code review for quality, patterns, and issues |
| `/mid/security-review` | Security analysis with compliance reporting |
| `/mid/test` | Run tests with analysis of results |

#### Macro Commands (Complex, multi-phase workflows)
| Command | Usage |
|---------|-------|
| `/macro/code-quality-review` | Comprehensive code quality review |
| `/macro/fix-bugs` | Autonomously fix bugs from Beads |
| `/macro/implement-feature` | Implement features from Beads hierarchy |
| `/macro/plan-epic` | Create a Beads epic from specifications |
| `/macro/release` | Execute release workflow |
| `/macro/research-to-requirements` | Process documents to requirements |
| `/macro/security-review` | Security review with domain-based iteration |

#### Ralph Commands (Generate autonomous loop commands)
| Command | Usage |
|---------|-------|
| `/ralph/bugfix` | Generate command for bug fix sprint |
| `/ralph/epic` | Generate command for epic execution |
| `/ralph/migrate` | Generate command for codebase migration |
| `/ralph/tdd` | Generate command for TDD development |

#### Headless Commands (Unattended execution)
| Command | Usage |
|---------|-------|
| `/headless/bugfix` | Run headless bug fix sprint |
| `/headless/code-quality` | Run headless code quality review |
| `/headless/epic` | Run headless epic execution |
| `/headless/migrate` | Run headless codebase migration |
| `/headless/research` | Run headless research to requirements |
| `/headless/security-review` | Run headless security review |

### Rules (`rules/`)

Coding standards and safety rules:
- `git-safety.md` - Git commit and branch safety rules
- `go-conventions.md` - Go code style guidelines
- `security.md` - Security best practices
- `streb-architecture.md` - Project architecture patterns

### Scripts (`scripts/ralph/`)

Shell scripts for headless Ralph loops:
- `epic.sh` - Execute Beads epic tasks
- `bugfix.sh` - Fix bugs in priority order
- `migrate.sh` - Codebase migration
- `security-review.sh` - Security analysis
- `code-quality.sh` - Code quality review
- `research.sh` - Document processing
- `common.sh` - Shared utilities

---

## Updating streb Configuration

To update your streb installation and Claude Code configuration:

```bash
# Upgrade streb itself to the latest version
streb upgrade

# Update bundled tools (Claude Code, Beads, Beads UI)
streb update

# Check for tool updates without installing
streb update --check

# Re-run initialization to update templates
streb init
```

The `streb update` command will update:
- Claude Code CLI
- Beads (`bd`) CLI
- Beads UI (`bdui`)

The `streb upgrade` command updates streb itself.

---

## Ralph Loops

Ralph loops enable autonomous, multi-iteration task execution. See [docs/ralph-loop-guide.md](docs/ralph-loop-guide.md) for the complete guide.

### Quick Reference

**Interactive Mode** (monitor in current session):
```bash
/ralph/epic bd-abc123      # Execute epic tasks
/ralph/bugfix              # Fix bugs in priority order
/ralph/tdd bd-xyz789       # Test-driven development
/ralph/migrate "desc"      # Codebase migration
```

**Headless Mode** (unattended, fresh context each iteration):
```bash
/headless/epic bd-abc123 -n 50       # 50 iterations max
/headless/bugfix -n 30               # Bug fixes
/headless/security-review ./src      # Security review
/headless/code-quality ./internal    # Code quality
```

**Direct Script Execution** (from terminal):
```bash
./.claude/scripts/ralph/epic.sh bd-abc123 -n 50
./.claude/scripts/ralph/bugfix.sh -n 30
./.claude/scripts/ralph/migrate.sh "Convert to async" "src/**/*.ts"
```

### When to Use Each Mode

| Scenario | Mode | Why |
|----------|------|-----|
| Watch progress in real-time | Interactive | Real-time visibility |
| Run overnight unattended | Headless | Fresh context each iteration |
| Small task (5-10 iterations) | Interactive | Quick, easy monitoring |
| Large task (50+ iterations) | Headless | Avoids context limits |
| Debug a workflow | Interactive | See exactly what happens |
| Parallel tasks | Headless | Run in separate terminals |

### Exit Conditions

| Signal | Meaning | Action |
|--------|---------|--------|
| `COMPLETE` | All work done | Success! |
| `BLOCKED` | Human decision needed | Check `activity.md`, decide, re-run |
| `STUCK` | No progress | Manual investigation needed |
| `MAX_ITERATIONS` | Hit limit | Re-run with higher `-n` |

---

## Troubleshooting

### AI-Hub API Key Issues

If Claude Code isn't connecting to the adesso AI-Hub:

1. **Check your global settings file:**
   ```
   ~/.claude/settings.json
   ```

2. **Verify the configuration contains:**
   ```json
   {
     "apiKeyHelper": "~/.claude/get-api-key.sh",
     "env": {
       "ANTHROPIC_BASE_URL": "https://adesso-ai-hub.3asabc.de",
       "DISABLE_PROMPT_CACHING": "1"
     }
   }
   ```

3. **Check the API key helper script exists:**
   ```bash
   cat ~/.claude/get-api-key.sh
   ```

4. **Verify the key is approved in Claude's config:**
   ```bash
   cat ~/.claude.json
   # Look for your key in customApiKeyResponses.approved
   ```

5. **Test the connection:**
   ```bash
   streb doctor
   ```

6. **Reconfigure if needed:**
   ```bash
   streb init
   # Select "adesso AI-Hub" when prompted
   ```

### "bd command not found"

Install and configure Beads:
```bash
streb install bd
bd onboard
```

### Script Permission Issues

If headless scripts fail with permission errors:
```bash
chmod +x .claude/scripts/ralph/*.sh
```

### Plugins Not Loading

Check plugin status:
```bash
streb status
```

Re-install plugins:
```bash
streb init --reinstall-plugins
```

---

## Related Projects

| Project | Description | Repository |
|---------|-------------|------------|
| **Beads** | Git-backed issue tracker for AI-assisted development | [github.com/steveyegge/beads](https://github.com/steveyegge/beads) |
| **Beads UI** | Visual task management interface for Beads | [npmjs.com/package/beads-ui](https://www.npmjs.com/package/beads-ui) |
| **Dagger** | Programmable CI/CD engine | [dagger.io](https://dagger.io) |
| **streb** | Developer environment bootstrapper | [github.com/adesso-ai/homebrew-streb](https://github.com/adesso-ai/homebrew-streb) |

---

## File Structure

```
.claude/
├── README.md                    # This file
├── settings.json                # Project-level Claude Code settings
├── agents/                      # Specialized AI agents
├── commands/
│   ├── headless/               # Unattended execution commands
│   ├── macro/                  # Complex multi-phase workflows
│   ├── micro/                  # Quick atomic tasks
│   ├── mid/                    # Multi-step workflows
│   └── ralph/                  # Autonomous loop generators
├── docs/
│   └── ralph-loop-guide.md     # Complete Ralph loop documentation
├── hooks/                       # Pre/post command hooks
├── rules/                       # Coding standards and safety rules
└── scripts/
    └── ralph/                   # Headless execution scripts
```

---

## Getting Help

- Run `streb doctor` for environment diagnostics
- Run `streb status` for a quick overview
- Check [strebcli.dev](https://strebcli.dev) for documentation
- Report issues at [github.com/adesso-ai/homebrew-streb/issues](https://github.com/adesso-ai/homebrew-streb/issues)
