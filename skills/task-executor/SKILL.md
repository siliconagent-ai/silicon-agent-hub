# Task Executor Skill — Dynamic Task Intake & Execution

## Description
Accepts ANY free-form task in natural language, auto-generates the right workflow, creates agents if needed, assigns work, executes, and delivers results. This is the "just get it done" layer on top of the company structure.

## Input
- **task** (required): Free-form natural language task description
- **company** (required): Company name (must exist)
- **priority** (optional): P0-P3 (default: P2)
- **assign-to** (optional): Specific agent role to handle

## Task Examples
| User Says | Parsed Intent |
|-----------|--------------|
| "conduct maths exam slip test on coming saturday" | Exam management task for a school |
| "we should get double produce from unit 3, prepare budget and plan" | Production planning for a fab |
| "design a new curriculum for grade 10 science" | Curriculum development for a school |
| "prepare safety audit report for site B" | Safety compliance for construction |
| "organize parent-teacher conference next month" | Event management for a school |
| "analyze why yield dropped in clean room 2 last quarter" | Root cause analysis for semiconductor |
| "create onboarding plan for 5 new teachers joining next term" | HR planning for a school |

## Execution Flow

### Phase 1: Task Analysis

**Parse the task to extract:**
1. **Intent**: What needs to happen (exam, budget, plan, analysis, event, audit, etc.)
2. **Domain**: What area of the company this touches (academics, production, safety, HR, etc.)
3. **Deliverables**: What the user expects as output (exam paper, budget report, plan document, etc.)
4. **Constraints**: Time, budget, scope mentioned in the task
5. **Urgency**: Is this time-sensitive?

### Phase 2: Gap Analysis — Do We Have What We Need?

Check the company's existing resources:

**Agents**: Read `companies/<name>/structure.md` for current agents.
- Do existing agents have the right capabilities for this task?
- If NO → generate needed agents (see Phase 3)

**Workflows**: Check if any existing workflow in `companies/<name>/workflows/` fits:
- `product-development` → for building/creating something new
- `research` → for investigation/analysis
- `bugfix` → for fixing a problem
- `marketing-campaign` → for marketing/outreach
- `hotfix` → for emergencies
- If NONE fit → generate a dynamic workflow (see Phase 3)

### Phase 3: Auto-Provision (Generate What's Missing)

#### 3a. Generate Agents (if needed)
If the task requires capabilities not covered by existing agents:

1. Determine what new agent(s) are needed based on the task
2. Generate from `templates/agent-template.md` with:
   - `name`: Role identifier (e.g., "exam-coordinator", "production-planner")
   - `department`: Relevant department for this company
   - `level`: Appropriate org level
   - `reports_to`: Appropriate manager
   - `triggers`: Task-specific trigger phrases
   - `tools`: Tools needed for this type of work
   - `responsibilities`: Task-relevant duties
3. Present to user: "This task needs a new agent: `<role>`. Create it? [yes / skip / modify]"
4. On approval → create agent files, update structure.md, update manifest
5. Log to audit: `{"action":"auto_spawn_agent","trigger":"task","task":"<task description>"}`

#### 3b. Generate Dynamic Workflow (if no pre-built workflow fits)
If no existing workflow matches the task:

1. AI generates a multi-phase workflow based on the task:
   ```
   Phase 1: <preparation phase>
   Phase 2: <execution phase>
   Phase 3: <review/validation phase>
   Phase 4: <delivery phase>
   ```
2. Each phase specifies:
   - **Agent**: Which agent (or capability) handles it
   - **Input**: What the phase receives
   - **Steps**: What to do
   - **Output**: What the phase produces
   - **Gate**: Quality check before next phase
3. Write workflow to `companies/<name>/workflows/dynamic-<task-slug>-<date>.flow`
4. Log to audit: `{"action":"generate_workflow","trigger":"task","workflow":"dynamic-<slug>"}`

### Phase 4: Add to Task Wall

Add the task to `companies/<name>/taskwall.md`:
- **ID**: Next available ID
- **Task**: Full description
- **Assigned To**: Lead agent for this task
- **Priority**: Determined from analysis
- **Pipeline**: Name of the selected/generated workflow
- **Status**: in_progress (start immediately)

### Phase 5: Execute

Execute the workflow phase by phase:

For each phase:
1. **Resolve the agent** — Use the 3-level workflow agent resolution:
   - Exact match in company agents
   - Capability map lookup
   - Ask user
2. **Prepare agent context** — Load:
   - Task description and requirements
   - Previous phase outputs (if any)
   - Company context (manifest, relevant memory)
3. **Execute phase** — Delegate to the agent
4. **Collect output** — Store in `companies/<name>/outputs/<agent>/<artifact>-<date>.md`
5. **Quality check** — Verify phase output meets the gate criteria
6. **If failed** → log failure, route to recovery
7. **Update task wall** — Track progress

### Phase 6: Deliver Results

1. Aggregate all phase outputs into a final deliverable
2. Update task wall: task → done
3. Present results to user:
```
✅ Task Complete: <task summary>

Deliverables:
  📄 <output-1>: <brief description> → companies/<name>/outputs/<agent>/<file>
  📄 <output-2>: <brief description> → companies/<name>/outputs/<agent>/<file>

Agents Used: <list>
Workflow: <pre-built or dynamic name>
Tokens Spent: <estimate>

Next Steps:
  → <suggested follow-up based on results>
```
4. Log to audit: `{"action":"task_complete","task":"<description>","result":"success","deliverables":<count>}`
5. Update company knowledge in memory

### Phase 7: Capture Learnings

- If anything was generated (agents, workflows), record in `companies/<name>/memory/company-knowledge.md`
- If any failures occurred, record in `companies/<name>/memory/failures.md`
- Update `companies/<name>/memory/shared-context.md` with current state

## Error Handling

| Error | Action |
|-------|--------|
| Company not found | "No company found for this task. Create one first: `/silicon-agent create <type> company <name>`" |
| Task too vague | Ask clarifying questions before proceeding |
| No suitable agent exists | Offer to generate one, or ask user to specify |
| Phase execution fails | Log failure, retry with refined instructions (max 2), then escalate |
| Budget exceeded | Alert user, pause execution, ask to increase budget or reduce scope |

## Dynamic Generation Patterns

### Agent Generation Checklist
When generating a new agent for a task:
- [ ] Name is unique in the company (check structure.md)
- [ ] Department exists or will be created
- [ ] Reports_to chain is valid (no circular deps)
- [ ] Tools are appropriate for the task
- [ ] Triggers include the task's domain keywords

### Workflow Generation Checklist
When generating a new workflow:
- [ ] Phases are sequential with clear handoffs
- [ ] Each phase has a single responsible agent
- [ ] Quality gates are defined for each phase
- [ ] Failure handling is specified
- [ ] File is saved to `companies/<name>/workflows/`

## Interaction Patterns

### Pattern 1: Simple Task (existing agents + existing workflow)
```
User: /silicon-agent acme run research on "competitor analysis for Q3"

→ Uses existing research-agent
→ Uses existing research workflow
→ Executes and delivers report
```

### Pattern 2: Complex Task (new agents + new workflow)
```
User: /silicon-agent lincoln-high conduct maths slip test for grade 10 on Saturday

→ Analyzes: exam management, needs exam-coordinator agent
→ Gap: no exam-coordinator exists → generates from template
→ Gap: no "exam-conduct" workflow → generates dynamic workflow:
    Phase 1: Prepare question paper (exam-coordinator)
    Phase 2: Schedule and logistics (exam-coordinator)
    Phase 3: Conduct exam (exam-coordinator + math-teacher)
    Phase 4: Evaluate and report (math-teacher)
→ Executes all phases
→ Delivers: question paper, schedule, answer key, grading rubric
```

### Pattern 3: Strategic Task (multi-agent collaboration)
```
User: /silicon-agent chipworks double production from unit 3, prepare budget and plan

→ Analyzes: production planning, needs cross-department coordination
→ Uses: production-manager, finance-agent, quality-inspector
→ Generates dynamic workflow:
    Phase 1: Current state analysis (production-manager)
    Phase 2: Capacity assessment (production-manager + quality-inspector)
    Phase 3: Budget preparation (finance-agent)
    Phase 4: Implementation plan (production-manager)
    Phase 5: Risk assessment (quality-inspector)
→ Executes all phases
→ Delivers: capacity report, budget plan, implementation roadmap, risk matrix
```
