# SiliconAgent — Full Requirements Specification

## 1. Core Concept

SiliconAgent is a **Claude Code plugin that acts as a factory**. It creates, manages, and operates isolated virtual companies — each company is a self-contained directory with its own agents, workflows, state, memory, and logs.

**The plugin itself is never mutated.** Agent definitions, skills, workflows, and templates in the plugin directory are read-only blueprints. All company data lives under `companies/<name>/`.

---

## 2. Architecture

```
~/.claude/skills/silicon-agent-company/        ← PLUGIN (factory, NEVER modified)
├── .claude-plugin/
│   └── plugin.json                             ← Minimal manifest
├── SKILL.md                                    ← Main entry point & command router
├── agents/                                     ← Agent TEMPLATES (read-only)
│   ├── silicon-agent.md                        ← The orchestrator (factory agent)
│   ├── ceo-advisor.md
│   ├── coo.md
│   ├── product-manager.md
│   ├── engineer.md
│   ├── qa-engineer.md
│   ├── marketing-manager.md
│   ├── sales-agent.md
│   ├── support-agent.md
│   ├── finance-agent.md
│   └── research-agent.md
├── skills/                                     ← Skill definitions (read-only)
│   ├── company-generator/SKILL.md              ← Creates company directories
│   ├── agent-spawner/SKILL.md                  ← Copies agents into companies
│   └── company-manager/SKILL.md                ← Status, reports, compaction
├── workflows/                                  ← Workflow TEMPLATES (read-only)
│   ├── product-development.flow
│   ├── marketing-campaign.flow
│   ├── bugfix.flow
│   ├── research.flow
│   ├── hotfix.flow
│   ├── recovery.flow
│   └── pivot.flow
├── templates/                                  ← Agent & workflow templates
│   ├── agent-template.md
│   └── workflow-template.flow
├── hooks/
│   └── hooks.json                              ← Session hooks
├── scripts/                                    ← Utility scripts
│   ├── validate-agent.sh
│   ├── setup.sh
│   └── memory-manager.sh
├── companies/                                  ← DATA ROOT (generated, the only mutable area)
│   ├── silicondev/                             ← A created company
│   │   ├── manifest.md                         ← Company config (name, type, budget)
│   │   ├── structure.md                        ← Org chart, agent states
│   │   ├── taskwall.md                         ← Task board (pending/in-progress/done)
│   │   ├── agents/                             ← Instantiated agent .md files (copied from templates)
│   │   │   ├── ceo-advisor.md
│   │   │   ├── product-manager.md
│   │   │   └── ...
│   │   ├── departments/                        ← Department isolation
│   │   │   ├── engineering/
│   │   │   │   ├── agents/                     ← Agent state files
│   │   │   │   ├── workflows/                  ← Department-specific workflows
│   │   │   │   ├── messages/inbox/             ← Inter-agent messages
│   │   │   │   └── outputs/                    ← Department outputs
│   │   │   ├── marketing/
│   │   │   └── ...
│   │   ├── workflows/                          ← Company-specific workflow copies
│   │   ├── memory/                             ← Company memory
│   │   │   ├── company-knowledge.md            ← Accumulated facts
│   │   │   ├── shared-context.md               ← Session context
│   │   │   └── failures.md                     ← Failure alchemy log
│   │   ├── messages/                           ← Inter-agent inbox/outbox
│   │   │   ├── inbox/
│   │   │   └── outbox/
│   │   ├── outputs/                            ← Versioned agent outputs
│   │   │   ├── product-manager/
│   │   │   ├── engineer/
│   │   │   └── qa/
│   │   ├── logs/                               ← Company audit trail
│   │   │   └── audit.jsonl
│   │   └── archive/                            ← Retired agents/workflows
│   │       ├── agents/
│   │       ├── workflows/
│   │       └── outputs/
│   └── acme/                                   ← Another company (fully isolated)
│       ├── manifest.md
│       └── ...
├── README.md
├── company-manifest.schema.yaml                ← Manifest schema reference
└── tests/
    └── smoke-tests.md
```

