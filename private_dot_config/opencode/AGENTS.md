# OpenCode Autonomous Workflow Conventions

This document defines the conventions, architecture, and constraints for all autonomous agents operating within this repository. It enforces cost efficiency, quality gates, and predictable behavior across all workflows.

## 1. Core Agentic Philosophy

The primary workflow is based on the **Orchestrator-Stateless Subagent** pattern.

* **Primary Agents (Orchestrators):** Responsible for task decomposition, coordination, communication with the user, and quality gate enforcement. They are the only agents that maintain a view of the global task state.
* **Subagents (Stateless):** Highly specialized, focused only on their immediate, single-step task (execution, review, finalization). They report results back to the Orchestrator and do not initiate new workflows.

## 2. Naming and File Conventions

All agents and commands must follow a standardized structure to ensure discoverability and predictable routing.

### 2.1. Agent Naming Convention

Agents are named using the pattern: `[WORKFLOW_NAME]-[ROLE_NAME]`.

| Category | Role Name | Naming Example | Agent Mode |
| :--- | :--- | :--- | :--- |
| **Primary** | `orchestrator` | `build-orchestrator` | `primary` |
| **Subagents** | `worker`, `reviewer`, `committer` | `plan-worker`, `code-reviewer`, `doc-committer` | `subagent` |

### 2.2. Command Naming Convention

User-facing commands initiating a workflow must reside in the `.opencode/commands` directory and use the `[WORKFLOW_NAME].md` pattern (e.g., `/full-build` is defined by `full-build.md`).

## 3. Model & Cost Tiers

The selection of the LLM model for a given task is strictly based on the required **Reasoning Effort** and the associated cost/speed trade-off.

| Reasoning Effort | Model Tier | Model Convention | Task Type | Temperature Constraint |
| :--- | :--- | :--- | :--- | :--- |
| **High** | Tier 1 (High Reliability/Cost) | `github-copilot/claude-sonnet-4` | Planning, Orchestration, Critical Analysis, Code Review | `0.1` (Strict, Analytical) |
| **Medium** | Tier 2 (Balanced Speed/Cost) | `github-copilot/gpt-5-mini` | Code Execution, Error Correction, Creative Generation | `0.3` (Flexible, Experimental) |
| **Low** | Tier 3 (Fastest/Cheapest) | `github-copilot/gpt-5-mini` | Mechanical tasks, Fixed formatting, Log summarization | `0.0` (Deterministic, Factual) |

## 4. Standard Conceptual Agent Roles

All workflows must be composed of these standardized conceptual roles.

| Conceptual Role | Model Tiering | Primary Responsibility | Key Constraint |
| :--- | :--- | :--- | :--- |
| **`[Task]-Orchestrator`** | **Tier 1 (High)** | Decompose the initial task into a sequence of Micro-Tasks; manage flow control; enforce all quality gates; interact with the human user. | Must delegate all execution and critique; only manages state and flow. |
| **`[Task]-Worker`** | **Tier 2 (Medium)** | Execute a single, defined Micro-Task (e.g., file modification, research, drafting). Must include a `bash` step for validation (e.g., tests, lints). | Task is complete only upon successful validation/test run. |
| **`[Task]-Reviewer`** | **Tier 1 (High)** | Perform critical quality assurance on the latest changes (`git diff` or output) against a strict, objective checklist (security, style, performance). | Must be impartial and forbidden from making changes (`edit`/`write` tools are disallowed). |
| **`[Task]-Finalizer`** | **Tier 3 (Low)** | Execute the final, mechanical completion steps. This often includes staging changes, generating a conventional summary, and committing. | Must use the lowest temperature (`0.0`) for maximum determinism and compliance with formatting rules. |

## 5. Operational Conventions

### 5.1. Temperature Settings & Rationale

Agents must set the `temperature` parameter based on the role's required cognitive complexity:

* **0.0 (Zero):** Reserved for tasks requiring absolute obedience and zero creativity (e.g., `[Task]-Finalizer`).
* **0.1 (Low):** Reserved for analytical, planning, or judgmental tasks (e.g., `[Task]-Orchestrator`, `[Task]-Reviewer`).
* **0.3 (Medium):** Reserved for tasks involving code synthesis, debugging, or minor rephrasing (e.g., `[Task]-Worker`).

### 5.2. Gated Workflow

1.  **Micro-Task Definition:** The Orchestrator must break the request into small, sequential Micro-Tasks.
2.  **Mandatory Review:** The Orchestrator must call the `[Task]-Reviewer` after *every* completed Micro-Task before proceeding. Work is only accepted if the reviewer explicitly returns **`Review Status: Approved`**.
3.  **Stateless Execution:** All subagents must be stateless, receiving full context for their immediate Micro-Task from the Orchestrator and focusing solely on that step. They should not attempt to manage the overall task list or look ahead.

# CLI Commands

- `mise` is responsible for installing and managing cli commands invocable by the 'bash' tool, both global and per-project (per git-repo).
    - `mise` is a cli command
    - `mise ls --local` lists the currently specified tools in your context
    - If you want to install a tool via `mise`, you must ask for permission, regardless of mode.

