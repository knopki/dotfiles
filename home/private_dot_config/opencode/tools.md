Available builtin tools:

- `bash`- Executes a given bash command in a persistent shell session with optional timeout, ensuring proper handling and security measures.
- `edit` - Performs exact string replacements in files.
- `write` - Writes a file to the local filesystem
- `read` - Reads a file from the local filesystem
- `grep` - Fast content search tool that works with any codebase size
- `glob` - Fast file pattern matching tool that works with any codebase size
- `list` - List files and directories
- `lsp` - Experimental LSP tool
- `patch` - Apply patches to files
- `skill` - Access to skills
- `todowrite` - Use this tool to create and manage a structured task list for your current coding session
- `todoread` - Use this tool to read the current to-do list for the session
- `webfetch` - Fetches content from a specified URL
- `websearch` - Search the web using Exa AI
- `question` - Ask questions

Available builtin hidden tools:

- `batch` - Executes multiple independent tool calls concurrently to reduce latency.
- `codesearch` - Search and get relevant context for any programming task using Exa Code API
- `multiedit` - This is a tool for making multiple edits to a single file in one operation
- `task` - Launch a new agent to handle complex, multi-step tasks autonomously.

Also:

- Avery MCP's tools are prefixed via MCP name and can be enabled/disabled by wildcard like "my_mcp\*"
