# SiliconAgent Hub — Virtual Company Marketplace

A Claude Code plugin that acts as a **marketplace platform** for creating, managing, and operating isolated virtual companies. Browse pre-built industry packs, install agents from the store, use curated workflows — or let the AI generate everything dynamically for any company type.

## Quick Start

```bash
# Initialize the hub
./scripts/setup.sh

# Browse the marketplace
/silicon-agent browse packs           # See all industry packs
/silicon-agent browse agents          # See all available agents
/silicon-agent browse workflows       # See all available workflows

# Create from a marketplace pack (curated, tested)
/silicon-agent install pack school company lincoln-high
/silicon-agent install pack semiconductor company chipworks
/silicon-agent install pack construction company buildright

# Or create the classic way (known types)
/silicon-agent create SaaS company acme

# Or create ANY type (AI infers structure)
/silicon-agent create hospital company city-med
/silicon-agent create restaurant company taste-of-italy

# ★ Execute any task — system figures out the rest ★
/silicon-agent lincoln-high conduct maths exam slip test for grade 10 on Saturday
/silicon-agent chipworks double production from unit 3, prepare budget and plan
/silicon-agent buildright prepare safety audit report for site B
```

## Marketplace — Browse, Install, Create

### Company Packs (10 Industries)

| Pack | Industry | Agents | Use Case |
|------|----------|--------|----------|
| **saas** | Technology | 8 | Software-as-a-Service startup |
| **consulting** | Professional Services | 6 | Consulting firm |
| **agency** | Creative Services | 5 | Digital/creative agency |
| **e-commerce** | Retail | 8 | Online store/marketplace |
| **research** | R&D | 5 | Research organization |
| **school** | Education | 7 | K-12 school or university |
| **construction** | Construction | 6 | Construction company |
| **hospital** | Healthcare | 6 | Hospital or healthcare facility |
| **semiconductor** | Manufacturing | 6 | Semiconductor fab |
| **restaurant** | Food Service | 6 | Restaurant or food service |

```bash
/silicon-agent browse packs                              # List all packs
/silicon-agent info packs school                         # See school pack details
/silicon-agent install pack school company lincoln-high  # Create from pack
```

### Agent Store (17 Agents)

| Category | Built-in (11) | Marketplace (6) |
|----------|--------------|-----------------|
| Executive | master, ceo-advisor, coo, research-agent | — |
| Engineering | product-manager, engineer, qa-engineer | — |
| Education | — | principal, teacher |
| Operations | support-agent | production-planner, safety-inspector, site-manager |
| Healthcare | — | nurse |
| Finance | finance-agent | — |
| Sales & Marketing | marketing-manager, sales-agent | — |

```bash
/silicon-agent browse agents                          # List all agents
/silicon-agent lincoln-high hire safety-inspector     # Install from store
```

### Workflow Store (10 Workflows)

| Category | Built-in (7) | Marketplace (3) |
|----------|-------------|-----------------|
| Product | product-development | — |
| Quality | bugfix | — |
| Marketing | marketing-campaign | — |
| Research | research | — |
| Operations | hotfix, recovery, pivot | — |
| Education | — | curriculum-design |
| Industrial | — | safety-audit, production-planning |

```bash
/silicon-agent browse workflows                                # List all workflows
/silicon-agent lincoln-high install workflow curriculum-design  # Install to company
```

## How It Works

### 3 Creation Paths (Priority Order)

1. **Pack** → `install pack school company X` → uses curated blueprint from marketplace
2. **Known Type** → `create SaaS company X` → uses built-in defaults (backward compatible)
3. **AI Inferred** → `create hospital company X` → AI generates blueprint, user confirms

### 4-Tier Agent Resolution

When hiring or referencing an agent:
1. **Built-in** → `agents/<role>.md` in plugin
2. **Marketplace** → `marketplace/agent-store/agents/<role>.md`
3. **Blueprint** → company blueprint in manifest
4. **Custom** → AI generates from template on-the-fly

### Dynamic Task Execution

Throw any task at a company in natural language:
```
/silicon-agent lincoln-high conduct maths exam for grade 10 on Saturday
→ Analyzes task → generates exam-coordinator agent → creates workflow → executes → delivers
```

## Commands

### Marketplace Commands
| Command | Description |
|---------|-------------|
| `/silicon-agent browse packs` | List all company packs |
| `/silicon-agent browse agents` | List agent store |
| `/silicon-agent browse workflows` | List workflow store |
| `/silicon-agent install pack <name> company <co>` | Create from pack |
| `/silicon-agent search <query>` | Search marketplace |
| `/silicon-agent info <type> <name>` | Show item details |

### Global Commands
| Command | Description |
|---------|-------------|
| `/silicon-agent create <type> company <name>` | Create company (any type) |
| `/silicon-agent list` | Show all companies |
| `/silicon-agent delete company <name>` | Archive and remove |

### Company Commands
| Command | Description |
|---------|-------------|
| `/<company> status` | Company dashboard |
| `/<company> hire <role>` | Hire agent (from store or custom) |
| `/<company> fire <role>` | Remove agent |
| `/<company> task add <desc>` | Add task |
| `/<company> run <workflow>` | Run pre-built workflow |
| `/<company> <anything>` | ★ Dynamic task execution |
| `/<company> report` | Full report |
| `/<company> budget` | Budget status |
| `/<company> agents` | List agents |

## Architecture

```
silicon-agent-hub/
├── .claude-plugin/plugin.json      ← Hub manifest
├── SKILL.md                        ← Command router (5-tier parsing)
├── agents/                         ← 11 built-in agent templates
│   ├── master.md                   ← Hub orchestrator (renamed from silicon-agent)
│   └── ... (10 other built-in)
├── skills/                         ← 5 sub-skills
│   ├── marketplace/SKILL.md        ← Browse/install marketplace
│   ├── company-generator/SKILL.md  ← 3-path creation (pack/known/AI)
│   ├── agent-spawner/SKILL.md      ← 4-tier agent resolution
│   ├── company-manager/SKILL.md    ← Status, reports, budget
│   └── task-executor/SKILL.md      ← Dynamic free-form tasks
├── marketplace/                    ← THE MARKETPLACE
│   ├── company-packs/              ← 10 industry packs with blueprints
│   ├── agent-store/                ← 17 agents (11 built-in + 6 industry)
│   └── workflow-store/             ← 10 workflows (7 built-in + 3 industry)
├── workflows/                      ← 7 built-in workflows (backward compat)
├── templates/                      ← Agent & workflow generation templates
├── hooks/                          ← Session lifecycle hooks
├── scripts/                        ← Validation & management scripts
├── companies/                      ← DATA ROOT (generated, mutable)
└── tests/                          ← Smoke tests + marketplace tests
```

## Validation

```bash
./scripts/setup.sh                                    # Validate hub structure
./scripts/validate-agent.sh agents/                   # Validate built-in agents
./scripts/validate-agent.sh marketplace/agent-store/agents/  # Validate store agents
./scripts/validate-agent.sh companies/<name>/agents/   # Validate company agents
```

## Key Principles

1. **Marketplace first** — curated packs, agents, and workflows for common industries
2. **AI fallback** — anything not in the store gets AI-inferred dynamically
3. **Backward compatible** — all pre-marketplace commands still work
4. **Read-only plugin** — only `companies/` is mutable
5. **Any company type** — from SaaS to schools, fabs to restaurants
6. **Any task** — natural language execution with auto-provisioning
