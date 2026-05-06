#!/bin/bash
# Post-command hook: Log tool results for audit.
# Default behavior stores metadata only. Redacted payload logging can be enabled with:
#   STREB_AUDIT_INCLUDE_PAYLOADS=1
#
# Queue-based approach: write to unique temp file, then atomic rename into queue dir.

LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
LOG_FILE="${LOG_DIR}/tool-audit.jsonl"
QUEUE_DIR="${LOG_DIR}/.queue"

mkdir -p "$LOG_DIR" "$QUEUE_DIR" 2>/dev/null || true

INPUT=$(cat)

if ! command -v jq &>/dev/null; then
    exit 0
fi

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null) || exit 0
TOOL_INPUT_KEYS=$(printf '%s' "$INPUT" | jq -c '(.tool_input // {} | keys)' 2>/dev/null) || TOOL_INPUT_KEYS='[]'
TOOL_INPUT_SIZE=$(printf '%s' "$INPUT" | jq -r '(.tool_input // {} | tostring | length)' 2>/dev/null) || TOOL_INPUT_SIZE='0'
RESPONSE_TYPE=$(printf '%s' "$INPUT" | jq -r '(.tool_response | if . == null then "null" else type end)' 2>/dev/null) || RESPONSE_TYPE='unknown'
RESPONSE_SIZE=$(printf '%s' "$INPUT" | jq -r '(.tool_response // null | tostring | length)' 2>/dev/null) || RESPONSE_SIZE='0'

AUDIT_INCLUDE_PAYLOADS="${STREB_AUDIT_INCLUDE_PAYLOADS:-0}"
INCLUDE_PAYLOADS_JSON="false"
if [ "$AUDIT_INCLUDE_PAYLOADS" = "1" ]; then
    INCLUDE_PAYLOADS_JSON="true"
fi

REDACT_FILTER='
  def sensitive_key: (ascii_downcase | test("token|secret|password|authorization|api[_-]?key|auth"));
  def redact_string:
    if test("(?i)(sk-ant-|ghp_|glpat-|xox[baprs]-|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]+PRIVATE KEY-----)")
    then "***REDACTED***"
    else .
    end;
  def scrub:
    if type == "object" then
      with_entries(
        if (.key | sensitive_key)
        then .value = "***REDACTED***"
        else .value |= scrub
        end
      )
    elif type == "array" then map(scrub)
    elif type == "string" then redact_string
    else .
    end;
  scrub
'

TOOL_INPUT_REDACTED='{}'
TOOL_RESPONSE_REDACTED='null'
RESPONSE_TRUNCATED='false'
if [ "$AUDIT_INCLUDE_PAYLOADS" = "1" ]; then
    TOOL_INPUT_REDACTED=$(printf '%s' "$INPUT" | jq -c "$REDACT_FILTER (.tool_input // {} | scrub)" 2>/dev/null) || TOOL_INPUT_REDACTED='{}'
    TOOL_RESPONSE_REDACTED=$(printf '%s' "$INPUT" | jq -c "$REDACT_FILTER (.tool_response // null | scrub)" 2>/dev/null) || TOOL_RESPONSE_REDACTED='null'

    if [ ${#TOOL_RESPONSE_REDACTED} -gt 4096 ]; then
        TOOL_RESPONSE_REDACTED="${TOOL_RESPONSE_REDACTED:0:4000}... [truncated]"
        RESPONSE_TRUNCATED='true'
    fi
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.%N 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%S)
UNIQUE_ID="${TIMESTAMP}-$$-${RANDOM}"

if [ "$AUDIT_INCLUDE_PAYLOADS" = "1" ]; then
    LOG_ENTRY=$(jq -n \
        --arg timestamp "$TIMESTAMP" \
        --arg event "post_tool_use" \
        --arg tool "$TOOL_NAME" \
        --arg response_type "$RESPONSE_TYPE" \
        --argjson input "$TOOL_INPUT_REDACTED" \
        --argjson response "$TOOL_RESPONSE_REDACTED" \
        --argjson input_keys "$TOOL_INPUT_KEYS" \
        --argjson input_size "$TOOL_INPUT_SIZE" \
        --argjson response_size "$RESPONSE_SIZE" \
        --argjson response_truncated "$RESPONSE_TRUNCATED" \
        --argjson include_payloads "$INCLUDE_PAYLOADS_JSON" \
        --arg session_id "${CLAUDE_SESSION_ID:-unknown}" \
        --arg user "${USER:-unknown}" \
        --arg seq "$UNIQUE_ID" \
        '{
            timestamp: $timestamp,
            event: $event,
            tool: $tool,
            response_type: $response_type,
            input: $input,
            response: $response,
            input_keys: $input_keys,
            input_size: $input_size,
            response_size: $response_size,
            response_truncated: $response_truncated,
            include_payloads: $include_payloads,
            session_id: $session_id,
            user: $user,
            seq: $seq
        }' 2>/dev/null) || exit 0
else
    LOG_ENTRY=$(jq -n \
        --arg timestamp "$TIMESTAMP" \
        --arg event "post_tool_use" \
        --arg tool "$TOOL_NAME" \
        --arg response_type "$RESPONSE_TYPE" \
        --argjson input_keys "$TOOL_INPUT_KEYS" \
        --argjson input_size "$TOOL_INPUT_SIZE" \
        --argjson response_size "$RESPONSE_SIZE" \
        --argjson include_payloads "$INCLUDE_PAYLOADS_JSON" \
        --arg session_id "${CLAUDE_SESSION_ID:-unknown}" \
        --arg user "${USER:-unknown}" \
        --arg seq "$UNIQUE_ID" \
        '{
            timestamp: $timestamp,
            event: $event,
            tool: $tool,
            response_type: $response_type,
            input_keys: $input_keys,
            input_size: $input_size,
            response_size: $response_size,
            include_payloads: $include_payloads,
            session_id: $session_id,
            user: $user,
            seq: $seq
        }' 2>/dev/null) || exit 0
fi

TEMP_FILE=$(mktemp "${QUEUE_DIR}/.tmp.XXXXXX" 2>/dev/null) || exit 0
echo "$LOG_ENTRY" > "$TEMP_FILE"
mv "$TEMP_FILE" "${QUEUE_DIR}/${UNIQUE_ID}.json" 2>/dev/null || rm -f "$TEMP_FILE"

if mkdir "${LOG_DIR}/.consolidate.lock" 2>/dev/null; then
    shopt -s nullglob 2>/dev/null || true
    for f in "$QUEUE_DIR"/*.json; do
        [ -f "$f" ] || continue
        cat "$f" >> "$LOG_FILE" 2>/dev/null && rm -f "$f"
    done
    shopt -u nullglob 2>/dev/null || true
    rmdir "${LOG_DIR}/.consolidate.lock" 2>/dev/null
fi

exit 0