---

## 3. Command Interface

All commands go through `/silicon-agent` or natural language. The SKILL.md parses intent.

### 3.1 Company Commands

| Command | Action | Example |
|---------|--------|---------|
| `create <type> company <name>` | Generate a new company (any type) | `/silicon-agent create SaaS company Acme` |
| `create <type> company <name>` | Create non-standard company (AI infers blueprint) | `/silicon-agent create school company Lincoln-High` |
| `create <type> company <name> --industry <industry>` | With industry | `/silicon-agent create consulting company SiliconDev --industry "Software Development"` |
| `create <type> company <name> --quickstart` | Minimal: 3 agents only | `/silicon-agent create SaaS company Acme --quickstart` |
| `list` or `list companies` | Show all created companies | `/silicon-agent list` |
| `delete company <name>` | Archive and remove a company | `/silicon-agent delete company Acme` |

**Company type behavior:**
- **Known types** (SaaS, Consulting, Agency, E-commerce, Research) → use pre-built agent rosters, no confirmation needed
- **Any other type** (school, construction, hospital, semiconductor, etc.) → AI infers org blueprint → presents to user for approval → creates company with dynamic agents

### 3.2 Company-Scoped Commands

All company-scoped commands follow: `/silicon-agent <company-name> <action> [args]`

| Command | Action | Example |
|---------|--------|---------|
| `<company> status` | Show company dashboard | `/silicon-agent acme status` |
| `<company> hire <role>` | Spawn agent into company | `/silicon-agent acme hire engineer` |
| `<company> fire <role>` | Archive agent from company | `/silicon-agent acme fire research-agent` |
| `<company> task add <description>` | Add task to task wall | `/silicon-agent acme task add "Build login page"` |
| `<company> task list` | View task wall | `/silicon-agent acme task list` |
| `<company> task <id> status` | Check task status | `/silicon-agent acme task 5 status` |
| `<company> run <workflow>` | Execute a workflow | `/silicon-agent acme run product-development` |
| `<company> report` | Generate company report | `/silicon-agent acme report` |
| `<company> budget` | Show budget status | `/silicon-agent acme budget` |
| `<company> compact` | Compact company memory | `/silicon-agent acme compact` |
| `<company> agents` | List company agents | `/silicon-agent acme agents` |

### 3.3 Natural Language Routing

The SKILL.md should match natural language to commands:

| User Says | Parsed As |
|-----------|-----------|
| "create a SaaS company called Acme" | `create SaaS company acme` |
| "create a school called Lincoln High" | `create school company lincoln-high` |
| "build a hospital named City Med" | `create hospital company city-med` |
| "start a construction company BuildRight" | `create construction company buildright` |
| "how is Acme doing?" | `acme status` |
| "show Acme's tasks" | `acme task list` |
| "hire an engineer for Acme" | `acme hire engineer` |
| "hire a school nurse for Lincoln High" | `lincoln-high hire school-nurse` |
| "Acme build a landing page" | `acme run product-development --feature "landing page"` |
| "show all companies" | `list` |
| "delete Acme" | `delete company acme` |

---

## 4. Skill Definitions

### 4.1 SKILL.md (Main Entry Point)

Responsibilities:
1. **Parse command** — extract company name, action, arguments
2. **Route to sub-skill** — dispatch to company-generator, agent-spawner, or company-manager
3. **Inject company context** — read `companies/<name>/manifest.md` and `companies/<name>/structure.md` before executing any company-scoped command
4. **Log all operations** — append to `companies/<name>/logs/audit.jsonl`

Command parsing logic:
```
If no company name detected AND action is "create" → company-generator
If no company name detected AND action is "list" → list companies/ directory
If company name detected → verify companies/<name>/ exists → route action
If company name not found → suggest "create" command
```

### 4.2 company-generator/SKILL.md

**Input:** company name, type (any string), industry, optional flags (quickstart, budget, headcount)

