# Smoke Tests — SiliconAgent Plugin

## Test Execution Instructions
Run each test manually via `/silicon-agent` commands. Verify expected results.

---

## Test 1: Create Known Company Type (Backward Compat)

**Input:** `/silicon-agent create SaaS company Acme`

**Expected:**
- `companies/acme/` directory created with all subdirectories
- `companies/acme/manifest.md` exists with type=SaaS, status=active
- `companies/acme/structure.md` exists with agent registry table
- `companies/acme/taskwall.md` exists with setup task done
- Agent files copied: silicon-agent, product-manager, engineer, qa-engineer, marketing-manager, sales-agent, support-agent, finance-agent (8 agents)
- Departments created: executive, engineering, marketing, sales, support, finance
- Workflow files copied: all 7 .flow files
- Memory files initialized: company-knowledge.md, shared-context.md, failures.md
- Audit log created with `create_company` entry
- NO user confirmation prompt (known type, backward compatible)
- User sees success message with summary

---

## Test 2: Quickstart Company

**Input:** `/silicon-agent create SaaS company Test --quickstart`

**Expected:**
- `companies/test/` directory created
- Only 3 agent files: silicon-agent, product-manager, engineer
- All other structure same as full company
- Headcount.current = 3

---

## Test 3: List Companies

**Input:** `/silicon-agent list`

**Expected:**
- Shows both Acme and Test
- Each with name, type, agent count, status

---

## Test 4: Company Status

**Input:** `/silicon-agent acme status`

**Expected:**
- Dashboard showing: name, type, agents (8), tasks, budget
- All agents shown as idle
- No active or pending tasks (only setup done task)

---

## Test 5: Hire Built-in Agent

**Input:** `/silicon-agent acme hire research-agent`

**Expected:**
- `companies/acme/agents/research-agent.md` created (copied from built-in template)
- Agent state file created in departments/executive/agents/
- structure.md updated with new agent row
- manifest.md headcount incremented
- Audit log entry for spawn_agent with source=builtin
- Company headcount: 9/10

---

## Test 6: Add Task

**Input:** `/silicon-agent acme task add "Build login page"`

**Expected:**
- Task added to taskwall.md with ID=1
- Status: pending, Priority: P2
- Assigned to: unassigned
- Task appears in Pending section

---

## Test 7: Run Workflow

**Input:** `/silicon-agent acme run product-development`

**Expected:**
- Workflow reads from `companies/acme/workflows/product-development.flow`
- Agent resolution: exact match for research-agent, engineer, qa-engineer, product-manager (all exist)
- Phases execute in sequence (Research → Design → Implement → QA → Release)
- Each phase delegates to the appropriate agent
- Outputs generated in `companies/acme/outputs/<agent>/`
- Task status updated on taskwall

---

## Test 8: Budget Check

**Input:** `/silicon-agent acme budget`

**Expected:**
- Shows allocated, spent, remaining budget
- Per-agent breakdown
- Burn rate estimate

---

## Test 9: Company Report

**Input:** `/silicon-agent acme report`

**Expected:**
- Executive summary
- Department-by-department breakdown (dynamically read from structure.md)
- Financial summary
- Recent audit log entries
- Recommendations based on current state

---

## Test 10: Compact Memory

**Input:** `/silicon-agent acme compact`

**Expected:**
- Memory files checked against size limits
- Files over limit are summarized
- Reduction percentages reported
- Audit log entry for compaction

---

## Test 11: Delete Company

**Input:** `/silicon-agent delete company Test`

**Expected:**
- Company archived before deletion
- `companies/test/` directory removed
- `/silicon-agent list` no longer shows Test
- Acme still intact (isolation)

---

## Test 12: Agent Validation

**Input:** `./scripts/validate-agent.sh companies/acme/agents/`

**Expected:**
- All agent files pass validation
- No missing frontmatter fields
- No circular reporting dependencies
- Works with arbitrary hierarchy (not just "CEO (Human)" termination)
- Exit code: 0

---

## Test 13: Plugin Untouched

**Input:** Check that plugin template files are unchanged

**Expected:**
- `git diff agents/` shows no changes
- `git diff workflows/` shows no changes
- `git diff skills/` shows no changes
- Only `companies/` directory has new content

---

## Test 14: Company Isolation

**Steps:**
1. Create two companies: `/silicon-agent create SaaS company alpha` and `/silicon-agent create Consulting company beta`
2. Add task to alpha: `/silicon-agent alpha task add "Alpha task"`
3. Check beta: `/silicon-agent beta task list`

**Expected:**
- Alpha's task wall has "Alpha task"
- Beta's task wall does NOT have "Alpha task"
- No cross-contamination between companies
- Different agent rosters (SaaS vs Consulting)

---

## Test 15: Create Non-Standard Company Type (School)

**Input:** `/silicon-agent create school company lincoln-high`

**Expected:**
- System detects "school" is NOT a known type → triggers AI blueprint inference
- Blueprint is presented to user for approval showing:
  - Appropriate departments (e.g., administration, faculty, student-services, operations)
  - Appropriate agents (e.g., principal, teachers, counselor, budget-manager)
  - Capability map (researcher → ?, implementer → ?, reviewer → ?, etc.)
  - Reporting hierarchy (teachers → curriculum-coordinator → principal → CEO)
- User can approve, modify, or cancel
- On approval:
  - `companies/lincoln-high/` created with dynamic departments
  - `silicon-agent.md` copied from built-in templates
  - All other agents generated from `templates/agent-template.md` (not copied from `agents/`)
  - Generated agents have appropriate responsibilities, triggers, and quality gates
  - `manifest.md` includes full blueprint section with capability map
  - All 7 workflows copied with capability-binding headers
  - Audit log entry includes `type=school`
  - Validation passes: `./scripts/validate-agent.sh companies/lincoln-high/agents/` → 0 errors

