# OpenCode Agents

This configuration defines a set of primary agents and subagents for OpenCode. A primary agent receives the user request, chooses the workflow, and delegates specialized work to subagents when useful.

## Agent Map

| Agent | Mode | Role |
| --- | --- | --- |
| `smart` | primary | Main orchestrator: classifies the task, decides when to ask, plan, execute directly, or delegate. |
| `orchestrator` | primary | Pure orchestrator: classifies the task, asks/plans when needed, and delegates all task work to subagents. |
| `grace-controller` | primary | GRACE controller: owns GRACE workflows, execution packets, shared artifacts, scoped review gates, and GRACE commits. |
| `enhance-prompt` | primary | Narrow primary agent for rewriting user prompts into clearer, more executable prompts. |
| `codebase-explorer` | subagent | Read-only local codebase search and structural discovery. |
| `librarian` | subagent | Read-only external research for libraries, documentation, GitHub, and real usage examples. |
| `architect` | subagent | Architecture advisor and technical decision reviewer. Does not edit files. |
| `implementer` | subagent | Focused single-file changes, especially for parallel repetitive edits. |
| `grace-module-implementer` | subagent | Implements one GRACE module or bounded slice from a controller execution packet. |
| `tester` | subagent | Test authoring in TDD or verification mode. |
| `debugger` | subagent | Complex error diagnosis and root cause analysis. May make temporary diagnostic edits only. |
| `reviewer` | subagent | Code review for correctness, security, integration risk, and missing tests. |
| `grace-contract-reviewer` | subagent | Read-only GRACE contract, semantic markup, import, scope, and graph-delta reviewer. |
| `grace-verification-reviewer` | subagent | Read-only GRACE verification-plan, evidence, trace, log, and test-strength reviewer. |
| `grace-fixer` | subagent | Repairs one GRACE failure packet inside an assigned write scope. Does not commit. |
| `document-writer` | subagent | Documentation: README files, API docs, architecture docs, and user guides. |
| `ux` | subagent | UI/UX design and visual implementation. |
| `multimodal-looker` | subagent | Analysis of PDFs, images, diagrams, and other visual content. |

## Routing

The main routing rules live in `agents/smart.md`. A stricter delegation-only variant lives in `agents/orchestrator.md`.

1. If the user explicitly requests a subagent, use that subagent when available.
2. If key requirements are missing, the primary agent should ask concise clarifying questions.
3. Explicit GRACE work goes to `grace-controller`. This includes `$grace-*`, `GRACE`, `grace lint/status/module/file`, `MODULE_CONTRACT`, `MODULE_MAP`, `CHANGE_SUMMARY`, semantic blocks, execution packets, `GraphDelta`, `VerificationDelta`, and GRACE docs under `docs/`.
4. External docs, GitHub URLs, libraries, and best-practice research go to `librarian`.
5. Local search, "where is X", and "how does X work" questions go to `codebase-explorer`.
6. Architecture, API design, and technical strategy go to `architect`.
7. README, CHANGELOG, API docs, and ADR work: `codebase-explorer` first, then `document-writer`.
8. UI/UX work: `codebase-explorer` first, then `ux`.
9. Code review, security review, and quality review go to `reviewer`.
10. Implementation, bug fixes, and refactors: `codebase-explorer` first, then `implementer`; `smart` may skip delegation only for simple direct work.
11. Clear but abstract or complex tasks may go to `architect`.

For simple tasks, `smart` can work directly; `orchestrator` always delegates. For 3+ independent files with the same isolated edit pattern, parallel `implementer` agents are allowed, but multiple agents must never write to the same file.

## Permission Model

The system mostly follows least privilege:

