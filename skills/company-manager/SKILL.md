# Company Manager Skill

## Description
Handles all company-scoped read operations, status reporting, memory compaction, and company deletion. Works with any company type — reads structure dynamically from company files.

## Input
- **company** (required): Company name
- **action** (required): status | report | budget | compact | agents | delete | task-list | task-status

## Actions

### `status` — Company Dashboard

1. Read `companies/<name>/manifest.md`
2. Read `companies/<name>/structure.md`
3. Read `companies/<name>/taskwall.md`

Present dashboard:
```
📊 Company Dashboard: <Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Type: <type> | Industry: <industry> | Status: <status>

👥 Agents (<current>/<max>)
  ✅ <agent> — <department> — <state>
  ✅ <agent> — <department> — <state>
  ...

📋 Tasks
  🔄 In Progress: <n>
  ⏳ Pending: <n>
  ✅ Done: <n>

💰 Budget
  Allocated: <amount> tokens
  Spent: <amount> tokens
  Remaining: <amount> tokens

📅 Created: <date> | Last Modified: <date>
```

### `report` — Full Company Report

1. Read all company state files
2. Read `companies/<name>/structure.md` to get the **dynamic department list** (not hardcoded)
3. Scan `outputs/` for all agent outputs
4. Read audit log for recent activity
5. Aggregate outputs and KPIs per department (whatever departments exist)

Present report:
```
📈 Company Report: <Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Executive Summary
<Type> company with <n> agents across <dept-count> departments, <tasks> tasks completed.

## Department Reports

(Dynamically read each department from structure.md)

### <Department Name>
- Agents: <n>
- Tasks completed: <n>
- Active: <n>
- Outputs: <list recent>

### <Department Name>
- ...

## Capability Map
| Capability | Agent |
|-----------|-------|
| <capability> | <mapped agent> |
| ... |

## Financial Summary
- Budget allocated: <amount>
- Budget spent: <amount>
- Efficiency: <spent/allocated * 100>%

## Recent Activity (last 10 audit entries)
<formatted audit log entries>

## Recommendations
<based on current state>
```

### `budget` — Budget Status

1. Read `companies/<name>/manifest.md` for allocated/remaining
2. Scan `companies/<name>/logs/audit.jsonl` for token spend entries
3. Calculate burn rate and runway

Present budget report:
```
💰 Budget Report: <Name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Allocated:  <amount> tokens
Spent:      <amount> tokens
Remaining:  <amount> tokens
Utilization: <percentage>%

Per-Agent Breakdown:
  <agent>: <tokens> tokens (<percentage>%)
  ...

Per-Workflow Breakdown:
  <workflow>: <tokens> tokens
  ...

Burn Rate: <tokens>/day (estimated)
Projected Runway: <days> days
```

### `compact` — Memory Compaction

1. Read all memory files in `companies/<name>/memory/`
2. For `shared-context.md`:
   - If > 5,000 tokens: summarize older entries, keep 10 most recent
3. For `company-knowledge.md`:
   - If > 8,000 tokens: archive entries older than 7 days, keep 20 most recent
4. For `failures.md`:
   - If > 3,000 tokens: archive resolved failures, keep unresolved
5. Write compacted files
6. Log compaction to audit trail

```
🧹 Memory Compacted: <Name>

shared-context.md: <before> → <after> tokens (<reduction>%)
company-knowledge.md: <before> → <after> tokens (<reduction>%)
failures.md: <before> → <after> tokens (<reduction>%)
```

### `agents` — List Agents

1. Read `companies/<name>/structure.md`
2. Read each agent state file from departments

```
👥 Agents: <Name> (<n> total)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| # | Agent | Department | Level | Reports To | State | Current Task |
|---|-------|-----------|-------|------------|-------|-------------|
| 1 | silicon-agent | <dept> | 0 | CEO | idle | — |
| 2 | <agent> | <dept> | <level> | <reports_to> | <state> | <task or —> |
| ... |
```

### `delete` — Archive and Remove

1. Verify company exists
2. Create archive snapshot in `companies/<name>/archive/_deletion-snapshot-<date>/`
3. Copy manifest, structure, taskwall, memory, and audit log to snapshot
4. Remove `companies/<name>/` directory entirely
5. Log deletion (if possible, to a global log)

```
🗑️ Company '<name>' deleted.
Archived snapshot: companies/<name>/archive/_deletion-snapshot-<date>/
```

### `task-list` — View Task Wall

1. Read `companies/<name>/taskwall.md`
2. Format and present

### `task-status` — Check Specific Task

1. Read `companies/<name>/taskwall.md`
2. Find task by ID
3. Present status, assignments, and history
