# SiliconAgent Hub — Usage Guide

Complete step-by-step instructions for using the SiliconAgent Hub marketplace.

---

## Table of Contents

1. [Setup](#1-setup)
2. [Browse the Marketplace](#2-browse-the-marketplace)
3. [Create a Company — 3 Ways](#3-create-a-company--3-ways)
4. [Manage Agents](#4-manage-agents)
5. [Add and Track Tasks](#5-add-and-track-tasks)
6. [Run Pre-Built Workflows](#6-run-pre-built-workflows)
7. [Execute Dynamic Tasks (Free-Form)](#7-execute-dynamic-tasks-free-form)
8. [Monitor and Report](#8-monitor-and-report)
9. [Complete Walkthrough: School](#9-complete-walkthrough-school)
10. [Complete Walkthrough: Semiconductor Fab](#10-complete-walkthrough-semiconductor-fab)
11. [Complete Walkthrough: SaaS Startup](#11-complete-walkthrough-saas-startup)
12. [Command Reference](#12-command-reference)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Setup

```bash
# Run the setup script — validates the full hub structure
./scripts/setup.sh

# Expected output: all directories ✅, all skills ✅, agents validated ✅
```

---

## 2. Browse the Marketplace

Before creating anything, see what's available:

```bash
# List all 10 industry packs
/silicon-agent browse packs

# List all 17 agents (11 built-in + 6 marketplace)
/silicon-agent browse agents

# List all 10 workflows (7 built-in + 3 marketplace)
/silicon-agent browse workflows

# Search for something specific
/silicon-agent search manufacturing
/silicon-agent search education
/silicon-agent search safety

# Get details on a specific item
/silicon-agent info packs school
/silicon-agent info agents production-planner
/silicon-agent info workflows curriculum-design
```

---

## 3. Create a Company — 3 Ways

### Way 1: Install a Marketplace Pack (Recommended)

Best for: common industries with curated blueprints.

```bash
# Create a school from the marketplace pack
/silicon-agent install pack school company lincoln-high

# The system will:
# 1. Read marketplace/company-packs/school/pack.yaml
# 2. Show you the pack details (agents, departments, capabilities)
# 3. Ask: Approve? [yes / modify / cancel]
# 4. On approval → create company with curated agents and workflows
```

### Way 2: Classic Create (Known Types)

Best for: the 5 original tech company types. No confirmation needed.

```bash
/silicon-agent create SaaS company acme
/silicon-agent create Consulting company tech-advisors
/silicon-agent create Agency company creative-co
/silicon-agent create E-commerce company shop-now
/silicon-agent create Research company deep-labs
```

### Way 3: AI-Inferred (Any Type)

Best for: unusual company types not in the marketplace. AI infers the structure, you confirm.

```bash
# Any company type works — AI figures out the right structure
/silicon-agent create law-firm company legal-eagles
/silicon-agent create airline company sky-high-air
/silicon-agent create gym company fit-life

# With additional options:
/silicon-agent create startup company quick-co --quickstart        # Only 3 agents
/silicon-agent create nonprofit company help-org --industry "Education Charity" --budget 300000
```

---

## 4. Manage Agents

### View Current Agents

```bash
/silicon-agent acme agents
```

Output:
```
👥 Agents: acme (8 total)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| # | Agent | Department | Level | Reports To | State |
|---|-------|-----------|-------|------------|-------|
| 1 | master | executive | 0 | CEO | idle |
| 2 | product-manager | engineering | 2 | COO | idle |
| 3 | engineer | engineering | 3 | PM | idle |
| ... |
```

### Hire an Agent

```bash
# From built-in templates
/silicon-agent acme hire research-agent

# From marketplace store
/silicon-agent lincoln-high hire safety-inspector

# Custom agent (not in store — AI generates it)
/silicon-agent lincoln-high hire exam-coordinator
# → System: "This role doesn't exist. I'll infer: department=faculty, level=3, reports to=curriculum-coordinator. Create? [yes/modify/cancel]"
```

### Remove an Agent

```bash
/silicon-agent acme fire support-agent
# → Agent archived, structure updated
```

---

## 5. Add and Track Tasks

### Add Tasks

```bash
# Simple task
/silicon-agent acme task add "Build authentication system"

# With priority (P0=critical, P1=high, P2=medium, P3=low)
/silicon-agent acme task add "Fix login bug" --priority P0
```

### View Tasks

```bash
# View full task wall
/silicon-agent acme task list

# Check specific task status
/silicon-agent acme task 3 status
```

---

## 6. Run Pre-Built Workflows

```bash
# List available workflows
/silicon-agent browse workflows

# Run a workflow
/silicon-agent acme run product-development    # Research → PRD → Implement → QA → Release
/silicon-agent acme run research               # Investigate → Analyze → Report
/silicon-agent acme run bugfix                 # Report → Reproduce → Fix → Verify → Deploy

# Install a marketplace workflow to a company first
/silicon-agent lincoln-high install workflow curriculum-design
/silicon-agent lincoln-high run curriculum-design
```

---

## 7. Execute Dynamic Tasks (Free-Form)

This is the most powerful feature. Just describe what you need in natural language:

```bash
# School tasks
/silicon-agent lincoln-high conduct maths exam slip test for grade 10 on Saturday
/silicon-agent lincoln-high design a new science curriculum for grade 8
/silicon-agent lincoln-high organize parent-teacher conference next month
/silicon-agent lincoln-high prepare annual budget report for next academic year

# Semiconductor fab tasks
/silicon-agent chipworks double production from unit 3, prepare budget and plan
/silicon-agent chipworks analyze why yield dropped in clean room 2 last quarter
/silicon-agent chipworks prepare preventive maintenance schedule for Q3

# Construction tasks
/silicon-agent buildright prepare safety audit report for site B
/silicon-agent buildright plan resource allocation for the highway project
/silicon-agent buildright review subcontractor bids for electrical work

# SaaS tasks
/silicon-agent acme research competitor pricing and prepare strategy document
/silicon-agent acme build a landing page for the new product launch
/silicon-agent acme prepare Q3 marketing campaign for enterprise segment
```

The system automatically:
1. Analyzes your task intent and required deliverables
2. Checks if existing agents can handle it
3. Generates new agents if needed (asks your permission first)
4. Creates a dynamic workflow if no pre-built one fits
5. Executes phase by phase
6. Delivers results

---

## 8. Monitor and Report

```bash
# Quick dashboard
/silicon-agent acme status

# Full company report (departments, KPIs, financials, activity)
/silicon-agent acme report

# Budget breakdown
/silicon-agent acme budget

# List all companies
/silicon-agent list

# Compact memory when context gets large
/silicon-agent acme compact

# Delete a company (archived first)
/silicon-agent delete company acme
```

---

## 9. Complete Walkthrough: School

```
Step 1: Browse available packs
  /silicon-agent browse packs
  → See "school" pack with 7 agents, Education industry

Step 2: Check pack details
  /silicon-agent info packs school
  → See: principal, vice-principal, curriculum-coordinator, teacher, counselor,
    admissions-coordinator, budget-manager
  → Departments: administration, faculty, student-services, operations

Step 3: Create the school
  /silicon-agent install pack school company lincoln-high
  → System shows blueprint → approve → company created with 8 agents (master + 7 school)

Step 4: Verify
  /silicon-agent lincoln-high status
  → Dashboard shows all 8 agents idle, no tasks, budget available

Step 5: Add a task
  /silicon-agent lincoln-high task add "Design grade 10 science curriculum for next term"

Step 6: Execute a free-form task
  /silicon-agent lincoln-high conduct maths exam slip test for grade 10 on coming saturday
  → System detects no exam-coordinator → generates one from template
  → System generates dynamic exam workflow: prepare → schedule → conduct → evaluate
  → Executes all phases
  → Delivers: question paper, schedule, answer key, grading report

Step 7: Check results
  /silicon-agent lincoln-high task list
  → Shows completed tasks with deliverables

Step 8: Get a full report
  /silicon-agent lincoln-high report
  → Executive summary, department breakdown, financials, recent activity
```

---

## 10. Complete Walkthrough: Semiconductor Fab

```
Step 1: Create the fab
  /silicon-agent install pack semiconductor company chipworks
  → 7 agents: master, fab-director, production-planner, process-engineer,
    quality-inspector, equipment-technician, supply-chain-coordinator

Step 2: Execute a production planning task
  /silicon-agent chipworks double production from unit 3, prepare budget and plan
  → System uses existing agents (no new ones needed)
  → Generates dynamic workflow:
      Analyze capacity (production-planner)
    → Plan production (production-planner)
    → Prepare budget (supply-chain-coordinator)
    → Schedule (production-planner)
    → Risk assessment (quality-inspector)
  → Delivers: capacity report, production plan, budget, schedule, risk matrix

Step 3: Run a safety audit
  /silicon-agent chipworks install workflow safety-audit
  /silicon-agent chipworks run safety-audit
  → 5-phase safety audit workflow executes with quality-inspector

Step 4: Research a yield problem
  /silicon-agent chipworks analyze why yield dropped in clean room 2 last quarter
  → System uses research capability (process-engineer) to investigate
  → Delivers root cause analysis with recommendations
```

---

## 11. Complete Walkthrough: SaaS Startup

```
Step 1: Create the company (classic way — no confirmation needed)
  /silicon-agent create SaaS company acme
  → 8 agents from built-in templates, no marketplace needed

Step 2: Hire an extra agent
  /silicon-agent acme hire research-agent
  → Copied from built-in templates

Step 3: Add tasks
  /silicon-agent acme task add "Build user authentication"
  /silicon-agent acme task add "Design pricing page"
  /silicon-agent acme task add "Set up CI/CD pipeline"

Step 4: Run a product development workflow
  /silicon-agent acme run product-development
  → Research (research-agent) → PRD (product-manager) → Implement (engineer)
  → QA (qa-engineer) → Release (master)

Step 5: Execute a free-form marketing task
  /silicon-agent acme research competitor pricing and prepare strategy
  → Uses existing research-agent → delivers competitive analysis report

Step 6: Monitor
  /silicon-agent acme budget     → Token spend breakdown
  /silicon-agent acme report     → Full company report
  /silicon-agent acme status     → Quick dashboard
```

---

## 12. Command Reference

| Command | What It Does |
|---------|-------------|
| `browse packs` | List all 10 industry packs |
| `browse agents` | List all 17 agents by category |
| `browse workflows` | List all 10 workflows by category |
| `install pack <name> company <co>` | Create company from curated pack |
| `search <query>` | Search packs, agents, workflows |
| `info <type> <name>` | Show details for a marketplace item |
| `create <type> company <name>` | Create company (known type or AI-inferred) |
| `create <type> company <name> --quickstart` | Minimal: 3 agents |
| `list` | Show all companies |
| `delete company <name>` | Archive and remove |
| `<co> status` | Company dashboard |
| `<co> agents` | List agents with states |
| `<co> hire <role>` | Hire from store/blueprint/custom |
| `<co> fire <role>` | Remove agent |
| `<co> task add "<desc>"` | Add task to task wall |
| `<co> task list` | View task wall |
| `<co> run <workflow>` | Run a workflow |
| `<co> <anything>` | Dynamic free-form task execution |
| `<co> report` | Full company report |
| `<co> budget` | Budget breakdown |
| `<co> compact` | Compress memory files |
| `<co> install workflow <name>` | Add workflow from store |

---

## 13. Troubleshooting

| Problem | Solution |
|---------|----------|
| "Company not found" | Create it first: `/silicon-agent install pack <type> company <name>` |
| "Agent not found" | Browse available: `/silicon-agent browse agents` or create custom: `<co> hire <new-role>` |
| "Workflow not found" | Browse available: `/silicon-agent browse workflows` or install: `<co> install workflow <name>` |
| "Headcount limit reached" | Remove an agent: `<co> fire <role>` or increase max in manifest |
| "Unknown command" | Use natural language — the system routes free-form input as tasks |
| "Pack not found" | Check available packs: `/silicon-agent browse packs` — or use `create` for AI inference |
| Validation errors | Run: `./scripts/validate-agent.sh <agents-dir>` to check agent files |

---

## Validation Commands

```bash
# Validate hub structure
./scripts/setup.sh

# Validate built-in agents
./scripts/validate-agent.sh agents/

# Validate marketplace agents
./scripts/validate-agent.sh marketplace/agent-store/agents/

# Validate a company's agents
./scripts/validate-agent.sh companies/<name>/agents/

# Check memory usage
./scripts/memory-manager.sh report <company-name>

# Compact memory
./scripts/memory-manager.sh compact <company-name>
```