- Research agents (`codebase-explorer`, `architect`, `multimodal-looker`) are mostly read-only.
- Writing agents (`implementer`, `tester`, `document-writer`, `ux`) have `edit: allow`, but each prompt narrows the role-specific write scope.
- GRACE writing agents (`grace-controller`, `grace-module-implementer`, `grace-fixer`) have `edit: allow`, but their prompts enforce GRACE ownership boundaries.
- `debugger` has `edit: allow` only for diagnostic instrumentation, not bug fixes or refactors.
- `librarian` has external tools (`webfetch`, `websearch`, limited `bash`) for documentation, GitHub, and open-source research.
- `reviewer` is file read-only (`edit: deny`) and has a limited `bash` allowlist for read-only diff/status/show workflows plus common shell read patterns.
- GRACE reviewers (`grace-contract-reviewer`, `grace-verification-reviewer`) are read-only.
- `smart` has broad permissions because it is the primary orchestrator.
- `orchestrator` is read-only and delegates all task work to subagents.
- `grace-controller` is the only primary agent allowed to commit during GRACE workflows without extra approval.
- `grace-module-implementer` may commit only when its execution packet sets `commit_authorized: true`.
- `enhance-prompt` is intentionally isolated from task/skill/bash/lsp/web access, but can edit so it may save a rewritten prompt to a file when asked.

Frontmatter matrix:

| Agent | Model | Write | Network | Bash | Task | GitNexus |
| --- | --- | --- | --- | --- | --- | --- |
| `smart` | `openai/gpt-5.5` | yes | no | unspecified | selected subagents | yes |
| `orchestrator` | `openai/gpt-5.5` | no | no | unspecified | selected subagents + `smart` fallback | no |
| `grace-controller` | `openai/gpt-5.5` | yes | no | inherited | GRACE subagents + research/media agents | yes |
| `enhance-prompt` | `openai/gpt-5.5` | yes | no | no | no | no |
| `codebase-explorer` | `openai/gpt-5.4-mini` | no | no | no | no | yes |
| `librarian` | `openai/gpt-5.4-mini` | no | yes | allowlist | no | no |
| `architect` | `openrouter/google-3.1-pro-preview` | no | no | unspecified | `codebase-explorer`, `librarian` | yes |
| `implementer` | `openai/gpt-5.5` | yes | no | unspecified | `codebase-explorer`, `librarian` | yes |
| `grace-module-implementer` | `openai/gpt-5.5` | yes | no | inherited | `codebase-explorer`, `librarian` | yes |
| `tester` | `openai/gpt-5.4-mini` | yes | no | unspecified | no | yes |
| `debugger` | `openai/gpt-5.5` | diagnostic only | no | unspecified | `codebase-explorer`, `librarian` | yes |
| `reviewer` | `zai/glm-5.1` | no | no | allowlist | `codebase-explorer`, `librarian` | yes |
| `grace-contract-reviewer` | `zai/glm-5.1` | no | no | inherited | `codebase-explorer` | yes |
| `grace-verification-reviewer` | `openai/gpt-5.4-mini` | no | no | inherited | `codebase-explorer`, `librarian` | yes |
| `grace-fixer` | `openai/gpt-5.5` | yes | no | inherited | `codebase-explorer`, `librarian` | yes |
| `document-writer` | `openrouter/google/gemini-3-flash-preview` | yes | no | unspecified | `codebase-explorer`, `librarian` | yes |
| `ux` | `openrouter/google-3.1-pro-preview` | yes | no | unspecified | `codebase-explorer`, `librarian` | yes |
| `multimodal-looker` | `google/gemini-3-flash-preview` | no | no | no | no | no |

`unspecified` means the frontmatter has no explicit `bash: deny` or allowlist. Keep this only where OpenCode's default policy is expected and safe.
`inherited` means the agent intentionally inherits the global `permission.bash` from `opencode.jsonc`; prompt rules narrow how GRACE agents may use git and verification commands.

## GRACE Layer

GRACE is implemented as an isolated vertical workflow layer rather than mixed into the general agents.

- `smart` and `orchestrator` only route explicit GRACE work to `grace-controller`.
- `grace-controller` owns the GRACE lifecycle: init, plan, verification, execution packets, wave scheduling, scoped reviews, shared-artifact sync, and GRACE commits.
- `grace-module-implementer` receives compact execution packets and owns one module or bounded slice.
- `grace-contract-reviewer` and `grace-verification-reviewer` provide scoped gates before controller integration.
- `grace-fixer` handles one failure packet and reports deltas, but never commits.
- Upstream GRACE skills are not modified; OpenCode-specific behavior is expressed in agent prompts and global config only.

GRACE commit policy:

