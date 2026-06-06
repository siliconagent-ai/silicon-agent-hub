# Company Generator Skill

## Description
Creates a new company directory with full structure, agents, workflows, memory, and initial state. Supports both known types (pre-built rosters) and arbitrary types (AI-inferred blueprints with user confirmation).

## Input
- **name** (required): Company name, lowercase with hyphens, 3-50 chars
- **type** (required): Any free-form string (e.g., SaaS, school, construction, hospital, semiconductor)
- **industry** (optional): Industry description
- **quickstart** (optional): If true, minimal agents only
- **budget** (optional): Token budget (default: 500000)
- **headcount** (optional): Max agents (default: 10)

## Steps

### 1. Validate
- Company name format: 3-50 chars, lowercase letters, digits, hyphens only
- Company name doesn't already exist in `companies/`
- Type is any non-empty string (no enum restriction)

### 2. Resolve Blueprint — the core decision (3 paths, checked in order)

**Path resolution order: C → A → B**

#### Path C: Marketplace Pack (Preferred)
Check if `marketplace/company-packs/<type>/pack.yaml` exists.
If found → use the pack's curated blueprint:
- Read departments, agents (with department/level/reports_to), and capability_map directly from pack.yaml
- These are pre-built, tested blueprints curated for each industry
- Skip user confirmation (pack is explicitly chosen)
- Set `pack: <type>` in manifest

Available packs: saas, consulting, agency, e-commerce, research, school, construction, hospital, semiconductor, restaurant

#### Path A: Known Type (Backward Compatible)
If type matches a known type (case-insensitive) but no pack found → use the hardcoded agent list from `company-manifest.schema.yaml` `known_type_defaults`:
- Skip user confirmation (user chose a known type explicitly)
- Use pre-built agent list and department list

Known type defaults:
| Type | Agents | Departments |
|------|--------|-------------|
| SaaS | master, product-manager, engineer, qa-engineer, marketing-manager, sales-agent, support-agent, finance-agent | executive, engineering, marketing, sales, support, finance |
| Consulting | master, product-manager, engineer, qa-engineer, research-agent, finance-agent | executive, engineering, finance |
| Agency | master, product-manager, engineer, marketing-manager, sales-agent | executive, engineering, marketing, sales |
| E-commerce | master, product-manager, engineer, qa-engineer, marketing-manager, sales-agent, support-agent, finance-agent | executive, engineering, marketing, sales, support, finance |
| Research | master, research-agent, engineer, product-manager, finance-agent | executive, engineering, finance |

**Quickstart override**: Regardless of type, only use: master, product-manager, engineer (departments: executive, engineering)

#### Path B: Unknown Type (AI-Inferred Blueprint)
If type is NOT a known type AND no pack exists → AI infers the org structure.

**Inference prompt** (use internally to generate the blueprint):

Based on the company type "<type>" and industry "<industry>", infer a realistic organizational structure for a `<type>` company. Return a structured blueprint with:

1. **Departments**: 3-8 departments appropriate for a `<type>` organization
2. **Agents**: 4-10 agent roles with:
   - `name`: Role identifier (lowercase with hyphens, e.g., "site-manager")
   - `display_name`: Human-readable (e.g., "Site Manager")
   - `department`: Which department they belong to
   - `level`: Org level (0=orchestrator, 1=executive, 2=management, 3=individual contributor)
   - `reports_to`: Who they report to (another agent name, or "CEO (Human)")
   - `triggers`: Natural language phrases that should activate this agent
   - `tools`: Which tools the agent needs (Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch, Agent, LSP)
   - `responsibilities`: 3-5 key responsibilities
