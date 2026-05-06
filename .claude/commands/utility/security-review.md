---
description: Comprehensive security analysis of code with domain-based iteration and compliance reporting
argument-hint: <path> [--scope <domains>] [--compliance <framework>]
allowed-tools: Read, Grep, Glob, Bash
---

# Security Review

Execute comprehensive security analysis on: **$PATH**

This command follows the Ralph Wiggum pattern with 7-domain iteration and structured CWE reporting.

## Input Validation

**Required Arguments:**
- `$PATH` - Directory or file to review (validate exists and accessible)

**Optional Flags:**
- `--scope <domains>` - Comma-separated domains to scan (default: all)
  - Example: `--scope auth,injection,secrets`
- `--compliance <framework>` - Map findings to compliance framework
  - Supported: `pci-dss`, `hipaa`, `gdpr`, `owasp-top-10`, `cwe-top-25`
  - Default: None (findings only)

**Path Validation:**
```bash
[ -d "$PATH" ] || [ -f "$PATH" ] || exit "BLOCKED:RUNTIME - Path not accessible: $PATH"
```

## Architecture Overview

```
INITIALIZE
├── Validate path and permissions
├── Parse --scope and --compliance flags
├── Initialize finding accumulator
├── Set iteration limits (max 7 for domains)
└── Load domain definitions
     │
     ▼
DOMAIN_ITERATION (repeat for each domain)
├── Select domain (AUTH → INJECT → SECRETS → CRYPT → DEPS → CONFIG → LOGIC)
├── ASSESS current domain findings
├── PLAN search patterns
├── EXECUTE scans via Grep/Glob/Read
├── EVALUATE findings against severity
├── Accumulate with CWE/CVSS references
└── Check exit conditions
     │
     ├─→ Finding is CRITICAL/ambiguous? → MUST_ASK
     ├─→ Path inaccessible? → BLOCKED:RUNTIME
     ├─→ All domains complete? → Continue to FINALIZE
     └─→ Domain limit exceeded? → STUCK
     │
     ▼
FINALIZE
├── Generate structured report
├── Apply compliance mappings
├── Redact secrets from output
├── Calculate risk score
└── Exit with <promise>COMPLETE</promise>
```

## Design Decisions & Rationale

### 1. Domain Iteration Model: Sequential with Per-Domain Depth

**Decision:** Process all 7 domains sequentially in one command execution.

**Rationale:**
- **Comprehensive:** Covers all security areas in single run
- **Predictable:** Users know exactly what will be scanned
- **Parallelizable:** Domains are independent - future enhancement to process in parallel
- **Scope management:** `--scope` flag allows filtering to specific domains
- **State tracking:** Easy to accumulate findings across domains

**Alternative Considered:** One domain per Ralph Wiggum iteration
- ❌ Would require 7 separate invocations (poor UX)
- ❌ Difficult to calculate overall risk score
- ❌ Hard to maintain finding accumulator across invocations

### 2. Finding Accumulation Strategy: Structured Map by Domain

**Architecture:**
```yaml
findings:
  auth:
    - id: "AUTH-001"
      cwe: 287  # CWE-287: Improper Authentication
      severity: CRITICAL
      location: "src/auth.js:42"
      description: "..."
      evidence: "..."
      remediation: "..."
      compliance:
        pci-dss: ["6.5.10"]
        owasp-top-10: ["A7:2021"]
  injection:
    - id: "INJ-001"
      cwe: 89  # CWE-89: SQL Injection
      severity: CRITICAL
      ...
  # ... (other domains)
```

**Benefits:**
- Clear domain organization
- Enables filtering by domain or severity
- Facilitates compliance mapping
- Supports incremental reporting

### 3. Scope Filtering: Domain Selection Pre-Processing

**When `--scope auth,secrets` is specified:**
```
1. Parse comma-separated domain list
2. Validate domains exist (AUTH, INJECT, SECRETS, CRYPT, DEPS, CONFIG, LOGIC)
3. Filter domain_iterator to only requested domains
4. Process filtered domains sequentially
5. Report contains only requested domains + summary
```

