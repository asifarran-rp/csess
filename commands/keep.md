---
description: Preserve this session and write a summary so it can be hydrated later with csess
argument-hint: "[optional label for the session]"
allowed-tools: Bash(csess save:*), Bash(mkdir:*), Write, Read
---

The user wants to "keep" the current Claude Code session so it survives a
restart and can be resumed later via `csess`.

Current session id: `$CLAUDE_CODE_SESSION_ID`
Requested label (may be empty): `$ARGUMENTS`

Do the following:

1. Decide on a **label**:
   - If `$ARGUMENTS` is non-empty, slugify it (lowercase, words joined by `-`).
   - Otherwise invent a short, specific kebab-case label that captures what this
     session is actually about (e.g. `csess-session-tooling`, not `chat-1`).

2. Write a **summary** to `/tmp/claude-keep-summary.md` covering everything a
   future reader (you or the user, with no memory of this chat) needs to pick up
   where things left off. Use this structure:

   ```markdown
   # <label>

   **Goal:** one or two sentences on what this session set out to do.

   **Status:** where things currently stand.

   ## Key decisions
   - ...

   ## Current state / what exists now
   - files created or changed, important paths, commands, URLs

   ## Open threads / next steps
   - the very next things to do on resume

   ## Useful context
   - anything non-obvious worth not re-deriving
   ```

   Keep it tight and concrete — paths, command names, decisions — not fluff.

3. Run (substitute the real label and the working directory):

   ```
   csess save --id "$CLAUDE_CODE_SESSION_ID" --cwd "<the cwd>" --label "<label>" --summary-file /tmp/claude-keep-summary.md
   ```

4. Confirm to the user with the label and remind them: run `csess` in a terminal
   to browse and hydrate kept sessions, `csess prune` to clean up.
