# csess — keep & hydrate long-lived Claude Code sessions

A zero-dependency tool (Python stdlib only) for preserving the Claude Code
sessions you don't want to lose across machine restarts, browsing them with an
arrow-key picker, and pruning the ones you no longer need.

## Why

Claude Code already lets you resume any session with `claude -r <id>`, but:

- you have to know/track the id,
- there's no curated "these are the ones I care about" list, and
- **Claude Code auto-prunes old transcripts** (~30 days), so a session you leave
  alone for too long can silently disappear.

`csess` adds a small registry of *kept* sessions, **preserves a copy of each
transcript** so cleanup can't delete it, stores a human-readable summary
alongside it, and gives you a picker to hydrate one.

## Install

```sh
git clone <this-repo> ~/projects/csess
~/projects/csess/install.sh
```

`install.sh` symlinks:

- `bin/csess` → `~/.local/bin/csess` (must be on your `PATH`)
- `commands/keep.md` → `~/.claude/commands/keep.md` (the `/keep` slash command)

Because they're symlinks, `git pull` updates the installed tool instantly.

Requirements: `python3` (stdlib `curses`). No pip installs, no `node_modules`.

## Use

### Save a session — from inside Claude Code

```
/keep                       # agent picks a label + writes a summary
/keep db migration spike    # your label
```

This writes a summary, preserves the transcript, and registers the session.

### Browse & hydrate — from a terminal

```sh
csess                # arrow-key picker, newest activity first → resumes on Enter
csess ls             # plain text list (works without a TTY)
csess show <id|label>     # print the summary /keep wrote for a session
csess resume <id|label>   # resume directly, no picker
```

Resuming restores the transcript (and its `<id>/` sidecar dir of subagent
transcripts and tool results) into Claude Code's project dir if auto-cleanup
removed it, `cd`s to the original working directory, and execs `claude -r <id>`.

> Run the picker in a real terminal — it needs a TTY, so it won't render piped
> or from inside the agent. `csess ls` / `csess resume` work anywhere.

### Prune

```sh
csess prune          # multi-select picker (space=toggle, a=all), confirms, deletes
csess rm <id|label>  # delete specific ones, no picker
```

Removing a session deletes its registry entry, preserved transcript, sidecar
dir, and summary (it does **not** touch Claude Code's own live transcript).

## Layout

Everything lives under `~/.claude/csess/`:

```
index.json            registry of kept sessions
transcripts/<id>.jsonl  preserved transcript copies (survive auto-cleanup)
transcripts/<id>/       preserved sidecar dirs (subagents/, tool-results/)
summaries/<id>.md       per-session summary written by /keep
```

## How it works

- `CLAUDE_CODE_SESSION_ID` (exported into every session) tells `/keep` which
  session it's in — no guessing.
- Transcripts are discovered by globbing `~/.claude/projects/*/<id>.jsonl`;
  the sidecar dir `~/.claude/projects/*/<id>/` is preserved alongside.
- `/keep` writes its summary to a private `mktemp` file, so several sessions
  can `/keep` at the same time without clobbering each other.
- When the recorded project dir is gone, the fallback slug maps `/`, `.` and
  `_` to `-`, matching Claude Code's naming.
- Ordering is by newest real activity: live transcript mtime, else preserved
  copy mtime, else recorded save time.