**Example:**
```bash
/security-review /app --scope secrets,deps
# Only scans: SECRETS domain, DEPS domain
# Skips: AUTH, INJECT, CRYPT, CONFIG, LOGIC
# Result: Faster execution, focused report
```

### 4. Tool Requirements: Read/Grep/Glob/Bash

**Read:**
- Load source files for manual inspection of suspicious patterns
- Examine config files for hardcoded credentials
- Review comments for hints about security concerns
- Read package.json/requirements.txt for dependency analysis

**Grep:**
- Pattern matching for common vulnerability signatures:
  - SQL injection patterns: `SELECT.*\$|eval\(|exec\(`
  - Auth bypass: `if.*token|if.*password` (logic patterns)
  - Secrets: `api_key=|password:|AWS_|SECRET_`
  - Cryptography: `md5\(|SHA1\(|random\(`
  - Unsafe dependencies: `require.*lodash.*4\.[01]\.|pickle\.`

**Glob:**
- Find config files: `**/config.*.js`, `**/.env*`, `**/docker-compose.yml`
- Find secrets files: `**/private*`, `**/.key`, `**/credentials*`
- Find test files: `**/*.test.js`, `**/*_test.go`
- Identify framework markers: `**/package.json`, `**/go.mod`, `**/Cargo.toml`

**Bash:**
- Run security-specific tools if available:
  - `npm audit` for npm dependencies
  - `pip check` for Python dependencies
  - `cargo audit` for Rust dependencies
  - `git log --follow` for secret commit history
- File system checks: permissions, ownership, symlink traversal
- Calculate metrics and statistics

### 5. Secret Redaction: Three-Layer Strategy

**Layer 1 - Redaction in Processing:**
```python
# When reading findings, immediately redact:
REDACT_PATTERNS = [
    r'(api[_-]?key\s*[:=]\s*)["\']?([^"\'\\s]+)',
    r'(password\s*[:=]\s*)["\']?([^"\'\\s]+)',
    r'(token\s*[:=]\s*)["\']?([^"\'\\s]+)',
    r'(secret\s*[:=]\s*)["\']?([^"\'\\s]+)',
    r'(AWS_SECRET|PRIVATE_KEY|credentials)',
]

# Replace with: "[REDACTED]"
```

**Layer 2 - Evidence Sanitization:**
```yaml
evidence: |
  Found in config file: database_url="[REDACTED]"
  Pattern: database credentials hardcoded
  (Full value redacted for security)
```

**Layer 3 - Output Filtering:**
```bash
# Before generating report:
# - Strip passwords from code examples
# - Remove API keys from stack traces
# - Mask email addresses in findings
# - Redact commit hashes containing secrets
```

**Notification:** Report includes count of redacted items:
```
⚠️  5 potentially sensitive values redacted from evidence sections
```

### 6. Compliance Framework Mapping: Multi-Standard Support

**Data Structure:**
```yaml
compliance_mappings:
  pci-dss:
    AUTH:
      mapping: "Requirement 6.5.10: Broken authentication"
      applicable_findings: [AUTH-001, AUTH-003]
    SECRETS:
      mapping: "Requirement 3.2.1: Strong cryptography"
      applicable_findings: [SEC-002]

  owasp-top-10:
    AUTH:
      mapping: "A07:2021 – Broken Authentication"
      applicable_findings: [AUTH-001, AUTH-003]
    INJECT:
      mapping: "A03:2021 – Injection"
      applicable_findings: [INJ-001, INJ-002]
```

**Runtime Process:**
```
1. If --compliance flag not provided:
   - Generate findings-only report

2. If --compliance framework specified:
   a. Load compliance_mappings[framework]
   b. For each finding, determine applicable requirements
   c. Add "compliance" section to finding
   d. Generate compliance summary in report
```

