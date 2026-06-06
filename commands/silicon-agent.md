---
description: Create, manage, and operate virtual companies with AI agents and workflows
deprecated: false
---

# SiliconAgent — Main Entry Point & Command Router

## Description
Create, manage, and operate isolated virtual companies with AI agents, workflows, and state management. Supports any company type — from SaaS startups to schools, construction firms, hospitals, and semiconductor fabs.

## Command Parsing

Parse the user's input to extract: **company name**, **action**, and **arguments**.

### Parsing Logic (4-tier)

```
1. Normalize input to lowercase for matching
2. Check for explicit commands:
   - "create <type> company <name> [--flags]"  → action: create
   - "list" or "list companies"                 → action: list
   - "delete company <name>"                    → action: delete
   - "browse packs" / "browse agents" / "browse workflows" → action: browse
   - "install pack <name> company <company>"    → action: install
   - "install agent <name>"                     → action: install (needs --company)
   - "install workflow <name>"                  → action: install (needs --company)
   - "search <query>"                           → action: search
   - "info <type> <name>"                       → action: info
3. Check for company-scoped commands:
   - "<company> <action> [args]"                → action: <action>, company: <company>
   - Known actions: status, hire, fire, task, run, report, budget, compact, agents
4. Check for company-scoped free-form tasks:
   - "<company> <anything else>"                → action: task, company: <company>
5. Fallback: natural language matching (see table below)
6. FINAL FALLBACK: If nothing matches → treat entire input as a task for the task executor
```

### Natural Language Routing

| User Says | Parsed As |
|-----------|-----------|
| "create a [type] company called [name]" | `create <type> company <name>` |
| "create a school called [name]" | `create school company <name>` |
| "build a hospital named [name]" | `create hospital company <name>` |
| "start a construction company [name]" | `create construction company <name>` |
| "set up a semiconductor fab [name]" | `create semiconductor company <name>` |
| "how is [name] doing?" | `<name> status` |
| "show [name]'s tasks" | `<name> task list` |
| "hire [role] for [name]" | `<name> hire <role>` |
| "[name] build [feature]" | `<name> run product-development --feature "<feature>"` |
| "show all companies" | `list` |
| "delete [name]" | `delete company <name>` |
| "what's the budget for [name]" | `<name> budget` |
| "compact [name]" | `<name> compact` |
| "[name] report" | `<name> report` |
| "who works at [name]" | `<name> agents` |
| **"[company] conduct maths exam slip test on saturday"** | **`<company> task "conduct maths exam..."`** |
| **"[company] double production from unit 3, prepare budget"** | **`<company> task "double production..."`** |
| **"[company] prepare safety audit for site B"** | **`<company> task "prepare safety audit..."`** |
| **"conduct maths exam at lincoln-high"** | **`lincoln-high task "conduct maths exam..."`** |
| **Any other input with a company reference** | **`<company> task "<full input>"`** |
| "show me available packs" | `browse packs` |
| "what agents can I hire" | `browse agents` |
| "what workflows are available" | `browse workflows` |
| "I need a school setup" | `install pack school` |
| "search for manufacturing" | `search manufacturing` |

## Command Dispatch

### Global Commands (no company required)

#### `create <type> company <name> [--industry <industry>] [--quickstart] [--budget <amount>] [--headcount <n>]`
→ Delegate to `skills/company-generator/SKILL.md`
- **type** is ANY free-form string: SaaS, school, construction, hospital, semiconductor, law-firm, restaurant, etc.
- If type is one of the 5 known types (SaaS, Consulting, Agency, E-commerce, Research) → use pre-built roster (backward compatible, no confirmation needed)
- If type is anything else → AI infers org blueprint → present to user for approval → then create
- Pass: name, type, industry, quickstart flag, budget, headcount

#### `list` or `list companies`
→ List all directories under `companies/`
- For each company, read `manifest.md` and show: name, type, agent count, status

#### `browse packs` — List marketplace company packs
→ Delegate to `skills/marketplace/SKILL.md` (browse packs action)
- Shows all available industry packs with descriptions

#### `browse agents` — List marketplace agent store
→ Delegate to `skills/marketplace/SKILL.md` (browse agents action)
- Shows all available agents grouped by category

#### `browse workflows` — List marketplace workflow store
→ Delegate to `skills/marketplace/SKILL.md` (browse workflows action)
- Shows all available workflows grouped by category

#### `install pack <name> company <company-name>` — Create from marketplace pack
→ Delegate to `skills/marketplace/SKILL.md` (install pack action)
- Creates a company using a curated marketplace pack blueprint
- Preferred over AI inference when pack exists

#### `search <query>` — Search marketplace
→ Delegate to `skills/marketplace/SKILL.md` (search action)
- Search across packs, agents, and workflows

#### `info <type> <name>` — Show marketplace item details
→ Delegate to `skills/marketplace/SKILL.md` (info action)

#### `delete company <name>`
→ Delegate to `skills/company-manager/SKILL.md` (delete action)
- Archive company to `companies/<name>/archive/`
- Remove from active directory

### Company-Scoped Commands

Before executing ANY company-scoped command:
1. **Verify company exists**: check `companies/<name>/manifest.md` exists
2. **Load company context**: read `manifest.md`, `structure.md`, `taskwall.md`
3. **If company not found**: report error, suggest `create` command

#### `<company> status`
→ Delegate to `skills/company-manager/SKILL.md` (status action)
- Show: company name, type, agent count, active tasks, budget status

