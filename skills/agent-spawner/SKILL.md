# Agent Spawner Skill

## Description
Spawns (hires) or removes (fires) agents within an existing company. Supports built-in agents, blueprint-defined agents, and on-the-fly custom agent creation.

## Input
- **company** (required): Company name (must exist)
- **role** (required): Agent role name
- **action**: spawn (default) or remove

## Role Resolution — 4-Tier System

When hiring an agent, resolve the role through 4 tiers:

### Tier 1: Built-in Plugin Templates
Check if `agents/<role>.md` exists in the plugin's `agents/` directory.
If found → copy it directly. Use the department/level/reports_to from the template's frontmatter.

### Tier 1.5: Marketplace Agent Store
Check if `marketplace/agent-store/agents/<role>.md` exists.
If found → copy it directly. Use the department/level/reports_to from the agent's frontmatter.

### Tier 2: Company Blueprint
Check the company's blueprint in `companies/<name>/manifest.md`.
If the role is listed in the blueprint → generate agent file from `templates/agent-template.md` using blueprint values.

### Tier 3: On-the-Fly Custom Agent
If role is in neither → offer to create a brand new custom agent:
1. AI infers appropriate department, level, and reports_to based on:
   - Company type and industry
   - Existing agents and departments in the company
   - The role name (e.g., "school-nurse" → student-services department)
2. Present inference to user:
```
🆕 New Agent: <role>
  Department: <inferred-dept>
  Level: <inferred-level>
  Reports to: <inferred-reports-to>
  Triggers: <inferred-triggers>

  Create this agent? [yes / modify / cancel]
```
3. On approval → add to blueprint in manifest.md, generate agent file, create state

## Spawn Steps (Hire)

### 1. Verify Company
- Check `companies/<name>/manifest.md` exists
- Read manifest for headcount limits and budget

### 2. Check Headcount
- Read `companies/<name>/structure.md` for current agent count
- If current >= max → report error: "Headcount limit reached (<n>/<max>). Remove an agent first with `/silicon-agent <name> fire <role>`"

### 3. Check Duplicate
- If `companies/<name>/agents/<role>.md` exists → report: "Agent '<role>' already exists in this company."

### 4. Resolve Role (use 3-tier system above)
- Determine agent details (department, level, reports_to, tools, responsibilities)
- If Tier 3 (custom): present to user for confirmation before proceeding

### 5. Copy or Generate Agent Definition
- **Built-in**: Copy `agents/<role>.md` → `companies/<name>/agents/<role>.md`
- **Blueprint or Custom**: Generate from `templates/agent-template.md` with:
  - Substitute all `{{placeholders}}` with resolved values
  - AI generates appropriate responsibilities, quality gates, and trigger phrases
  - Write to `companies/<name>/agents/<role>.md`

### 6. Ensure Department Directory Exists
- Create `companies/<name>/departments/<dept>/` with subdirs if not present:
  - `agents/`, `workflows/`, `messages/inbox/`, `outputs/`

### 7. Create Agent State File
Create `companies/<name>/departments/<dept>/agents/<role>-state.md`:

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

### 8. Create Output Directory
- Ensure `companies/<name>/outputs/<role>/` exists

### 9. Create Inbox
- Create `companies/<name>/messages/inbox/<role>.md` with empty header:
```markdown
# Inbox: <role>
(No messages)
```

### 10. Update Structure
- Append agent row to `companies/<name>/structure.md` agent table
- Update department summary counts in structure.md

### 11. Update Manifest
- Increment `headcount.current` in `companies/<name>/manifest.md`
- If custom agent: add to blueprint agents list and update capability map if needed

### 12. Audit Log
Append to `companies/<name>/logs/audit.jsonl`:
```json
{"ts":"<ISO-8601>","agent":"silicon-agent","action":"spawn_agent","company":"<name>","target":"<role>","result":"success","detail":"department=<dept>,level=<level>,source=<builtin|blueprint|custom>"}
```

### 13. Report
```
✅ Agent '<role>' hired for '<company>'!

Department: <department>
Level: <level>
Reports to: <reports_to>
Source: <built-in | blueprint | custom>

Company headcount: <n>/<max>
```

## Remove Steps (Fire)

### 1. Verify Agent Exists
- Check `companies/<name>/agents/<role>.md` exists
- If not → report: "Agent '<role>' not found in company '<name>'."

### 2. Check Agent State
- Read agent state file
- If state is `active` → warn: "Agent '<role>' is currently active. Confirm removal."
- Move agent file to `companies/<name>/archive/agents/<role>-<date>.md`

### 3. Archive State
- Move state file to `companies/<name>/archive/agents/<role>-state-<date>.md`

### 4. Update Structure
- Remove agent row from `companies/<name>/structure.md` agent table
- Update department summary counts

### 5. Update Manifest
- Decrement `headcount.current` in `companies/<name>/manifest.md`
- Remove from blueprint agents list if present

### 6. Cleanup
- Remove `companies/<name>/messages/inbox/<role>.md` (if exists)
- Keep output files (archive, don't delete)

### 7. Audit Log
```json
{"ts":"<ISO-8601>","agent":"silicon-agent","action":"fire_agent","company":"<name>","target":"<role>","result":"success"}
```

### 8. Report
```
✅ Agent '<role>' removed from '<company>'.
Archived to: archive/agents/<role>-<date>.md
Company headcount: <n>/<max>
```

## Error Messages

| Condition | Message |
|-----------|---------|
| Unknown role (not built-in, not in blueprint) | "Role '<role>' not found in built-in templates or company blueprint. Would you like to create a custom agent? Or choose from: <list built-in roles + company blueprint roles>" |
| Headcount full | "Headcount limit reached (<n>/<max>). Remove an agent first: `/silicon-agent <name> fire <role>`" |
| Agent already exists | "Agent '<role>' already exists in company '<name>'." |
