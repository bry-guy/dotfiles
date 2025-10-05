---
description: Runs the full, multi-step planning workflow for a given specification file.
agent: plan-orchestrator
---
# Initiate Planning Workflow

**SPECIFICATION FILE:** @$ARGUMENTS

**VALIDATION REQUIREMENTS:**
* Specification file must exist and be readable
* File must have .md extension
* File must contain more than just YAML front matter
* Specification file must be under 6000 tokens (approximately 24KB)
* If file exceeds token limit, automatically split into logical chunks
* Create multiple plans: plan-$ARGUMENTS-1.md, plan-$ARGUMENTS-2.md, etc. for chunked specifications
* Create doc/plan/ directory structure if it doesn't exist before writing output
* Validate write permissions to target directory before proceeding
* If validation fails, respond: 'Specification file @$ARGUMENTS not found, unreadable, or invalid format'
* Validation must complete before proceeding to parsing step

**Initial Task for Orchestration:**
The user has provided the specification in the file `@$ARGUMENTS`. You are the `PlanOrchestrator`.

Your workflow should be:

1.  **Parsing & To-Do:**
    * First, perform the initial `parse-specification` step: Read the file, understand the feature, and break the entire spec down into a detailed, numbered **To-Do List** of required research and implementation steps.
    * Present the **To-Do List** for user review.

2.  **Context Research (Delegation):**
    * Once the user approves the To-Do List, use the **`@plan-researcher`** subagent for *each item* on the list to gather all necessary code context.
    * Synthesize the research findings into a full **Technical Ticket** for each To-Do item, including dependencies.

3.  **Final Persistence (Delegation):**
    * Use the **`@plan-writer`** subagent to write the final, synthesized plan (all tickets in order) to the file `doc/plan/plan-$ARGUMENTS`.

Wait for the user's instructions after presenting the initial **To-Do List**.
