# streb Architecture Rules

## Provider Interface Pattern

All external system integrations MUST implement the Provider interface:

```go
type Provider interface {
    Name() string
    ValidateConfig(config map[string]interface{}) error
    TestConnection(ctx context.Context) error
    Provision(ctx context.Context, config *ProjectConfig) (*ProvisionResult, error)
    Rollback(ctx context.Context, result *ProvisionResult) error
}
```

## Installer Pattern

Tool installers follow this structure:
- `internal/installer/homebrew.go` - macOS package manager
- `internal/installer/winget.go` - Windows package manager
- `internal/installer/scoop.go` - Windows alternative
- `internal/installer/script.go` - Custom scripts

Each installer implements:
```go
type Installer interface {
    Name() string
    Available() bool
    Install(ctx context.Context, tool *Tool) error
    Uninstall(ctx context.Context, tool *Tool) error
    IsInstalled(tool *Tool) (bool, error)
}
```

## CLI Command Structure

Cobra commands go in `internal/cli/`:
- One file per command or command group
- Use `cmd.AddCommand()` for subcommands
- Validate inputs before execution
- Use Viper for configuration binding

## Configuration

- `.streb/config.yaml` - Project config
- `~/.streb/config.yaml` - Global config
- Environment variables override config files
- Use Viper's automatic env binding

## Performance Targets

Keep these in mind:
- CLI startup: < 100ms
- `streb status`: < 2s
- `streb init` (without downloads): < 30s

## Error Messages

- Clear, actionable error messages
- Include context: what failed, why, how to fix
- Use exit codes: 0=success, 1=error, 2=usage error
