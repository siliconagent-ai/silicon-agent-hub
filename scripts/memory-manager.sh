#!/usr/bin/env bash
# memory-manager.sh — Manage company memory files (compact, archive, report)
# Usage: ./scripts/memory-manager.sh <command> <company-name>
# Commands:
#   compact <company>   — Compact memory files that exceed size limits
#   archive <company>   — Archive old memory entries
#   report <company>    — Show memory usage report

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
COMPANIES_DIR="$PLUGIN_DIR/companies"

# Token size limits (approximate: 1 token ≈ 4 chars)
SHARED_CONTEXT_MAX=20000     # ~5,000 tokens
COMPANY_KNOWLEDGE_MAX=32000  # ~8,000 tokens
FAILURES_MAX=12000           # ~3,000 tokens

COMMAND="${1:-}"
COMPANY="${2:-}"

usage() {
    echo "Usage: $0 <compact|archive|report> <company-name>"
    exit 1
}

[[ -z "$COMMAND" || -z "$COMPANY" ]] && usage

COMPANY_DIR="$COMPANIES_DIR/$COMPANY"
MEMORY_DIR="$COMPANY_DIR/memory"

if [[ ! -d "$MEMORY_DIR" ]]; then
    echo "Error: Memory directory not found for company '$COMPANY'"
    exit 1
fi

get_size() {
    local file="$1"
    if [[ -f "$file" ]]; then
        wc -c < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

size_to_tokens() {
    local chars="$1"
    echo $(( chars / 4 ))
}

case "$COMMAND" in
    report)
        echo "=== Memory Report: $COMPANY ==="
        echo ""

        for file in shared-context.md company-knowledge.md failures.md; do
            filepath="$MEMORY_DIR/$file"
            if [[ -f "$filepath" ]]; then
                size=$(get_size "$filepath")
                tokens=$(size_to_tokens "$size")
                case "$file" in
                    shared-context.md) max=5000 ;;
                    company-knowledge.md) max=8000 ;;
                    failures.md) max=3000 ;;
                esac
                pct=$(( tokens * 100 / max ))
                status="✅"
                [[ $pct -gt 80 ]] && status="⚠️"
                [[ $pct -gt 100 ]] && status="🔴"
                echo "  $status $file: ${tokens}/${max} tokens (${pct}%)"
            else
                echo "  ❌ $file: not found"
            fi
        done
        ;;

    compact)
        echo "=== Compacting Memory: $COMPANY ==="
        echo ""

        # Check shared-context.md
        sc_file="$MEMORY_DIR/shared-context.md"
        if [[ -f "$sc_file" ]]; then
            size=$(get_size "$sc_file")
            if [[ $size -gt $SHARED_CONTEXT_MAX ]]; then
                echo "  ⚠️ shared-context.md exceeds limit — needs compaction"
                echo "     Current: $(size_to_tokens $size) tokens (max: 5000)"
                echo "     → Summarize older entries, keep 10 most recent"
            else
                echo "  ✅ shared-context.md: within limits"
            fi
        fi

        # Check company-knowledge.md
        ck_file="$MEMORY_DIR/company-knowledge.md"
        if [[ -f "$ck_file" ]]; then
            size=$(get_size "$ck_file")
            if [[ $size -gt $COMPANY_KNOWLEDGE_MAX ]]; then
                echo "  ⚠️ company-knowledge.md exceeds limit — needs compaction"
                echo "     Current: $(size_to_tokens $size) tokens (max: 8000)"
                echo "     → Archive entries older than 7 days, keep 20 most recent"
            else
                echo "  ✅ company-knowledge.md: within limits"
            fi
        fi

        # Check failures.md
        f_file="$MEMORY_DIR/failures.md"
        if [[ -f "$f_file" ]]; then
            size=$(get_size "$f_file")
            if [[ $size -gt $FAILURES_MAX ]]; then
                echo "  ⚠️ failures.md exceeds limit — needs compaction"
                echo "     Current: $(size_to_tokens $size) tokens (max: 3000)"
                echo "     → Archive resolved failures, keep unresolved"
            else
                echo "  ✅ failures.md: within limits"
            fi
        fi

        echo ""
        echo "Note: Actual compaction (content summarization) is performed by the"
        echo "company-manager skill's compact action, which uses AI to intelligently"
        echo "summarize and preserve important information."
        ;;

    archive)
        echo "=== Archiving Old Memory: $COMPANY ==="
        archive_dir="$COMPANY_DIR/archive"
        mkdir -p "$archive_dir"

        timestamp=$(date +%Y%m%d-%H%M%S)

        for file in shared-context.md company-knowledge.md failures.md; do
            filepath="$MEMORY_DIR/$file"
            if [[ -f "$filepath" ]]; then
                cp "$filepath" "$archive_dir/${file%.md}-$timestamp.md"
                echo "  ✅ Archived: $file → archive/${file%.md}-$timestamp.md"
            fi
        done
        ;;

    *)
        usage
        ;;
esac