**Steps:**
1. Validate company name doesn't already exist in `companies/`
2. **Resolve blueprint:**
   - If type is a known type (SaaS, Consulting, Agency, E-commerce, Research) → use pre-built agent roster
   - If type is anything else → AI infers org blueprint (departments, agents, capability map)
   - For unknown types: present blueprint to user for approval/modification
3. Create `companies/<name>/` directory tree with **dynamic departments** derived from blueprint
4. Write `companies/<name>/manifest.md` with company config **and full blueprint**
5. Write `companies/<name>/structure.md` with org chart (initially all agents idle)
6. Copy/generate agent `.md` files:
   - If `agents/<role>.md` exists in plugin templates → copy it (built-in)
   - If not → generate from `templates/agent-template.md` with AI-inferred fields
   - If `--quickstart`: only silicon-agent + 2 top agents
7. Copy all workflow `.flow` files from `workflows/` to `companies/<name>/workflows/` with capability-binding headers
8. Create agent state files in `companies/<name>/departments/<dept>/agents/`
9. Initialize `companies/<name>/memory/` (company-knowledge.md, shared-context.md, failures.md)
10. Initialize `companies/<name>/taskwall.md` (empty)
11. Initialize `companies/<name>/logs/audit.jsonl` (creation entry)
12. Run validation: all files present, no circular reports_to
13. Report result to user

**Known type → agent mapping** (backward compatible):

| Type | Agents | Departments |
|------|--------|-------------|
| SaaS | silicon-agent, PM, Engineer, QA, Marketing, Sales, Support, Finance | executive, engineering, marketing, sales, support, finance |
| Consulting | silicon-agent, PM, Engineer, QA, Research, Finance | executive, engineering, finance |
| Agency | silicon-agent, PM, Engineer, Marketing, Sales | executive, engineering, marketing, sales |
| E-commerce | silicon-agent, PM, Engineer, QA, Marketing, Sales, Support, Finance | executive, engineering, marketing, sales, support, finance |
| Research | silicon-agent, Research, Engineer, PM, Finance | executive, engineering, finance |

**Unknown types** → AI infers appropriate agents and departments dynamically. User confirms before creation.

### 4.3 agent-spawner/SKILL.md

**Input:** company name, role, optional overrides

**3-tier role resolution:**
1. **Built-in**: Check if `agents/<role>.md` exists in plugin templates → copy it
2. **Blueprint**: Check company blueprint in manifest → generate from template
3. **Custom**: If neither → AI infers department/level/reports_to → present to user for confirmation → generate from template

**Steps:**
1. Verify `companies/<name>/` exists
2. Read `companies/<name>/manifest.md` — check headcount limit
3. Read `companies/<name>/structure.md` — check current headcount
4. If limit reached → report error, suggest removing an agent
5. Resolve role through 3-tier system (built-in → blueprint → custom)
6. For built-in: copy `agents/<role>.md` to `companies/<name>/agents/`
7. For blueprint/custom: generate from `templates/agent-template.md` with resolved values
8. Create department directory if not present: `companies/<name>/departments/<dept>/`
9. Create state file: `companies/<name>/departments/<dept>/agents/<role>-state.md` (state: idle)
10. Update `companies/<name>/structure.md` — add to agent table
11. Create inbox: `companies/<name>/messages/inbox/<role>.md`
12. Update manifest (headcount, blueprint if custom)
13. Log to `companies/<name>/logs/audit.jsonl`

### 4.4 company-manager/SKILL.md

Handles all company-scoped read operations:

**Status:** Read manifest + structure + taskwall → present dashboard
**Report:** Aggregate department outputs, KPIs, budget
**Budget:** Read manifest budget, scan audit.jsonl for token spend
**Compact:** Run memory compaction on company memory files
**Task List:** Read and format taskwall.md
**Agents:** List all agents with states from structure.md
**Delete:** Archive company to `companies/<name>/archive/`, remove from active

---

## 5. Task Wall

Inspired by AI-company's task wall. Stored in `companies/<name>/taskwall.md`.