**Example Output Section:**
```
## Compliance Mapping

### PCI-DSS v3.2.1 Coverage
- [x] Requirement 6.5.10: AUTH-001 (CRITICAL) - Broken authentication
- [x] Requirement 3.2.1: SEC-002 (HIGH) - Weak encryption
- [ ] Requirement 4.1: No findings related to encryption in transit

**Coverage: 2/3 requirements with findings (66%)**
```

## The 7 Security Domains

### Domain 1: AUTH (Authentication & Authorization)

**Purpose:** Verify identity verification and access control

**Search Patterns:**
- Missing authentication checks
- Hardcoded credentials
- Token validation bypass
- Default credentials
- Insufficient password policies
- Session management flaws

**Key Patterns:**
```bash
# No auth check
grep -r "if.*request\.auth" --include="*.js"
grep -r "@requires_login\|@login_required" --include="*.py" | wc -l

# Hardcoded creds (already covered in SECRETS, but check context)
grep -r "password.*=.*['\"].*['\"]" --include="*.js"

# JWT issues
grep -r "jwt\|Bearer\|token" --include="*.js" | grep -i "decode\|verify"
```

**CWE References:**
- CWE-287: Improper Authentication
- CWE-290: Authentication with Hard-Coded Credentials
- CWE-384: Session Fixation
- CWE-613: Insufficient Session Expiration

### Domain 2: INJECT (Code & Command Injection)

**Purpose:** Detect injection vulnerabilities (SQL, Command, Template)

**Search Patterns:**
- Dynamic SQL without parameterization
- Command execution with user input
- Template injection
- LDAP injection
- OS command injection
- No input validation

**Key Patterns:**
```bash
# SQL injection risks
grep -r "SELECT.*\+" --include="*.js" | grep -v "prepared\|parameterized"
grep -r "execute.*f\"" --include="*.py"
grep -r "sql\(.*\+\)" --include="*.rb"

# Command injection
grep -r "exec\|system\|popen" --include="*.py" | grep -v "subprocess"
grep -r "eval\|exec\|spawn" --include="*.js"

# Template injection
grep -r "render.*request\|render.*user" --include="*.py"
grep -r "template.*eval\|template.*render" --include="*.js"
```

**CWE References:**
- CWE-89: SQL Injection
- CWE-78: Improper Neutralization of Special Elements used in an OS Command
- CWE-94: Improper Control of Generation of Code
- CWE-1336: Improper Neutralization of Special Elements Used in a Template Engine

### Domain 3: SECRETS (Hardcoded Secrets & Credentials)

**Purpose:** Identify exposed credentials, API keys, tokens

**Search Patterns:**
- API keys in code
- Private keys in repositories
- Database passwords
- AWS credentials
- JWT tokens
- .env files with secrets
- Comments revealing secrets
- Secrets in version control history

**Key Patterns:**
```bash
# Obvious patterns
grep -ri "api.key\|api_key\|apikey" --include="*.py" --include="*.js"
grep -ri "secret\|password\|passwd" --include="*.env*" --include="*.config.*"
grep -ri "aws_access_key\|AWS_SECRET" --include="*.sh" --include="*.yml"

# AWS credentials
grep -r "AKIA" --include="*.txt" --include="*.py" --include="*.js"

# Private keys
grep -r "BEGIN RSA PRIVATE KEY\|BEGIN PRIVATE KEY" --include="*.pem" --include="*.key"

# Database URLs
grep -r "mongodb://\|postgres://\|mysql://" --include="*.js" --include="*.py"

# JWT patterns
grep -r "eyJ[A-Za-z0-9_-]*\." --include="*.js" --include="*.py"
```

**CWE References:**
- CWE-798: Use of Hard-Coded Credentials
- CWE-759: Use of a One-Way Hash with a Predictable Salt
- CWE-760: Use of a One-Way Hash with a Predictable Salt
- CWE-214: Invocation of Process Using Visible Sensitive Information

### Domain 4: CRYPT (Cryptography & Hashing)

**Purpose:** Evaluate crypto implementation and key management

