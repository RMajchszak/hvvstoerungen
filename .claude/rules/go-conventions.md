---
globs:
  - "**/*.go"
---

# Go Code Conventions for streb

## Error Handling

- Always handle errors; never use `_` to ignore them
- Wrap errors with context: `fmt.Errorf("failed to %s: %w", action, err)`
- Return errors early; avoid deep nesting
- Use custom error types for domain errors:
  ```go
  type NotFoundError struct {
      Resource string
  }
  func (e *NotFoundError) Error() string {
      return fmt.Sprintf("%s not found", e.Resource)
  }
  ```

## Naming

- Use mixedCaps, not snake_case
- Acronyms should be all caps: `HTTP`, `URL`, `ID`
- Interface names describe behavior: `Reader`, `Installer`
- Avoid stuttering: `config.Config` not `config.ConfigStruct`

## Package Structure

```
internal/
  cli/         # Cobra commands
  config/      # Configuration loading
  installer/   # Tool installation
  platform/    # OS-specific code
  tools/       # Tool management
```

## Testing

- Use testify for assertions
- Table-driven tests for multiple cases
- Test file next to source: `foo.go` -> `foo_test.go`
- Use `t.Helper()` for test helper functions

## Dependencies

- Use Cobra for CLI commands
- Use Viper for config (already integrated with Cobra)
- Use Bubble Tea for TUI elements
- Prefer standard library when possible

## Platform Code

- Use build tags: `//go:build darwin` or `//go:build windows`
- Put platform code in `internal/platform/{darwin,windows,linux}/`
- Always provide fallback behavior
