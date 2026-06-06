# Marketplace Skill

## Description
Browse and install company packs, agents, and workflows from the silicon-agent-hub marketplace. The marketplace is a catalog of pre-built, curated templates organized by industry and category.

## Input
- **action** (required): browse | install | search | info
- **type** (required for browse): packs | agents | workflows
- **name** (required for install): pack/agent/workflow name
- **company** (required for install agent/workflow): target company name

## Actions

### `browse packs` — List Company Packs

1. Read all directories under `marketplace/company-packs/`
2. For each, read `pack.yaml`
3. Present formatted list:

```
📦 Company Packs Available
━━━━━━━━━━━━━━━━━━━━━━━━

| # | Pack | Industry | Agents | Description |
|---|------|----------|--------|-------------|
| 1 | saas | Technology | 8 | Software-as-a-Service company |
| 2 | school | Education | 7 | K-12 school or educational institution |
| 3 | construction | Construction | 6 | Construction company with site operations |
| 4 | hospital | Healthcare | 6 | Hospital or healthcare facility |
| 5 | semiconductor | Manufacturing | 6 | Semiconductor fabrication facility |
| 6 | restaurant | Food Service | 6 | Restaurant or food service business |
| ... |

Use: /silicon-agent install pack <name> company <company-name>
```

### `browse agents` — List Agent Store

1. Read `marketplace/agent-store/catalog.yaml`
2. Group agents by category
3. Present formatted list:

```
🤖 Agent Store
━━━━━━━━━━━━━━

## Executive & Leadership
  master — Hub orchestrator [built-in]
  ceo-advisor — Strategic advisor [built-in]
  principal — School principal [marketplace]

## Engineering & Development
  engineer — Software development [built-in]
  process-engineer — Semiconductor process engineering [marketplace]

## Education & Teaching
  teacher — Lesson planning and instruction [marketplace]

## Operations & Production
  production-planner — Manufacturing scheduling [marketplace]
  safety-inspector — Safety audits [marketplace]
  site-manager — Construction site operations [marketplace]

## Healthcare & Medical
  nurse — Patient care [marketplace]

...

Use: /silicon-agent <company> install agent <name>
```

### `browse workflows` — List Workflow Store

1. Read `marketplace/workflow-store/catalog.yaml`
2. Group workflows by category
3. Present formatted list:

```
⚡ Workflow Store
━━━━━━━━━━━━━━━━

## Product & Feature Development
  product-development — Research → PRD → Implement → QA → Release [5 phases]

## Quality & Bug Fixing
  bugfix — Report → Reproduce → Fix → Verify → Deploy [5 phases]

## Education & Curriculum
  curriculum-design — Assess → Design → Review → Approve → Implement [5 phases]

## Industrial & Manufacturing
  safety-audit — Plan → Inspect → Identify → Report → Remediate [5 phases]
  production-planning — Analyze → Plan → Budget → Schedule → Risk [5 phases]

...

Use: /silicon-agent <company> install workflow <name>
```

### `search <query>` — Search Marketplace

Search across packs, agents, and workflows for matching items:
1. Read all catalog files
2. Match query against names, descriptions, tags, industries
3. Present matching results grouped by type

### `info <type> <name>` — Show Details

Show full details for a specific marketplace item:
- Pack: full pack.yaml content, agent list, department list, capability map
- Agent: full agent .md file
- Workflow: full .flow file with phases

### `install pack <name> company <company-name>` — Create from Pack

1. Verify `marketplace/company-packs/<name>/pack.yaml` exists
2. If pack not found → offer similar packs or AI inference fallback
3. Read pack.yaml for blueprint (departments, agents, capability map)
4. Present pack details for confirmation:

```
📦 Installing Pack: <name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Industry: <industry>
Agents: <count> (<list>)
Departments: <list>

Create company '<company-name>' from this pack? [yes / modify / cancel]
```

5. On approval → delegate to `skills/company-generator/SKILL.md` with pack blueprint
   - Use Path C (pack resolution) in company-generator
   - Pack provides departments, agent list, and capability map directly
   - For each agent in pack: check if `agents/<name>.md` exists (built-in), else check `marketplace/agent-store/agents/<name>.md`, else generate from template
6. Set `pack: <name>` in manifest.md
7. Log to audit: `{"action":"install_pack","pack":"<name>","company":"<company-name>"}`

### `install agent <name>` — Add Agent to Company (requires `--company`)

1. Resolve agent source (3-tier):
   - Check `agents/<name>.md` (built-in)
   - Check `marketplace/agent-store/agents/<name>.md` (marketplace)
   - If neither → offer to generate from template
2. Delegate to `skills/agent-spawner/SKILL.md` with resolved source
3. Log to audit

### `install workflow <name>` — Add Workflow to Company (requires `--company`)

1. Resolve workflow source:
   - Check `workflows/<name>.flow` (built-in)
   - Check `marketplace/workflow-store/workflows/<name>.flow` (marketplace)
   - If neither → offer to generate from template
2. Copy workflow to `companies/<name>/workflows/<name>.flow`
3. Add capability-binding header based on company's capability map
4. Log to audit

## Natural Language Routing

| User Says | Parsed As |
|-----------|-----------|
| "show me available packs" / "what company types are available" | `browse packs` |
| "show agents" / "what agents can I hire" | `browse agents` |
| "show workflows" / "what workflows are available" | `browse workflows` |
| "I need a school setup" / "set up a school" | `install pack school` |
| "I need a safety inspector" | `install agent safety-inspector` |
| "add production planning workflow" | `install workflow production-planning` |
| "search for manufacturing" / "find construction agents" | `search manufacturing` |
| "tell me about the school pack" | `info packs school` |

## Error Handling

| Error | Response |
|-------|----------|
| Pack not found | "Pack '<name>' not found. Available: <list>. Or use `/silicon-agent create <type> company <name>` for AI-inferred companies." |
| Agent not found | "Agent '<name>' not found in store. Browse available: `/silicon-agent browse agents`" |
| Workflow not found | "Workflow '<name>' not found in store. Browse available: `/silicon-agent browse workflows`" |
| No company specified for install | "Specify a company: `/silicon-agent install agent <name> --company <company>`" |
