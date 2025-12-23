---
description: Review staged changes, create commit message, ask for confirmation before committing
agent: build
---

Review the staged changes and create a suitable commit message. Follow these steps:

1. First, examine the git status to see what's staged:
   `git status`

2. Review the staged changes in detail:
   `git diff --staged`

3. If necessary, examine specific changed files to understand the changes better. Use read tools for key files.

4. Look at recent commit history for context:
   `git log --oneline -5`

5. Analyze the changes and create a concise, descriptive commit message that follows conventional commit format if appropriate. Focus on the 'why' rather than just the 'what'.

6. Present the proposed commit message to the user and ask for confirmation before committing.

7. If user confirms, execute the commit with the proposed message. If not, ask for adjustments.

IMPORTANT: Always ask for user confirmation before actually running 'git commit'. Provide reasoning for your proposed commit message based on the changes observed.