- General agents still do not perform git writes without explicit user instruction.
- `grace-controller` may commit during GRACE workflows without extra approval.
- `grace-module-implementer` may commit only when its packet has `commit_authorized: true`.
- `grace-fixer` and GRACE reviewers never commit.
- Sequential `grace-execute`: worker implementation commits are allowed when authorized; controller commits shared artifacts.
- Parallel `grace-multiagent-execute`: workers never commit; controller serializes module commits and shared-artifact commits.
- Staging must use exact files only. `git add .`, `git add -A`, and `git add --all` are forbidden.
- Push, pull, merge, rebase, checkout, reset, amend, force, `--no-verify`, and `--no-gpg-sign` require explicit user instruction.

## Design Review

Strengths:

- Clear split between primary orchestration and specialized subagents.
- `smart` has an explicit complexity scale and rules for asking, planning, delegating, and direct execution.
- `orchestrator` provides a stricter read-only primary mode where all task work is delegated.
- Subagents have narrow roles and usually cannot ask the user questions, which makes delegation more deterministic.
- Read-only roles are mostly enforced as read-only (`codebase-explorer`, `architect`, `multimodal-looker`, `reviewer`).
- External research is centralized in `librarian` instead of being spread across all agents.
- Parallel write conflicts are explicitly addressed: primary agents forbid multiple agents from writing to the same file.
- GRACE is isolated into a dedicated controller and GRACE-specific workers/reviewers instead of being mixed into general agents.

Permission notes:

| Agent | Note | Risk | Recommendation |
| --- | --- | --- | --- |
| `debugger` | `edit: allow` is intentional for temporary diagnostic instrumentation. | The agent could drift from diagnosis into fixing. | Keep the prompt strict: diagnostic edits only, no fixes/refactors, remove or report temporary edits. |
| `tester` | GitNexus skills and `"gitnexus_*": allow` are aligned. | Low: the agent can use graph tools when designing tests. | Keep GitNexus access enabled. |
| `reviewer` | The `bash` allowlist includes `echo *`, `grep *`, and `head *` so natural read-only shell patterns do not fail while git commands are allowed. | Slightly larger read-only surface. | Keep as-is, or strengthen the prompt to prefer specialized tools over shell for file reading. |
| `enhance-prompt` | `edit: allow` is useful when the user asks to save the rewritten prompt to a file. | Low because task/skill/bash/web are denied. | Keep as-is. |
| `document-writer` | The prompt requires studying the codebase through `codebase-explorer`, and task permissions allow that chain. | Low, mostly depends on prompt discipline. | Keep as-is. |
| `smart` | Broad permissions include editing, subagent routing, and GitNexus access. | Higher blast radius if the primary behaves incorrectly. | Acceptable for smart direct-execution mode; keep subagents narrower. |
| `orchestrator` | Read-only primary with subagent routing and no GitNexus access. | Lower direct-write risk, but depends on correct subagent prompts. | Keep `edit: deny` so it remains pure orchestration. |
| `grace-controller` | `edit: allow` and inherited bash are intentional so it can own shared artifacts and serialized GRACE commits. | Global `git add *` and `git commit -m *` are hard-permission broad; safety depends on prompt discipline. | Keep exact-file staging rules prominent and do not allow push/destructive git without explicit user instruction. |
| `grace-module-implementer` | May commit only with `commit_authorized: true`; otherwise returns commit-ready output. | Could misuse global git write allowlist if prompt discipline fails. | Keep packet authorization mandatory and use controller-serialized commits for multi-agent execution. |
| `grace-fixer` | Can edit scoped failures but never commits. | Could drift into architecture changes if the failure is actually contract drift. | Keep the prompt strict: stop and report when the fix requires replanning. |
| GRACE reviewers | Read-only GRACE-specific gates. | Low. They inherit global bash but have `edit: deny` and no commit role. | Keep review scope narrow and escalate only on evidence of broader drift. |

## Summary

The architecture is sound: primary orchestration options, narrow subagents, read-only research, separate implementation/test/review/docs/UX roles, and an isolated GRACE layer. The main remaining hard-permission trade-off is global `git add *` / `git commit -m *`; GRACE prompt rules restrict actual use to `grace-controller` and explicitly authorized `grace-module-implementer` runs.