```markdown
# Task Wall — <Company Name>

## In Progress
| ID | Task | Assigned To | Priority | Started | Pipeline |
|----|------|-------------|----------|---------|----------|
| 1 | Build login page | engineer | P1 | 2026-05-30 | feature |

## Pending
| ID | Task | Assigned To | Priority | Created | Pipeline |
|----|------|-------------|----------|---------|----------|
| 2 | Write PRD for dashboard | product-manager | P2 | 2026-05-30 | feature |
| 3 | Fix auth bug | engineer | P0 | 2026-05-30 | bugfix |

## Done
| ID | Task | Completed By | Completed At | Result |
|----|------|-------------|-------------|--------|
| 0 | Company setup | silicon-agent | 2026-05-30 | ✅ success |
```

**Task lifecycle:**
```
pending → in_progress → done (success)
                      → blocked (needs input/approval)
                      → failed (triggers recovery)
```

---

## 6. Workflows (Company-Scoped)

All workflows read from and write to `companies/<name>/`. Each workflow file lives in the plugin's `workflows/` as a template and is copied to `companies/<name>/workflows/` during company creation.

### 6.1 Pipeline Templates

| Pipeline | Phases | Use Case |
|----------|--------|----------|
| `feature` | Research → Design → Implement → Review → Test → Deploy | New features |
| `bugfix` | Reproduce → Fix → Test → Deploy | Bug fixes |
| `research` | Investigate → Analyze → Report | Research tasks |
| `refactor` | Analyze → Plan → Refactor → Test | Code cleanup |
| `quick-fix` | Implement → Test | Trivial changes |
| `hotfix` | Fix → Test → Deploy (skip review) | Production emergencies |
| `spike` | Investigate → Report | Time-boxed exploration |

### 6.2 Orchestration Workflows

| Workflow | Purpose |
|----------|---------|
| `product-development.flow` | End-to-end: PRD → Architecture → Implement → QA → Release |
| `marketing-campaign.flow` | Brief → Content → Distribute → Report |
| `bugfix.flow` | Report → Reproduce → Fix → Verify → Deploy |
| `recovery.flow` | Error → Classify → Retry/Fallback/Escalate/Abort |
| `pivot.flow` | Assess → Decide → Realign → Resume |

### 6.3 Workflow Agent Resolution

Workflows reference agent roles by name (e.g., "research-agent", "engineer"). When a company doesn't have a built-in agent with that name, the system resolves it through:

1. **Exact match**: `companies/<name>/agents/<role>.md` exists → use it
2. **Capability map**: Map the role name to a capability, look up in manifest's capability map → use the mapped agent
3. **Ask user**: If neither resolves → ask which agent should handle this phase

**Capability mapping:**
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

This means a school can run the "research" workflow — "research-agent" maps to the school's "curriculum-coordinator" via the capability map.

---

## 7. Failure Alchemy

Inspired by AI-company. When a task fails:

1. **Log failure** in `companies/<name>/memory/failures.md`:
   ```markdown
   ## Failure: <task description>
   - **Date**: <timestamp>
   - **Agent**: <agent name>
   - **Error**: <error description>
   - **Root Cause**: <analysis>
   - **Lesson**: <what to avoid next time>
   - **Category**: transient | agent_error | task_error | system_error
   ```

2. **Antibody** — The failure entry itself prevents the same mistake
3. **Recovery** — Route to `recovery.flow` (retry → fallback → escalate → abort)

---

## 8. Agent Lifecycle

Each agent in a company has a state file: `companies/<name>/departments/<dept>/agents/<role>-state.md`

```yaml
---
state: idle          # idle | active | blocked | waiting_approval | done
assigned_task: null
task_id: null
started_at: null
blockers: []
waiting_approval: false
---
# Current Work
(None)
```

**State transitions:**
```
idle + task_assigned → active
active + needs_input → blocked
active + needs_approval → waiting_approval
waiting_approval + approved → active
waiting_approval + rejected → active (with feedback)
active + completed → done
done + new_task → idle
```

---

## 9. Permission Matrix

