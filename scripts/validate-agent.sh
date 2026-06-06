#!/usr/bin/env bash
# validate-agent.sh — Validate agent definition files
# Usage: ./validate-agent.sh <path-to-agents-dir>
# Works for both plugin templates (agents/) and company instances (companies/<name>/agents/)
# Compatible with bash 3.2+ (macOS)

set -euo pipefail

AGENTS_DIR="${1:-}"
ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

error() { echo -e "${RED}ERROR${NC}: $1"; ERRORS=$((ERRORS + 1)); }
warn()  { echo -e "${YELLOW}WARN${NC}: $1"; WARNINGS=$((WARNINGS + 1)); }
pass()  { echo -e "${GREEN}PASS${NC}: $1"; }

# Validate arguments
if [[ -z "$AGENTS_DIR" ]]; then
    echo "Usage: $0 <path-to-agents-dir>"
    exit 1
fi

if [[ ! -d "$AGENTS_DIR" ]]; then
    error "Directory not found: $AGENTS_DIR"
    exit 1
fi

echo "=== Validating agents in: $AGENTS_DIR ==="
echo ""

# Collect reports_to as flat files for bash 3.2 compat
REPORTS_FILE=$(mktemp)
trap 'rm -f "$REPORTS_FILE"' EXIT

for agent_file in "$AGENTS_DIR"/*.md; do
    [[ -f "$agent_file" ]] || continue

    agent_basename=$(basename "$agent_file" .md)
    echo "--- Validating: $agent_basename ---"

    # Read the file
    content=$(cat "$agent_file")

    # Extract frontmatter (between --- markers)
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$agent_file" | sed '1d;$d')

    # 1. Check required frontmatter fields
    for field in name description model tools level reports_to department; do
        if echo "$frontmatter" | grep -q "^${field}:"; then
            pass "$agent_basename: has '$field'"
        else
            error "$agent_basename: missing required field '$field'"
        fi
    done

    # 2. Validate name format (3-50 chars, lowercase with hyphens)
    name=$(echo "$frontmatter" | grep "^name:" | sed 's/^name: *//')
    if [[ "$name" =~ ^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$ ]]; then
        pass "$agent_basename: name format valid ('$name')"
    elif [[ -n "$name" ]]; then
        error "$agent_basename: name '$name' invalid (must be 3-50 chars, lowercase letters/digits/hyphens)"
    fi

    # 3. Check description has triggering conditions
    desc=$(echo "$frontmatter" | grep "^description:" | sed 's/^description: *//')
    if echo "$desc" | grep -qi "triggered by\|trigger"; then
        pass "$agent_basename: description has triggering conditions"
    else
        warn "$agent_basename: description should include triggering conditions (e.g., 'Triggered by ...')"
    fi

    # 4. Check required sections (Responsibilities, Authority)
    for section in "Responsibilities" "Authority"; do
        if echo "$content" | grep -q "## $section"; then
            pass "$agent_basename: has '$section' section"
        else
            error "$agent_basename: missing required section '## $section'"
        fi
    done

    # 5. Collect reports_to for circular dependency check
    reports_to=$(echo "$frontmatter" | grep "^reports_to:" | sed 's/^reports_to: *//')
    if [[ -n "$reports_to" && -n "$name" ]]; then
        echo "$name|$reports_to" >> "$REPORTS_FILE"
    fi

    echo ""
done

# 6. Check for circular reports_to dependencies
echo "--- Checking reporting structure ---"

lookup_reports_to() {
    local agent="$1"
    grep "^${agent}|" "$REPORTS_FILE" 2>/dev/null | cut -d'|' -f2 | head -1
}

check_circular() {
    local start="$1"
    local current="$1"
    local visited=""

    while [[ -n "$current" ]]; do
        # Check if we've visited this node before (cycle)
        if echo "$visited" | grep -q ":${current}:"; then
            error "Circular dependency detected involving: $current"
            return 1
        fi

        visited=":${current}:${visited}"

        # Stop at external entities — not agents in the directory
        # Common external entities: CEO (Human), Board, Owner, etc.
        # If the current entity has no agent file, it's external → stop
        local next=$(lookup_reports_to "$current")
        if [[ -z "$next" ]]; then
            # No mapping found — either external entity or leaf node
            return 0
        fi

        # Follow the chain
        current="$next"
    done

    return 0
}

circular_found=0
while IFS='|' read -r agent _; do
    if ! check_circular "$agent"; then
        circular_found=1
    fi
done < "$REPORTS_FILE"

if [[ $circular_found -eq 0 ]]; then
    pass "No circular reporting dependencies found"
fi

echo ""
echo "=== Validation Complete ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
else
    exit 0
fi