---

## Test 16: Hire Custom Agent Not in Blueprint

**Input:** `/silicon-agent lincoln-high hire school-nurse`

**Expected:**
- System detects "school-nurse" is not in built-in templates or company blueprint
- System offers to create custom agent with AI-inferred:
  - Department (e.g., student-services)
  - Level (e.g., 3)
  - Reports to (e.g., counselor)
  - Triggers, tools, responsibilities
- User confirms → agent generated from template
- Blueprint in manifest.md updated with new agent
- structure.md updated
- Audit log entry with source=custom

---

## Test 17: Run Workflow with Capability-Mapped Agents

**Input:** `/silicon-agent lincoln-high run research`

**Expected:**
- Research workflow references "research-agent"
- Agent resolution chain:
  1. Level 1: No `research-agent.md` in `companies/lincoln-high/agents/` → skip
  2. Level 2: "research-agent" maps to capability "researcher" → manifest capability map says researcher = `curriculum-coordinator` → use curriculum-coordinator
- Workflow executes with curriculum-coordinator handling research phases
- Outputs stored in `companies/lincoln-high/outputs/curriculum-coordinator/`

---

## Test 18: Backward Compatibility Check

**Steps:**
1. Delete all test companies
2. `/silicon-agent create SaaS company backward-test`
3. Check agents: must be exactly 8 (silicon-agent, product-manager, engineer, qa-engineer, marketing-manager, sales-agent, support-agent, finance-agent)
4. Check departments: must be exactly 6 (executive, engineering, marketing, sales, support, finance)

**Expected:**
- Known types still use hardcoded rosters without AI inference
- No user confirmation prompt for known types
- Exact same output as before this change
- All existing tests (1-14) still pass

---

## Test 19: Free-Form Task — Simple (Existing Agents + Existing Workflow)

**Input:** `/silicon-agent acme task "research competitor pricing for Q3"`

**Expected:**
- Task executor analyzes intent: research task
- Gap analysis: research-agent exists, research workflow exists → no gaps
- Task added to taskwall with status: in_progress
- Research workflow executes with research-agent
- Deliverable: competitor pricing report in `companies/acme/outputs/research-agent/`
- Task wall updated: task → done
- Audit log entries for task_start and task_complete

---

## Test 20: Free-Form Task — Complex with Agent Generation (School Exam)

**Input:** `/silicon-agent lincoln-high conduct maths exam slip test for grade 10 on coming saturday`

**Expected:**
- Task executor analyzes intent: exam management, needs exam-coordinator role
- Gap analysis: no exam-coordinator agent exists → offer to create
- User confirms → exam-coordinator generated from template with:
  - Department: faculty or administration
  - Tools: Read, Write, Glob, Grep (for preparing exam content)
  - Triggers: "exam", "test", "assessment", "slip test"
  - Responsibilities: exam preparation, scheduling, evaluation
- Gap analysis: no "exam-conduct" workflow exists → generate dynamic workflow:
  - Phase 1: Prepare question paper (exam-coordinator)
  - Phase 2: Schedule logistics (exam-coordinator)
  - Phase 3: Conduct exam (exam-coordinator + math-teacher)
  - Phase 4: Evaluate and report (math-teacher)
- Dynamic workflow saved to `companies/lincoln-high/workflows/dynamic-exam-conduct-<date>.flow`
- All phases execute, outputs collected
- Deliverables: question paper, schedule, answer key, grading report
- New agent and workflow recorded in company knowledge

---

## Test 21: Free-Form Task — Strategic Multi-Agent (Fab Production)

**Input:** `/silicon-agent chipworks double production from unit 3, prepare budget and plan`

**Expected:**
- Task executor analyzes intent: production planning, cross-department coordination
- Gap analysis: may need production-planner agent → generate if missing
- Dynamic workflow generated with multiple phases:
  - Phase 1: Current state analysis (production-planner)
  - Phase 2: Capacity assessment (production-planner + quality-inspector)
  - Phase 3: Budget preparation (finance-equivalent agent)
  - Phase 4: Implementation roadmap (production-planner)
  - Phase 5: Risk assessment (quality-inspector)
- All phases execute with capability-mapped agents
- Deliverables: capacity report, budget plan, roadmap, risk matrix
- Budget impact tracked in audit log

---

## Test 22: Free-Form Task — Natural Language Catch-All

**Input:** `/silicon-agent lincoln-high organize parent-teacher conference next month`

**Expected:**
- Input doesn't match any known command (not status, hire, fire, etc.)
- Catch-all routing detects company "lincoln-high" → routes as task
- Task executor handles: analyzes, checks gaps, generates workflow, executes
- No need for user to explicitly say "task" — natural language works

---

## Test 23: Free-Form Task — Task Without Company (Error)

**Input:** `/silicon-agent prepare annual budget report`

**Expected:**
- No company name detected in input
- System responds: "Which company should handle this task? Available: <list>. Or create a new company first."

---

## Test 24: Dynamic Agent Generates Valid Files

**Prerequisite:** Test 20 completed (exam-coordinator created)

**Input:** `./scripts/validate-agent.sh companies/lincoln-high/agents/`

**Expected:**
- ALL agents pass validation, including dynamically generated exam-coordinator
- exam-coordinator.md has required frontmatter (name, description, model, tools, level, reports_to, department)
- No circular reporting dependencies introduced
- Exit code: 0
