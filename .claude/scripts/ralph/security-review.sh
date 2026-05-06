#!/bin/bash
# .claude/scripts/ralph/security-review.sh
# Headless Ralph Wiggum loop for security reviews
#
# Usage: ./.claude/scripts/ralph/security-review.sh <path> [--scope <full|api|auth|data|deps>] [--compliance <owasp|pci|hipaa|soc2>] [-n max-iterations]
# Example: ./.claude/scripts/ralph/security-review.sh ./internal --scope api --compliance owasp -n 30

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") <path> [options]

Perform comprehensive security review of a codebase path.

Arguments:
    path                Path to review (directory, file, or glob pattern)

Options:
    --scope             Focus area: full (default), api, auth, data, deps
    --compliance        Framework: owasp (default), pci, hipaa, soc2
    -n, --max-iterations    Maximum iterations (default: 30)
    -h, --help              Show this help message

Examples:
    $(basename "$0") ./internal
    $(basename "$0") ./internal --scope api
    $(basename "$0") ./internal --scope auth --compliance soc2
    $(basename "$0") ./internal --compliance pci -n 50

Security Domains Reviewed:
    - Authentication & Authorization
    - Input Validation & Injection
    - Data Protection
    - Dependency Security
    - API Security
    - Configuration Security
    - Error Handling & Logging

Notes:
    - Reviews one security domain per iteration
    - Outputs findings with file:line references
    - Exit codes: 0=complete, 1=max iterations, 2=blocked (critical finding), 3=stuck
EOF
}

# Parse arguments
TARGET_PATH=""
SCOPE="full"
COMPLIANCE="owasp"
MAX_ITERATIONS=30

while [[ $# -gt 0 ]]; do
    case $1 in
        --scope)
            SCOPE="$2"
            shift 2
            ;;
        --compliance)
            COMPLIANCE="$2"
            shift 2
            ;;
        -n|--max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$TARGET_PATH" ]; then
                TARGET_PATH="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$TARGET_PATH" ]; then
    log_error "Target path is required"
    show_help
    exit 1
fi

# Validate path exists
if [ ! -e "$TARGET_PATH" ]; then
    log_error "Path does not exist: $TARGET_PATH"
    exit 1
fi

log_info "Security Review: $TARGET_PATH"
log_info "Scope: $SCOPE"
log_info "Compliance Framework: $COMPLIANCE"
log_info "Max iterations: $MAX_ITERATIONS"

# Build the prompt
PROMPT="Security Review of $TARGET_PATH:

## Context
Performing comprehensive security review with focus on $SCOPE scope.
Compliance framework: $COMPLIANCE
This is a HEADLESS session - be thorough and document all findings.

## Pre-flight
1. Check activity.md for any previous security review progress
2. Scan codebase structure to understand:
   - Technology stack (languages, frameworks)
   - Entry points (API routes, CLI handlers)
   - Authentication layer location
   - Configuration files
   - Secret handling patterns

## Security Domains to Review

Based on scope '$SCOPE':
$(case $SCOPE in
    full) echo "- All 7 domains in order";;
    api) echo "- API Security, Auth, Input Validation (primary)
- Config, Error Handling (secondary)";;
    auth) echo "- Auth, Error Handling (primary)
- API Security (secondary)";;
    data) echo "- Data Protection, Input Validation, Dependencies (primary)
- Config (secondary)";;
    deps) echo "- Dependency Security (primary)
- Config (secondary)";;
esac)

## Domain Details

**Domain 1: Authentication & Authorization**
- Session management, tokens, RBAC, OAuth
- Credential storage, password policies
- JWT validation, CSRF protection
- Red flags: hardcoded credentials, missing token expiration

**Domain 2: Input Validation & Injection**
- SQL injection, XSS, command injection, path traversal
- Input sanitization, type validation
- Red flags: string concatenation in queries, eval() with user input

**Domain 3: Data Protection**
- Encryption at rest/transit, PII handling
- Secrets management, key rotation
- Red flags: plaintext secrets, weak hashing (MD5/SHA1)

**Domain 4: Dependency Security**
- CVEs, outdated packages, supply chain risks
- Version pinning, transitive dependencies
- Red flags: known vulnerabilities, floating versions

**Domain 5: API Security**
- Rate limiting, CORS, authentication enforcement
- Input validation on endpoints
- Red flags: unauthenticated endpoints, CORS *, no rate limiting

**Domain 6: Configuration Security**
- Hardcoded secrets, debug modes
- Security headers (CSP, HSTS, X-Frame-Options)
- Red flags: debug=True in prod, secrets in config files

**Domain 7: Error Handling & Logging**
- Information disclosure, sensitive data in logs
- Stack trace exposure
- Red flags: stack traces to users, passwords in logs

## Compliance: $COMPLIANCE
$(case $COMPLIANCE in
    owasp) echo "Cross-reference findings with OWASP Top 10 (2021) and CWE";;
    pci) echo "Focus on PCI-DSS Requirements 2,3,6,8 - cardholder data protection";;
    hipaa) echo "Focus on PHI handling, audit logs, encryption requirements";;
    soc2) echo "Focus on Trust principles - access controls, monitoring";;
esac)

## Finding Format
For each finding, record:
- Severity: CRITICAL/HIGH/MEDIUM/LOW/INFO
- Domain: which security domain
- Location: file:line
- CWE/OWASP reference
- Description and evidence (REDACT actual secrets)
- Remediation recommendation

## Exit Conditions
- <promise>SECURITY_REVIEW_COMPLETE</promise> when all in-scope domains reviewed
- <promise>MUST_ASK_CRITICAL</promise> if critical vulnerability found requiring immediate decision
- <promise>BLOCKED</promise> if cannot proceed without external input
- <promise>STUCK</promise> if same analysis fails 3+ times

## Important
- NEVER output actual secret values - redact and show location only
- NEVER provide executable exploit code
- Document all findings with file:line references
- Include positive findings (security done well)
"

# Run the loop
run_ralph_loop "$PROMPT" "SECURITY_REVIEW_COMPLETE" "$MAX_ITERATIONS"
exit_code=$?

case $exit_code in
    0)
        log_success "Security review complete: $TARGET_PATH"
        ;;
    1)
        log_warning "Max iterations reached. Review may be incomplete."
        ;;
    2)
        log_warning "Review blocked. Critical finding may need immediate attention."
        log_info "Check activity.md for details."
        ;;
    3)
        log_error "Review stuck. Manual intervention needed."
        ;;
esac

exit $exit_code
