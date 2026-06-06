#!/usr/bin/env bash
# setup.sh — Initialize the SiliconAgent plugin
# Usage: ./scripts/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== SiliconAgent Plugin Setup ==="
echo "Plugin directory: $PLUGIN_DIR"
echo ""

# 1. Validate plugin structure
echo "Checking plugin structure..."

required_dirs=(".claude-plugin" "agents" "skills" "workflows" "templates" "hooks" "scripts" "companies" "marketplace" "marketplace/company-packs" "marketplace/agent-store" "marketplace/agent-store/agents" "marketplace/workflow-store" "marketplace/workflow-store/workflows")
for dir in "${required_dirs[@]}"; do
    if [[ -d "$PLUGIN_DIR/$dir" ]]; then
        echo "  ✅ $dir/"
    else
        echo "  ❌ $dir/ — MISSING"
        mkdir -p "$PLUGIN_DIR/$dir"
        echo "     Created: $dir/"
    fi
done

echo ""

# 2. Validate plugin manifest
echo "Checking plugin manifest..."
if [[ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]]; then
    echo "  ✅ plugin.json found"
else
    echo "  ❌ plugin.json MISSING"
fi

echo ""

# 3. Validate agent definitions
echo "Validating agent definitions..."
agent_count=$(find "$PLUGIN_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  Agent files found: $agent_count"

bash "$PLUGIN_DIR/scripts/validate-agent.sh" "$PLUGIN_DIR/agents"

echo ""

# 4. Validate skills
echo "Checking skills..."
skills=( "company-generator" "agent-spawner" "company-manager" "task-executor" "marketplace" )
for skill in "${skills[@]}"; do
    if [[ -f "$PLUGIN_DIR/skills/$skill/SKILL.md" ]]; then
        echo "  ✅ skills/$skill/SKILL.md"
    else
        echo "  ❌ skills/$skill/SKILL.md — MISSING"
    fi
done

echo ""

# 5. Validate workflows
echo "Checking workflows..."
workflow_count=$(find "$PLUGIN_DIR/workflows" -name "*.flow" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  Workflow files found: $workflow_count"

echo ""

# 6. Create companies directory if needed
mkdir -p "$PLUGIN_DIR/companies"
echo "  ✅ companies/ directory ready"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Usage:"
echo "  /silicon-agent create SaaS company my-startup"
echo "  /silicon-agent list"
echo "  /silicon-agent my-startup status"
