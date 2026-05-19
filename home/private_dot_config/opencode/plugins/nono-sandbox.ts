// nono-sandbox.ts — opencode plugin for nono sandbox denial detection
//
// TODO(api-shape): the tool.execute.after hook signature below is inferred
// from https://opencode.ai/docs/plugins/ and the @opencode-ai/plugin type
// stubs. Validate the exact (input, result) shape against a live opencode
// session before tagging 0.1.0. The denial-detection and message-mutation
// logic is correct; only the hook key and argument names may need updating.

import * as fs from "fs"

const DENIAL_PATTERN =
  /operation not permitted|permission denied|eperm|eacces|sandbox.*denied|landlock/i

type Caps = {
  fs?: Array<{ path: string; resolved?: string; access: string }>
  net_blocked?: boolean
}

function buildGuidance(caps: Caps): string {
  const pathLines =
    (caps.fs ?? [])
      .map(e => "  " + (e.resolved ?? e.path) + " (" + e.access + ")")
      .join("\n") || "  (none)"
  const net = caps.net_blocked ? "blocked" : "allowed"

  return [
    "",
    "---",
    "**[nono sandbox]** This is a sandbox permission denial — not a Unix or macOS permissions issue.",
    "Do NOT suggest sudo, chmod, or system permission changes.",
    "",
    "Allowed paths in this session:",
    pathLines,
    "Network: " + net,
    "",
    "Next steps (in order):",
    "1. Run `nono why --path <blocked-path> --op read` immediately.",
    "   Include its output verbatim in your reply.",
    "2. Present the user with exactly these two options:",
    "   Option A (quick fix):  nono run --allow /path/to/needed -- opencode",
    "   Option B (persistent): draft a profile to ~/.config/nono/profile-drafts/<name>.json",
    "                          extending `opencode`, add the path under `\"allow\"` or `\"read\"`,",
    "                          then tell the user: run `nono profile promote <name>`",
    "                          to review and apply, then start with",
    "                          `nono run --profile <name> -- opencode`",
  ].join("\n")
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function appendGuidance(result: any, guidance: string): unknown {
  if (!result || typeof result !== "object") return result
  const r = result as Record<string, unknown>
  if (typeof r.content === "string") {
    return { ...r, content: r.content + guidance }
  }
  if (Array.isArray(r.content)) {
    const parts = [...r.content]
    const lastText = parts
      .map(p => typeof (p as { text?: unknown }).text === "string")
      .lastIndexOf(true)
    if (lastText >= 0) {
      parts[lastText] = {
        ...(parts[lastText] as object),
        text: (parts[lastText] as { text: string }).text + guidance,
      }
    } else {
      parts.push({ type: "text", text: guidance })
    }
    return { ...r, content: parts }
  }
  return result
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const NonoSandboxPlugin = async (_ctx: any) => {
  const capFile = process.env.NONO_CAP_FILE
  if (!capFile) return {}

  return {
    tool: {
      execute: {
        // Fires after every tool call. When the result contains a
        // sandbox-denial signature we append capability context and the
        // standard Option A / Option B remediation so the model receives
        // the correct guidance without needing to call nono why itself.
        after: async (_input: unknown, result: unknown) => {
          if (!DENIAL_PATTERN.test(JSON.stringify(result))) return result

          let caps: Caps = {}
          try {
            caps = JSON.parse(fs.readFileSync(capFile, "utf8")) as Caps
          } catch {
            return result
          }

          return appendGuidance(result, buildGuidance(caps))
        },
      },
    },
  }
}