**Search Patterns:**
- Weak hashing (MD5, SHA1)
- Weak encryption (DES, RC4)
- Hard-coded encryption keys
- Missing encryption for sensitive data
- Insecure random number generation
- Insufficient key length

**Key Patterns:**
```bash
# Weak hashing
grep -ri "md5\|sha1" --include="*.py" --include="*.js" --include="*.java"
grep -ri "md5\|SHA.1" --include="*.go"

# Weak encryption
grep -ri "des\|rc4\|cbc" --include="*.py" --include="*.js"

# Hard-coded keys
grep -r "key.*=.*\".*\"" --include="*.py" | grep -i "secret\|private"

# Weak random
grep -ri "random\(\)\|Math.random\|rand\(\)" --include="*.py" --include="*.js"

# Crypto imports
grep -r "from crypto import\|import hashlib\|require('crypto')" --include="*.py" --include="*.js"
```

**CWE References:**
- CWE-326: Inadequate Encryption Strength
- CWE-327: Use of a Broken or Risky Cryptographic Algorithm
- CWE-330: Use of Insufficiently Random Values
- CWE-916: Use of Password Hash With Insufficient Computational Effort

### Domain 5: DEPS (Dependency Security)

**Purpose:** Identify vulnerable or suspicious dependencies

**Search Patterns:**
- Known vulnerable packages
- Outdated dependencies
- Malicious packages
- Unmaintained dependencies
- License conflicts
- Transitive dependency issues

**Key Patterns:**
```bash
# Package manifest files
find . -name "package.json" -o -name "requirements.txt" -o -name "Gemfile" -o -name "go.mod"

# Run dependency scanners (if available)
npm audit --json 2>/dev/null
pip check 2>/dev/null
cargo audit --json 2>/dev/null

# Manual inspection
grep -r "lodash" package.json | grep -E "4\.[01]\..*"  # Known vulnerable versions
grep -r "serialize-javascript" package.json | grep -E "[0-2]\."  # RCE vulnerability
```

**CWE References:**
- CWE-1035: 2017 Top 10 A9: Using Components with Known Vulnerabilities
- CWE-937: OWASP Top 10 2013 A9: Using Components with Known Vulnerabilities
- CWE-1021: Improper Restriction of Rendered UI Layers or Frames

### Domain 6: CONFIG (Configuration & Deployment Security)

**Purpose:** Verify secure configuration practices

**Search Patterns:**
- Debug mode enabled in production
- Insecure CORS settings
- Missing security headers
- Insecure cookies (no HttpOnly, Secure)
- SQL error messages exposed
- Stack traces in responses
- Unencrypted communication
- Insecure deserialization settings

**Key Patterns:**
```bash
# Debug/dev settings
grep -ri "debug.*true\|development\|localhost" --include="*.config.*" --include="*.py"
grep -r "DEBUG\|ENV.*=.*development" --include=".env*" --include="Dockerfile"

# CORS issues
grep -ri "cors.*\*\|Access-Control.*\*" --include="*.js" --include="*.py"

# Security headers missing
grep -r "X-Frame-Options\|X-Content-Type-Options\|Strict-Transport-Security" --include="*.js" | wc -l

# Cookie settings
grep -ri "httponly\|secure" --include="*.js" | grep -i "cookie" | wc -l

# Deserialization
grep -ri "pickle\|serialize\|unmarshal" --include="*.py" | grep -v "json"
```

**CWE References:**
- CWE-16: Configuration
- CWE-693: Protection Mechanism Failure
- CWE-829: Inclusion of Functionality from Untrusted Control Sphere
- CWE-248: Uncaught Exception

### Domain 7: LOGIC (Business Logic & Input Validation)

**Purpose:** Evaluate business logic security and input validation

**Search Patterns:**
- Missing input validation
- Race conditions
- Privilege escalation
- Information disclosure
- Insecure direct object references (IDOR)
- Missing access controls
- Type confusion
- Logic bypasses

