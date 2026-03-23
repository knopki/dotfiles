---
name: continuity-ledger
description: MANDATORY. Maintain context and project state across context window compactions. ALWAYS activate this skill when starting any task, managing project progress, or coordinating between multiple agents. Essential for long-running workflows.
license: MIT
compatibility: opencode 1.0.193
---

<system_instruction>
<description>
Continuity management system maintaining persistent project state across context windows and agent handoffs through a structured ledger file at `.opencode/CONTINUITY.md`.
</description>

<core_principle>
The ledger is the canonical session briefing designed to survive context compaction. Do not rely on earlier chat text unless it is reflected in the ledger.
</core_principle>

  <instructions>
    <initialization>
      When starting a new session or task:
      - Check for the existence of `.opencode/CONTINUITY.md` in the project root
      - If the ledger is missing, create it based LEDGER_FORMAT
    </initialization>

    <format_adherence>
      When updating or creating the ledger:
      - Strictly follow the schema defined in LEDGER_FORMAT
      - Refer to the Continuity Ledger Format for the exact Markdown structure and required sections
      - Do not add top-level headers that are not defined in the specification unless absolutely necessary for the task
    </format_adherence>

    <read_act_update_cycle>
      For every significant turn or sub-task completion:
      - **Read**: Load the current state from the ledger
      - **Act**: Perform the required task (planning, coding, or delegating)
      - **Update**: Update the ledger with any new decisions, progress changes (Done/Now/Next), or discovered constraints
    </read_act_update_cycle>

    <compaction_awareness>
      When you detect that the conversation history is long or has been summarized:
      - Rely on the `.opencode/CONTINUITY.md` file as the definitive state
      - Do not trust summarized history for critical technical decisions or project constraints if they conflict with the ledger
      - If you notice missing recall or a compaction/summary event: refresh/rebuild the ledger from visible context, mark gaps in AGENTS.md, ask up to 1–3 targeted questions, then continue
    </compaction_awareness>

    <multi_agent_coordination>
      - **Orchestrator**: Maintains the master ledger for high-level goals
      - **Sub-agents**: Update specific sections or maintain task-specific sub-ledgers
      - Always include a "Ledger Snapshot" (Goal + Now/Next) when handing off tasks between agents
    </multi_agent_coordination>

    <todowrite_vs_ledger>
      - `todowrite` is for short-term execution scaffolding while you work (a small 3–7 step plan with pending/in_progress/completed)
      - `.opencode/CONTINUITY.md` is for long-running continuity across compaction (the "what/why/current state"), not a step-by-step task list
      - Keep them consistent: when the plan or state changes, update the ledger at the intent/progress level (not every micro-step)
    </todowrite_vs_ledger>

    <reply_format>
      - Begin with a brief "Ledger Snapshot" (Goal + Now/Next + Open Questions)
      - Print the full ledger only when it materially changes or when the user asks
    </reply_format>

  </instructions>

  <constraints>
    - Must strictly follow schema defined in reference guide
    - Do not add top-level headers not defined in specification
    - Do not trust summarized history if it conflicts with the ledger
    - Never guess - mark uncertainty as UNCONFIRMED
    - Keep `todowrite` and `.opencode/CONTINUITY.md` consistent
    - Update ledger at intent/progress level, not every micro-step
    - Keep ledger short and stable: facts only, no transcripts
    - Prefer bullets for all content
  </constraints>

<output_format>
<LEDGER_FORMAT>

# Contunuity Ledger

## Project Goal

- **Objective**: [Clear statement of the end goal]
- **Success Criteria**: [List of measurable outcomes]

## Context & Constraints

- **Tech Stack**: [e.g., Python, FastAPI, etc.]
- **Constraints**: [Security requirements, hardware tokens, etc.]

## Key Decisions

- [YYYY-MM-DD]: [Decision] - [Reasoning]

## Execution State

- **Done**:
  - [x] Task 1
- **Now**:
  - [ ] Task 2 (Current focus)
- **Next**:
  - [ ] Task 3

## Open Questions (UNCONFIRMED)

- [ ] Question regarding X...

## Working Set

- **Files**: [List of relevant paths]
- **Commands**: [Last used/useful CLI commands]
  </LEDGER_FORMAT>
  <ledger_snapshot_format>
  <description>Brief format for replies and agent handoffs:</description>
  <template>

- Goal: [Current objective]
- Now: [Current focus tasks]
- Next: [Upcoming tasks]
- Open Questions: [Any unresolved items]
  </template>
  </ledger_snapshot_format>
  </output_format>

<examples>
    <example>
      <description>Updating Following the Format</description>
      <content>
        Based on LEDGER_FORMAT, I am updating the 'Execution State' section to mark 'Task A' as Done.
      </content>
    </example>
</examples>
</system_instruction>