| Invoker | Can Spawn | Can Assign | Can Approve | File Access |
|---------|-----------|------------|-------------|-------------|
| CEO (Human) | Anyone | Anyone | Anyone | All |
| SiliconAgent | Anyone | Anyone | Anyone | All (within company) |
| COO | Dept Heads+ | Dept Heads+ | Level 3 | Dept + shared |
| Dept Head | ICs only | ICs only | ICs | Own dept |
| IC | No one | No one | No | Own dept only |

**Guard rails** (defined in `.claude-plugin/guard-rails.yaml`):
- Protected files: manifest.md, structure.md, hooks.json, workflows/*.flow
- Only CEO (Human) or SiliconAgent can modify protected files
- Each agent has allowed/denied paths

---

## 10. Memory System

Per-company memory files in `companies/<name>/memory/`:

| File | Purpose | Max Size | Compaction |
|------|---------|----------|------------|
| `company-knowledge.md` | Accumulated facts, decisions | 8,000 tokens | Archive old, keep 20 recent |
| `shared-context.md` | Current session context | 5,000 tokens | Summarize, keep 10 recent |
| `failures.md` | Failure alchemy log | 3,000 tokens | Archive resolved failures |

**Auto-compact triggers** (in `companies/<name>/memory/auto-compact.yaml`):
- shared-context.md > 5,000 tokens → summarize older entries
- company-knowledge.md > 8,000 tokens → archive entries older than 7 days
- Inbox messages > 50 → merge into shared-context.md

---

## 11. Context Management

**Working set strategy:**
- Max 10 agents in context simultaneously
- Active agents always loaded; idle agents loaded on demand
- When context > 70%: compact memory → unload idle agents → reload working set

**Per-session context budget:**
- Shared memory: 5,000 tokens max
- Per-agent working memory: 2,000 tokens
- Company manifest + structure: always loaded (small)

---

## 12. Hooks

| Hook | Script | Purpose |
|------|--------|---------|
| `SessionStart` | Load active company context | If a company was active last session, inject its state |
| `PreCompact` | Summarize company state | Keep active tasks, blockers, decisions; drop old chatter |
| `SessionEnd` | Save company state | Persist current state to company memory files |
| `PostAgentRun` | Audit log | Append agent action to company's audit.jsonl |

---

## 13. Audit Trail

Per-company: `companies/<name>/logs/audit.jsonl`

```jsonl
{"ts":"2026-05-30T10:00:00Z","agent":"silicon-agent","action":"create_company","company":"acme","result":"success"}
{"ts":"2026-05-30T10:01:00Z","agent":"silicon-agent","action":"spawn_agent","company":"acme","target":"engineer","result":"success"}
{"ts":"2026-05-30T10:05:00Z","agent":"product-manager","action":"write_prd","company":"acme","result":"success","tokens":1200}
{"ts":"2026-05-30T10:10:00Z","agent":"engineer","action":"implement","company":"acme","result":"failed","error":"test_failure"}
```

---

## 14. Output Versioning

Agent outputs stored in `companies/<name>/outputs/<agent>/`:

```
outputs/
├── product-manager/
│   ├── prd-login-2026-05-30-v1.md
│   └── prd-login-2026-05-30-v2.md
├── engineer/
│   └── auth-impl-2026-05-30-v1.md
└── qa/
    └── test-report-2026-05-30.md
```

Format: `{artifact}-{date}-v{n}.md`

---

## 15. Inter-Agent Communication

Per-company inbox/outbox in `companies/<name>/messages/`:

```
messages/
├── inbox/
│   ├── product-manager.md      # Messages for PM
│   ├── engineer.md             # Messages for Engineer
│   └── ...
└── outbox/
    ├── product-manager.md
    ├── engineer.md
    └── ...
```

**Message format** (in inbox .md files):
```markdown
## From: <sender> | Priority: <P0-P3> | Date: <timestamp>
**Task:** <description>
**Input Spec:** <what was given>
**Acceptance Criteria:** <how to validate>
---
```

---

## 16. Quality Gates

Quality gates are defined in each agent's definition file. For built-in agents, these are software-development oriented. For dynamically generated agents, quality gates are AI-inferred based on the role and industry.

**Built-in agent quality gates:**

| Agent | Required Output |
|-------|-----------------|
| Product Manager | PRD with user stories, acceptance criteria, priority scores (P0-P3) |
| Engineer | Code with tests, passing CI, documentation |
| QA Engineer | Test plan with coverage %, pass/fail report |
| Marketing Manager | Campaign brief with channels, budget, KPIs |
| Sales Agent | Lead list with qualification scores |
| Research Agent | Report with 3+ sources, confidence level, recommendations |
| Finance Agent | Budget report with department breakdown, alerts |
| Support Agent | Issue classified with severity, resolution or escalation |

**Dynamic agent quality gates** (examples for non-standard types):

| Agent Type | Quality Gate Example |
|-----------|---------------------|
| Teacher (school) | Lesson plan with objectives, activities, assessment criteria |
| Principal (school) | Policy document with rationale, implementation plan, success metrics |
| Site Manager (construction) | Project plan with timeline, safety requirements, resource allocation |
| Quality Inspector (semiconductor) | Test report with yield data, defect analysis, corrective actions |

---

## 17. KPIs (Per Agent)

| Agent | Metrics |
|-------|---------|
| PM | PRDs completed, on-time %, avg revisions |
| Engineer | Tasks completed, test pass %, bugs caught by QA |
| QA | Test plans created, defects caught, coverage % |
| Marketing | Campaigns launched, engagement rate, leads generated |
| Sales | Leads qualified, conversion rate, pipeline value |
| Finance | Report accuracy, alert timeliness |

---

## 18. Validation

`scripts/validate-agent.sh` must work on both:
- Plugin template agents: `agents/*.md`
- Company instance agents: `companies/<name>/agents/*.md`

Usage: `./validate-agent.sh <path-to-agents-dir>`

Checks:
1. Required frontmatter fields (name, description, model, tools, level, reports_to, department)
2. Name format: 3-50 chars, lowercase with hyphens
3. Description has triggering conditions
4. Required sections (Responsibilities, Authority)
5. No circular reports_to dependencies

---

## 19. Smoke Tests

| # | Test | Input | Expected |
|---|------|-------|----------|
| 1 | Create company | `/silicon-agent create SaaS company Acme` | `companies/acme/` with manifest, structure, agents, workflows |
| 2 | Quickstart | `/silicon-agent create SaaS company Test --quickstart` | 3 agents only |
| 3 | List companies | `/silicon-agent list` | Shows Acme, Test |
| 4 | Company status | `/silicon-agent acme status` | Dashboard with agents, budget, tasks |
| 5 | Hire agent | `/silicon-agent acme hire qa-engineer` | Agent added to company |
| 6 | Add task | `/silicon-agent acme task add "Build login"` | Task on taskwall |
| 7 | Run workflow | `/silicon-agent acme run product-development` | Workflow executes within company |
| 8 | Budget check | `/silicon-agent acme budget` | Budget report |
| 9 | Company report | `/silicon-agent acme report` | Full company report |
| 10 | Compact memory | `/silicon-agent acme compact` | Memory compacted |
| 11 | Delete company | `/silicon-agent delete company Test` | Company archived |
| 12 | Validation | `./validate-agent.sh companies/acme/agents/` | All agents valid |
| 13 | Plugin untouched | `git diff agents/` | No changes to plugin files |
| 14 | Isolation | Create 2 companies, modify one | Other unaffected |

---

## 20. Key Principles

1. **Factory pattern** — Plugin is code/templates. Companies are data.
2. **Isolation** — Each company is fully independent. No cross-company state.
3. **Idempotent creation** — Creating the same company twice should fail gracefully (already exists).
4. **Read-only plugin** — The `agents/`, `skills/`, `workflows/`, `templates/` directories are NEVER modified by company operations.
5. **Mutable only under `companies/`** — The single source of truth for all generated data.
6. **Command routing** — All operations go through SKILL.md which parses and dispatches.
7. **Audit everything** — Every mutation logged to company's audit.jsonl.
8. **Graceful degradation** — Context limits trigger compaction, not failure.
