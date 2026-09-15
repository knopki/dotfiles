# fish completions for pi

# --- subcommands ---
complete -c pi -n 'not __fish_seen_subcommand_from install remove uninstall update list config auth' -a install -d 'Install extension source'
complete -c pi -n 'not __fish_seen_subcommand_from install remove uninstall update list config auth' -a remove -d 'Remove extension source'
complete -c pi -n 'not __fish_seen_subcommand_from install remove uninstall update list config auth' -a uninstall -d 'Alias for remove'
complete -c pi -n 'not __fish_seen_subcommand_from install remove uninstall update list config auth' -a update -d 'Update pi, extensions, or model catalogs'
complete -c pi -n 'not __fish_seen_subcommand_from install remove uninstall update list config auth' -a list -d 'List installed extensions'
complete -c pi -n 'not __fish_seen_subcommand_from install remove uninstall update list config auth' -a config -d 'Open TUI to enable/disable package resources'
complete -c pi -n 'not __fish_seen_subcommand_from install remove uninstall update list config auth' -a auth -d 'Print credentials for external clients'

# --- session ids (default dir; honors $PI_CODING_AGENT_SESSION_DIR) ---
function __fish_pi_sessions
    set -l dir $PI_CODING_AGENT_SESSION_DIR
    [ -z "$dir" ] && set dir ~/.pi/agent/sessions
    for f in $dir/*/*.jsonl
        basename $f .jsonl | string split -m1 _ | tail -n1
    end
end

# --- enumerable option values ---
complete -c pi -l mode -xa 'text json rpc' -d 'Output mode'
complete -c pi -l thinking -xa 'off minimal low medium high xhigh max' -d 'Thinking level'
complete -c pi -l provider -xa 'google anthropic openai openrouter bedrock ollama groq mistral xai deepseek qwen moonshot local' -d Provider
complete -c pi -l tools -xa 'read bash edit write grep find ls' -d 'Tool allowlist (comma-separated)'
complete -c pi -l exclude-tools -xa 'read bash edit write grep find ls' -d 'Tool denylist (comma-separated)'

# --- flags ---
complete -c pi -l help -s h -d 'Show help'
complete -c pi -l version -d 'Show version'
complete -c pi -l print -s p -d 'Non-interactive mode'
complete -c pi -l continue -s c -d 'Continue previous session'
complete -c pi -l approve -s a -d 'Trust project-local files for this run'
complete -c pi -l no-approve -s na -d 'Ignore project-local files for this run'
complete -c pi -l offline -d 'Disable startup network operations'
complete -c pi -l verbose -d 'Force verbose startup'
complete -c pi -l list-models -d 'List available models (optional fuzzy search)'
complete -c pi -l no-session -d "Don't save session (ephemeral)"
complete -c pi -l no-tools -s nt -d 'Disable all tools by default'
complete -c pi -l no-builtin-tools -s nbt -d 'Disable built-in tools, keep extension tools'
complete -c pi -l no-extensions -s ne -d 'Disable extension discovery'
complete -c pi -l no-skills -s ns -d 'Disable skills discovery and loading'
complete -c pi -l no-prompt-templates -s np -d 'Disable prompt template discovery'
complete -c pi -l no-themes -d 'Disable theme discovery'
complete -c pi -l no-context-files -s nc -d 'Disable AGENTS.md/CLAUDE.md discovery'

# --- options taking arguments ---
complete -c pi -l resume -s r -r -a '(__fish_pi_sessions)' -d 'Resume session'
complete -c pi -l session -r -a '(__fish_pi_sessions)' -d 'Session file or partial UUID'
complete -c pi -l session-id -r -a '(__fish_pi_sessions)' -d 'Exact project session ID'
complete -c pi -l fork -r -a '(__fish_pi_sessions)' -d 'Fork a session into a new one'
complete -c pi -l session-dir -r -F -d 'Session storage directory'
complete -c pi -l name -s n -r -d 'Session display name'
complete -c pi -l model -r -d 'Model pattern or ID'
complete -c pi -l models -r -d 'Model patterns for Ctrl+P cycling'
complete -c pi -l api-key -r -d 'API key'
complete -c pi -l primary -r -d 'Default primary agent at startup'
complete -c pi -l system-prompt -r -d 'System prompt'
complete -c pi -l append-system-prompt -r -d 'Append text/file to system prompt'
complete -c pi -l extension -s e -r -F -d 'Load extension file'
complete -c pi -l skill -r -F -d 'Load skill file or directory'
complete -c pi -l prompt-template -r -F -d 'Load prompt template file or directory'
complete -c pi -l theme -r -F -d 'Load theme file or directory'
complete -c pi -l mcp-config -r -F -d 'Path to MCP config file'
complete -c pi -l export -r -F -d 'Export session file to HTML'

# --- subcommand-local flags ---
complete -c pi -n '__fish_seen_subcommand_from install remove uninstall config auth' -l local -s l -d 'Project-local scope (.pi/settings.json)'
