# Marketplace Tests — SiliconAgent Hub

## Test Execution Instructions
Run each test manually via `/silicon-agent` commands. Verify expected results.

---

## Test M1: Browse Company Packs

**Input:** `/silicon-agent browse packs`

**Expected:**
- Lists all 10 packs: saas, consulting, agency, e-commerce, research, school, construction, hospital, semiconductor, restaurant
- Each pack shows: name, industry, agent count, description
- Output is formatted as a table

---

## Test M2: Browse Agent Store

**Input:** `/silicon-agent browse agents`

**Expected:**
- Lists all agents grouped by category (Executive, Engineering, Education, Operations, Healthcare, Hospitality, Finance, Sales & Marketing)
- Shows 11 built-in agents + 6 marketplace agents = 17 total
- Each agent shows: name, description, [built-in] or [marketplace] tag

---

## Test M3: Browse Workflow Store

**Input:** `/silicon-agent browse workflows`

**Expected:**
- Lists all workflows grouped by category
- Shows 7 built-in workflows + 3 marketplace workflows = 10 total
- New workflows: curriculum-design, safety-audit, production-planning
- Each workflow shows: name, description, phase count

---

## Test M4: Search Marketplace

**Input:** `/silicon-agent search manufacturing`

**Expected:**
- Returns results matching "manufacturing":
  - Pack: semiconductor (Semiconductor Manufacturing)
  - Agent: production-planner (Manufacturing production planner)
  - Workflow: production-planning (Manufacturing capacity → plan → budget → schedule)

---

## Test M5: Info Pack Detail

**Input:** `/silicon-agent info packs school`

**Expected:**
- Shows full school pack.yaml content:
  - 7 agents (principal, vice-principal, curriculum-coordinator, teacher, counselor, admissions-coordinator, budget-manager)
  - 4 departments (administration, faculty, student-services, operations)
  - Capability map (researcher → curriculum-coordinator, implementer → teacher, etc.)

---

## Test M6: Install Pack — Create School from Pack

**Input:** `/silicon-agent install pack school company test-school`

**Expected:**
- System reads `marketplace/company-packs/school/pack.yaml`
- Shows pack details for confirmation
- On approval:
  - `companies/test-school/` created
  - Agents: master + 7 school agents
  - Departments: administration, faculty, student-services, operations (NOT the old fixed 6)
  - `master.md` copied from built-in `agents/master.md`
  - School agents (principal, teacher, etc.) copied from `marketplace/agent-store/agents/`
  - `manifest.md` includes `pack: school` field
  - Capability map from pack.yaml in manifest
  - All 7 built-in workflows + 3 marketplace workflows copied
  - Audit log: `{"action":"install_pack","pack":"school","company":"test-school"}`
  - Validation passes: `./scripts/validate-agent.sh companies/test-school/agents/` → 0 errors

---

## Test M7: Install Agent from Store to Company

**Input:** `/silicon-agent test-school install agent head-chef` (assuming a restaurant pack)
Or: `/silicon-agent test-school hire safety-inspector`

**Expected:**
- 4-tier resolution: not in built-in → check marketplace/agent-store/agents/safety-inspector.md → found!
- Copy safety-inspector.md from store to `companies/test-school/agents/safety-inspector.md`
- Create department `safety/` if not present
- Update structure.md and manifest.md
- Audit log with source=marketplace

---

## Test M8: Install Workflow from Store to Company

**Input:** `/silicon-agent test-school install workflow curriculum-design`

**Expected:**
- System checks `marketplace/workflow-store/workflows/curriculum-design.flow` → found
- Copy to `companies/test-school/workflows/curriculum-design.flow`
- Prepend capability-binding header for test-school's capability map
- Confirm installation

---

## Test M9: Backward Compatibility — SaaS Still Works

**Steps:**
1. `/silicon-agent create SaaS company compat-test`
2. Check no marketplace confirmation prompt (known type, Path A)
3. Check 8 agents (master + 7 SaaS agents from built-in)
4. Check 6 departments (executive, engineering, marketing, sales, support, finance)
5. Check manifest does NOT have `pack:` field (used Path A, not pack)

**Expected:**
- All existing smoke tests (1-18) still pass unchanged
- SaaS creation is identical to pre-marketplace behavior

---

## Test M10: Pack Takes Priority Over AI Inference

**Steps:**
1. `/silicon-agent create school company direct-test` (without "install pack")
2. System should check Path C first → `marketplace/company-packs/school/pack.yaml` exists
3. Use pack blueprint directly (same result as M6)
4. No AI inference needed

**Expected:**
- Pack resolution (Path C) takes priority over AI inference (Path B)
- Same school structure as M6

---

## Test M11: Marketplace Agent Validation

**Input:** `./scripts/validate-agent.sh marketplace/agent-store/agents/`

**Expected:**
- All 6 marketplace agents pass validation
- Each has required frontmatter (name, description, model, tools, level, reports_to, department)
- Each has Responsibilities and Authority sections
- No circular reporting dependencies
- Exit code: 0
