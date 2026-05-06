---
description: Check current project, Beads, and git status
allowed-tools: Read, Grep, Glob, Bash
---

# Status

Quick overview of current project and task state.

## Beads Status

### In-Progress Tasks
!bd list --status in_progress 2>/dev/null || echo "Beads not initialized"

### Ready Tasks (Next Up)
!bd ready 2>/dev/null | head -5

### Blocked Tasks
!bd list --status blocked 2>/dev/null | head -3

### Statistics
!bd stats 2>/dev/null || echo "Run 'bd init' to initialize"

## Git Status

### Current Branch
!git branch --show-current 2>/dev/null

### Uncommitted Changes
!git status --short 2>/dev/null || echo "Not a git repository"

### Recent Commits
!git log --oneline -5 2>/dev/null

### Changed Files
!git diff --stat HEAD 2>/dev/null | head -5

## Project Info

### Project Type
![ -f "package.json" ] && echo "Node.js" && grep '"version"' package.json | head -1
![ -f "pyproject.toml" ] && echo "Python" && grep '^version' pyproject.toml | head -1
![ -f "Cargo.toml" ] && echo "Rust" && grep '^version' Cargo.toml | head -1
![ -f "go.mod" ] && echo "Go" && head -1 go.mod

## Infrastructure Tools

### Cloud CLIs
!command -v az >/dev/null && echo "✓ az (Azure)" && az account show --query name -o tsv 2>/dev/null || true
!command -v aws >/dev/null && echo "✓ aws (AWS)" && aws sts get-caller-identity --query Account --output text 2>/dev/null || true
!command -v gcloud >/dev/null && echo "✓ gcloud (GCP)" && gcloud config get-value project 2>/dev/null || true

### Git Platform CLIs
!command -v gh >/dev/null && [ -d ".github" ] && echo "✓ gh (GitHub)" && gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true
!command -v glab >/dev/null && [ -f ".gitlab-ci.yml" ] && echo "✓ glab (GitLab)" || true

### Kubernetes Tools
!command -v kubectl >/dev/null && echo "✓ kubectl" && kubectl config current-context 2>/dev/null || true
!command -v helm >/dev/null && echo "✓ helm" || true

### IaC Tools
!command -v terraform >/dev/null && [ -n "$(find . -maxdepth 2 -name '*.tf' 2>/dev/null | head -1)" ] && echo "✓ terraform" && terraform workspace show 2>/dev/null || true
!command -v pulumi >/dev/null && [ -f "Pulumi.yaml" ] && echo "✓ pulumi" || true

### Container Tools
!command -v docker >/dev/null && echo "✓ docker" && docker context show 2>/dev/null || true

## Summary

Report consolidated status:

```
## Project Status

### Beads
- In-progress: [count] tasks
- Ready: [count] tasks
- Blocked: [count] tasks

### Git
- Branch: [branch name]
- Uncommitted: [count] files
- Last commit: [summary]

### Infrastructure
- Cloud: [available CLIs with active account/project]
- K8s: [context if connected]
- IaC: [detected tools]

### Current Work
[If in-progress task exists, show it]

### Recommended Action
[Based on state: /next, /done, or continue current work]
```