**Key Patterns:**
```bash
# Input validation
grep -r "request\.\|input\.\|get\(" --include="*.py" | grep -v "strip\|sanitize\|validate"
grep -r "params\[\|req\.body\.\|argv\[" --include="*.js" | grep -v "validate\|check"

# ID handling (IDOR risk)
grep -r "user_id\|userId\|user\.id" --include="*.py" --include="*.js" | grep -i "request\|param"

# Access control
grep -r "if.*admin\|if.*role\|if.*permission" --include="*.py" --include="*.js" | wc -l

# Race condition indicators
grep -r "lock\|mutex\|atomic" --include="*.go" --include="*.rs" | wc -l
```

**CWE References:**
- CWE-20: Improper Input Validation
- CWE-639: Authorization Bypass Through User-Controlled Key
- CWE-862: Missing Authorization
- CWE-863: Incorrect Authorization

## Exit Conditions

### COMPLETE
When all requested domains have been scanned and report is generated:

```
## COMPLETE

<promise>COMPLETE</promise>

### Security Review Summary

**Target:** $PATH
**Domains Scanned:** $DOMAIN_COUNT / 7
**Total Findings:** $TOTAL

#### Severity Distribution
- CRITICAL: $CRIT_COUNT
- HIGH: $HIGH_COUNT
- MEDIUM: $MED_COUNT
- LOW: $LOW_COUNT
- INFO: $INFO_COUNT

#### Risk Score: $RISK (1-10)

### Key Findings
1. [Highest severity finding]
2. [Second highest]
3. [Third highest]

[Full report follows - see Report Structure section]
```

### BLOCKED: Path Inaccessible
When path cannot be accessed or is invalid:

```
## BLOCKED

<promise>BLOCKED</promise>

### Blocker
Path not accessible: $PATH

### Details
- Error: [stat/permission error]
- Attempted: [what was tried]

### Required to Unblock
- Verify path exists and is readable
- Check file permissions
- Ensure path is a file or directory
```

### BLOCKED: Critical Finding Requires Decision
When CRITICAL severity finding requires human decision:

```
## BLOCKED

<promise>BLOCKED</promise>

### MUST_ASK: Critical Finding Requires Decision

**Finding:** [description]

**Location:** [file:line]

**Risk:** [what could happen]

**Options:**
1. [Accept risk] - Proceed to complete scan, document exception
2. [Fix immediately] - Pause scan, fix issue, resume
3. [Defer] - Create issue in Beads, continue scan

**Recommendation:** [professional security recommendation]
```

### STUCK: Exceeded Iteration Limit
When domain iteration exceeds safety threshold:

```
## STUCK

<promise>STUCK</promise>

### Stuck Pattern
Domain iteration exceeded safety threshold (max 7 domains).

### Domains Processed
- [Domain 1]: N findings
- [Domain 2]: N findings
- ...

### Incomplete Domains
- [Domain X]: [reason - typically indicates infinite recursion in pattern matching]

### Action Taken
Scan terminated for safety. Processed domains above included in report.
```

## Report Structure

