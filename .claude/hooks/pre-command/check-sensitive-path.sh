#!/usr/bin/env bash
# Pre-command hook: Block writes to sensitive file paths.
# Cross-platform: detects python3, python, or py on Windows.
# Exit code 2 blocks the operation; exit 0 allows it.

PYTHON=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || command -v py 2>/dev/null)

if [ -z "$PYTHON" ]; then
    exit 0  # No Python available — allow operation
fi

exec "$PYTHON" -c "
import json, sys
try:
    d = json.load(sys.stdin)
    p = d.get('tool_input', {}).get('file_path', '')
    blocked = ['.env', '.pem', '.key', 'secret', 'credential', 'password']
    sys.exit(2 if any(x in p for x in blocked) else 0)
except Exception:
    sys.exit(0)
" 2>/dev/null
