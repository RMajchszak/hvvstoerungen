---
globs:
  - "**/*.go"
  - "**/*.sh"
---

# Security Rules

## Never Access Sensitive Files

Do NOT read, write, or edit:
- `.env` files
- `*.pem`, `*.key` files
- `*secret*`, `*credential*`, `*password*` files
- Vault tokens or API keys

## Command Execution Safety

When using `exec.Command`:
- NEVER pass unsanitized user input to commands
- Use argument arrays, not shell strings
- Validate paths before file operations

```go
// GOOD - arguments are separate
cmd := exec.Command("git", "clone", repoURL)

// BAD - shell interpretation possible
cmd := exec.Command("sh", "-c", "git clone " + repoURL)
```

## Path Safety

- Always use `filepath.Clean()` on user paths
- Check for path traversal (`..`)
- Validate paths are within expected directories

```go
// GOOD
cleanPath := filepath.Clean(userPath)
if !strings.HasPrefix(cleanPath, baseDir) {
    return fmt.Errorf("path outside allowed directory")
}
```

## Credential Storage

- Use the repository's file-based credential helpers with restrictive permissions
- Never log credentials
- Clear sensitive data after use
- Use Vault paths for credential storage

## Output Sanitization

- Mask secrets in logs and output
- Don't include full paths in error messages for sensitive files
- Sanitize user input before displaying