```markdown
# Security Review Report

**Target Path:** $PATH
**Scan Date:** $DATE
**Domains Requested:** $SCOPE (or all)
**Compliance Framework:** $COMPLIANCE (or none)

---

## Executive Summary

### Overall Risk Assessment
- **Risk Score:** $SCORE/10 (color-coded)
- **Verdict:** 🟢 LOW / 🟡 MEDIUM / 🔴 HIGH / 🔴🔴 CRITICAL
- **Recommended Action:** [Remediate immediately / Schedule review / Monitor / Acceptable]

### Quick Stats
| Metric | Count |
|--------|-------|
| Critical Issues | $N |
| High Issues | $N |
| Medium Issues | $N |
| Low Issues | $N |
| Info Issues | $N |
| **Total** | **$N** |

---

## Detailed Findings by Domain

### AUTH - Authentication & Authorization

#### Finding: AUTH-001
**Title:** [Name]
**Severity:** 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🟢 LOW / ℹ️ INFO
**CWE:** [CWE-NNN: Description](link)
**CVSS Score:** [X.X] [Vector]

**Location:** `path/to/file.ext:line_number`

**Description:**
[Detailed explanation of the vulnerability]

**Evidence:**
```
[Code snippet showing the issue, with sensitive data redacted]
```

**Risk:**
[What an attacker could do with this vulnerability]

**Remediation:**
```
[Example secure code]
```

**References:**
- [OWASP Reference]
- [Security Standard]
- [CVE if applicable]

**Compliance Impact:**
- PCI-DSS: Requirement X.X.X - [Impact]
- HIPAA: [Impact if applicable]
- GDPR: [Impact if applicable]

---

[Repeat for each finding, organized by domain]

---

## Compliance Mapping (if --compliance specified)

### PCI-DSS v3.2.1
| Requirement | Finding | Status | Severity |
|-------------|---------|--------|----------|
| 6.5.1 | AUTH-001 | ❌ Violation | CRITICAL |
| 6.5.10 | AUTH-002 | ⚠️ Warning | HIGH |
| 3.2 | CRYPT-001 | ✅ OK | - |

**Overall Compliance:** 30% / 100%

---

## Recommendations by Priority

### Immediate (CRITICAL)
1. [Specific action]
2. [Specific action]

### High Priority
1. [Specific action]
2. [Specific action]

### Medium Priority
1. [Specific action]

### Monitoring/Review
1. [Specific action]

---

## Files Analyzed
- Total files scanned: $N
- Files with findings: $N
- Languages detected: [list]
- Frameworks detected: [list]

---

## Redaction Notice
⚠️ $N potentially sensitive values have been redacted from this report.

---

## Next Steps

1. Review all CRITICAL findings immediately
2. Create issues in Beads for remediation tracking
3. Schedule follow-up review after fixes
4. Consider additional security testing (e.g., DAST, SAST)
```

## Severity Classification Algorithm

```
CRITICAL:
  ├─ Authentication bypass possible
  ├─ Hardcoded secrets/credentials
  ├─ SQL injection without parameterization
  ├─ Command injection
  └─ Remote code execution possible

HIGH:
  ├─ Weak cryptography (MD5, SHA1)
  ├─ Insecure deserialization
  ├─ Missing authorization checks
  ├─ Sensitive data in logs/errors
  └─ Known vulnerable dependencies (CVSS > 7.0)

MEDIUM:
  ├─ Weak password policy
  ├─ Missing security headers
  ├─ Insufficient input validation
  ├─ CORS misconfiguration
  └─ Debug mode enabled

LOW:
  ├─ Outdated but not vulnerable dependencies
  ├─ Suboptimal error handling
  ├─ Missing or unclear security comments
  └─ Potential code smell

INFO:
  ├─ Security headers present
  ├─ Input validation found
  ├─ Crypto library usage detected
  └─ Security best practices observed
```

## CWE Reference Database

Maintained mapping of:
- CWE ID → Description
- CWE ID → OWASP Mapping
- CWE ID → PCI-DSS Mapping
- CWE ID → Common False Positives

[Expand as needed for compliance frameworks]

## Begin

Execute security review:

1. **Validate inputs:**
   - Check path exists and is readable
   - Parse and validate --scope flag (if provided)
   - Parse and validate --compliance flag (if provided)

2. **Initialize:**
   - Create finding accumulator
   - Load domain definitions
   - Calculate expected iterations (1-7 based on scope)

3. **Execute domain iteration:**
   - For each domain in priority order
   - Execute domain-specific scans (Grep, Glob, Read)
   - Evaluate findings, classify severity
   - Check for CRITICAL findings → trigger MUST_ASK
   - Accumulate findings in structured format

4. **Generate report:**
   - Format findings by domain
   - Calculate overall risk score
   - Apply compliance mappings (if requested)
   - Redact sensitive information
   - Generate structured output

5. **Exit with <promise>COMPLETE</promise>**