3. **Capability map**: Map standard capabilities to agent names:
   - `researcher` → best agent for research/investigation
   - `implementer` → best agent for building/creating/executing core work
   - `reviewer` → best agent for quality review/validation
   - `coordinator` → best agent for planning/coordination
   - `marketing` → best agent for marketing/outreach (if applicable, else "N/A")
   - `sales` → best agent for sales/business development (if applicable, else "N/A")
   - `support` → best agent for support/issue handling (if applicable, else "N/A")
   - `finance` → best agent for financial management (if applicable, else "N/A")

**ALWAYS include silicon-agent** (level 0, orchestrator) in the agent list.

**Present blueprint to user for approval:**
```
📋 Proposed Blueprint for <Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Type: <type> | Industry: <industry>

Departments: <comma-separated list>

Agents:
| # | Role | Department | Level | Reports To |
|---|------|-----------|-------|------------|
| 1 | silicon-agent | <dept> | 0 | CEO (Human) |
| 2 | <role> | <dept> | <level> | <reports_to> |
| ... |

Capability Mapping:
  researcher → <agent>
  implementer → <agent>
  reviewer → <agent>
  ...

Approve this structure?
• Reply "yes" to proceed
• Reply "add <role> to <department>" to add an agent
• Reply "remove <role>" to remove an agent
• Reply "change <role> reports_to <target>" to modify hierarchy
• Reply "cancel" to abort
```

**Process user modifications** (loop until approved or cancelled):
- "add <role>": AI infers department/level/reports_to, adds to blueprint
- "remove <role>": Removes agent, updates any reports_to chains pointing to it
- "change ...": Updates the specified field
- "yes": Proceed to Step 3
- "cancel": Abort, no files created

### 3. Create Directory Tree
Create under `companies/<name>/`:

**Dynamic departments** — create directories based on the blueprint's department list (NOT a fixed set):
```
├── manifest.md
├── structure.md
├── taskwall.md
├── agents/
├── departments/
│   ├── <dept-1>/
│   │   ├── agents/
│   │   ├── workflows/
│   │   ├── messages/inbox/
│   │   └── outputs/
│   ├── <dept-2>/
│   │   └── (same structure)
│   └── ...
├── workflows/
├── memory/
│   ├── company-knowledge.md
│   ├── shared-context.md
│   └── failures.md
├── messages/
│   ├── inbox/
│   └── outbox/
├── outputs/
├── logs/
│   └── audit.jsonl
└── archive/
    ├── agents/
    ├── workflows/
    └── outputs/
```

### 4. Write manifest.md
Include the full blueprint in the manifest for later reference:

```markdown
---
name: <name>
type: <type>
industry: <industry or "General">
status: active
budget:
  allocated: <budget>
  spent: 0
  remaining: <budget>
headcount:
  current: <number of agents>
  max: <headcount>
created: <ISO-8601 date>
last_modified: <ISO-8601 date>
---

# Company: <Name>

**Type:** <Type>
**Industry:** <Industry>
**Status:** Active
**Budget:** <budget> tokens
**Headcount:** <n>/<max> agents

## Blueprint

### Departments
<comma-separated list>

### Capability Map
| Capability | Agent |
|-----------|-------|
| researcher | <agent> |
| implementer | <agent> |
| reviewer | <agent> |
| coordinator | <agent> |
| marketing | <agent or N/A> |
| sales | <agent or N/A> |
| support | <agent or N/A> |
| finance | <agent or N/A> |
```

### 5. Copy/Generate Agent Files
For each agent in the blueprint:

**If `agents/<role>.md` exists in plugin templates** (built-in):
→ Copy `agents/<role>.md` → `companies/<name>/agents/<role>.md`

**Else if `marketplace/agent-store/agents/<role>.md` exists** (marketplace agent):
→ Copy `marketplace/agent-store/agents/<role>.md` → `companies/<name>/agents/<role>.md`

