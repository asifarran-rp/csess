#!/usr/bin/env bash
# Install csess by symlinking the repo's source into the locations Claude Code
# and your shell look in. Re-running is safe (idempotent). Because these are
# symlinks, `git pull` in this repo instantly updates the installed tool.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
CMD_DIR="${CMD_DIR:-$HOME/.claude/commands}"

mkdir -p "$BIN_DIR" "$CMD_DIR"

ln -sfn "$REPO/bin/csess" "$BIN_DIR/csess"
ln -sfn "$REPO/commands/keep.md" "$CMD_DIR/keep.md"

echo "installed:"
echo "  $BIN_DIR/csess        -> $REPO/bin/csess"
echo "  $CMD_DIR/keep.md      -> $REPO/commands/keep.md"
echo
case ":$PATH:" in
  *":$BIN_DIR:"*) echo "PATH ok: $BIN_DIR is on your PATH";;
  *) echo "NOTE: add $BIN_DIR to your PATH to use 'csess'";;
esac
echo "done. run 'csess' to browse sessions, '/keep' inside a session to save one."