#### `<company> hire <role>`
→ Delegate to `skills/agent-spawner/SKILL.md`
- Pass: company name, role name
- 3-tier resolution: built-in template → company blueprint → AI-inferred custom

#### `<company> fire <role>`
→ Delegate to `skills/agent-spawner/SKILL.md` (remove action)
- Archive agent file, update structure.md, log to audit

#### `<company> task add <description>`
→ Write task to `companies/<name>/taskwall.md`
- Assign task ID (increment from current max)
- Default status: pending, priority: P2

#### `<company> task list`
→ Read and format `companies/<name>/taskwall.md`

#### `<company> task <id> status`
→ Read specific task from taskwall

#### `<company> run <workflow>`
→ Execute workflow with agent resolution:
1. Read workflow from `companies/<name>/workflows/<workflow>.flow`
2. For each phase that references an agent, resolve using the **Workflow Agent Resolution** logic below
3. Execute phases in sequence, delegating to resolved agents

#### `<company> report`
→ Delegate to `skills/company-manager/SKILL.md` (report action)

#### `<company> budget`
→ Delegate to `skills/company-manager/SKILL.md` (budget action)

#### `<company> compact`
→ Delegate to `skills/company-manager/SKILL.md` (compact action)

#### `<company> agents`
→ Delegate to `skills/company-manager/SKILL.md` (agents action)

#### `<company> task "<description>"` — Dynamic Task Execution
→ Delegate to `skills/task-executor/SKILL.md`
- **The "just get it done" command.** Accepts ANY task in natural language.
- System auto-analyzes the task, checks if existing agents/workflows can handle it
- If agents are missing → generates them from template (with user confirmation)
- If no workflow fits → generates a dynamic workflow on-the-fly
- Executes the workflow, collects deliverables, presents results
- Examples:
  - `/silicon-agent:silicon-agent lincoln-high task "conduct maths exam slip test for grade 10 on Saturday"`
  - `/silicon-agent:silicon-agent chipworks task "double production from unit 3, prepare budget and plan"`
  - `/silicon-agent:silicon-agent acme task "research competitor pricing for Q3"`

### Catch-All: Free-Form Task Fallback

When user input does NOT match any known command pattern but references a company:
1. Extract the company name from the input
2. If company exists → route the ENTIRE input as a task to `skills/task-executor/SKILL.md`
3. If company doesn't exist → suggest creating it first

This means users can type naturally:
```
/silicon-agent:silicon-agent lincoln-high conduct maths exam slip test for grade 10 on Saturday
/silicon-agent:silicon-agent chipworks we need double output from unit 3, prepare the plan
/silicon-agent:silicon-agent acme research our competitors and prepare a strategy document
```

All of the above get routed as: `<company> task "<full input>"`

## Workflow Agent Resolution

When a workflow references an agent role (e.g., "research-agent", "engineer", "qa-engineer"), resolve the actual agent to use:

### Resolution Chain (3 levels):

**Level 1 — Exact Match**: Does `companies/<name>/agents/<role>.md` exist?
→ Use it directly.

**Level 2 — Capability Map**: Read the capability map from `companies/<name>/manifest.md`.
Map standard workflow agent names to capabilities:
| Workflow Reference | Capability |
|-------------------|-----------|
| research-agent | researcher |
| engineer | implementer |
| qa-engineer | reviewer |
| product-manager | coordinator |
| marketing-manager | marketing |
| sales-agent | sales |
| support-agent | support |
| finance-agent | finance |
| ceo-advisor | coordinator |
| silicon-agent | coordinator |

Look up the capability in the manifest's capability map → use the mapped agent.

**Level 3 — Ask User**: If neither exact match nor capability map resolves:
→ Ask the user: "Workflow '<workflow>' needs an agent for '<role>'. Which agent should handle this? Available: <list company agents>"

### Example:
A school company has no "engineer" agent. The product-development workflow references "engineer" for the implementation phase.
- Level 1: No `engineer.md` in `companies/lincoln-high/agents/` → skip
- Level 2: "engineer" maps to capability "implementer" → manifest says implementer = `math-teacher` → use math-teacher
- The workflow runs with math-teacher handling the implementation phase

## Audit Logging

After every mutation, append to `companies/<name>/logs/audit.jsonl`:
```json
{"ts":"<ISO-8601>","agent":"silicon-agent","action":"<action>","company":"<name>","result":"<success|failed>","detail":"<optional>"}
```

## Error Handling

| Error | Response |
|-------|----------|
| Company not found | "Company '<name>' doesn't exist. Create it with: `/silicon-agent:silicon-agent create <type> company <name>`" |
| Company already exists | "Company '<name>' already exists. Use `/silicon-agent:silicon-agent <name> status` to see its state." |
| Unknown agent role | "Role '<role>' not found. Available: <built-in + company agents>. Or create custom: `/silicon-agent:silicon-agent <name> hire <role>`" |
| Unknown command BUT company found | Route as free-form task: `<company> task "<input>"` → task executor handles it |
| Unknown command AND no company | "I can help with: creating companies, managing agents, running tasks. What would you like to do?" |

## Constraints
- NEVER modify files in `agents/`, `skills/`, `workflows/`, `templates/` (plugin templates are read-only)
- ALL mutations happen under `companies/<name>/`
- ALWAYS validate before mutating
- FAIL GRACEFULLY with clear error messages
- ACCEPT any company type — the system infers structure dynamically