**If NOT a built-in or marketplace agent** (custom role for this company type):
→ Generate from `templates/agent-template.md` with substituted values:
```
{{ROLE_NAME}} → agent name
{{ROLE_TITLE}} → display_name (Title Case)
{{ROLE_DESCRIPTION}} → AI-generated description with triggers
{{TRIGGER_PHRASES}} → triggers from blueprint
{{MODEL}} → sonnet
{{TOOLS_LIST}} → formatted YAML list from blueprint tools
{{LEVEL}} → level from blueprint
{{REPORTS_TO}} → reports_to from blueprint
{{DEPARTMENT}} → department from blueprint
{{core_responsibility_summary}} → one-line summary
{{responsibilities_list}} → bullet points from blueprint
{{additional_authority}} → department-appropriate access
{{quality_gates_list}} → AI-generated quality gates relevant to this role
```

**Always copy master.md** from built-in templates.

### 6. Write structure.md
```markdown
# Organization Structure — <Name>

## Agent Registry

| Agent | Department | Level | Reports To | Status |
|-------|-----------|-------|------------|--------|
| silicon-agent | <dept> | 0 | CEO (Human) | idle |
| <agent-name> | <department> | <level> | <reports_to> | idle |
| ... |

## Department Summary

| Department | Agents | Active Tasks |
|-----------|--------|-------------|
| <dept> | <n> | 0 |
| ... |
```

### 7. Create Agent State Files
For each agent, create:
`companies/<name>/departments/<dept>/agents/<role>-state.md`

```yaml
---
state: idle
assigned_task: null
task_id: null
started_at: null
blockers: []
waiting_approval: false
---
# Current Work
(None)
```

### 8. Copy Workflows
Copy ALL workflow `.flow` files from plugin `workflows/` to `companies/<name>/workflows/`.

Prepend a **capability-binding header** to each copied workflow:
```markdown
<!-- Capability Binding for <company-name> -->
<!-- researcher: <mapped-agent> | implementer: <mapped-agent> | reviewer: <mapped-agent> | coordinator: <mapped-agent> -->
```
This allows the workflow runner to resolve agent references dynamically.

### 9. Initialize Memory Files

**company-knowledge.md:**
```markdown
# Company Knowledge — <Name>

## Facts
- Company created: <date>
- Type: <type>
- Industry: <industry>
- Departments: <comma-separated list>
- Agents: <comma-separated list>

## Decisions
(None yet)

## Research Findings
(None yet)
```

**shared-context.md:**
```markdown
# Shared Context — <Name>

## Active Work
(None)

## Recent Changes
- Company initialized: <date>

## Blockers
(None)
```

**failures.md:**
```markdown
# Failure Alchemy Log — <Name>

(No failures recorded yet)
```

### 10. Initialize Task Wall
```markdown
# Task Wall — <Name>

## In Progress
| ID | Task | Assigned To | Priority | Started | Pipeline |
|----|------|-------------|----------|---------|----------|
| (none) |

## Pending
| ID | Task | Assigned To | Priority | Created | Pipeline |
|----|------|-------------|----------|---------|----------|
| (none) |

## Done
| ID | Task | Completed By | Completed At | Result |
|----|------|-------------|-------------|--------|
| 0 | Company setup | silicon-agent | <date> | ✅ success |
```

### 11. Initialize Audit Log
`companies/<name>/logs/audit.jsonl`:
```jsonl
{"ts":"<ISO-8601>","agent":"silicon-agent","action":"create_company","company":"<name>","result":"success","detail":"type=<type>,agents=<count>,departments=<count>"}
```

### 12. Validate
- All required files present
- No circular `reports_to` dependencies
- Agent count matches structure.md
- All directories created

### 13. Report
```
✅ Company '<name>' created successfully!

Type: <type> | Industry: <industry>
Agents: <n> hired
  <list each agent with department>
Departments: <comma-separated list>
Workflows: <n> available
Budget: <amount> tokens

Quick commands:
  /silicon-agent <name> status    — View dashboard
  /silicon-agent <name> task add "..." — Add a task
  /silicon-agent <name> run <workflow> — Run a workflow
```
