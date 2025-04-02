# Interactive Commands Lock REPL

## Description

Certain interactive commands cause Claude Code's REPL to lock up, requiring a hard reset or terminal restart. Standard interrupt signals (ESC, Ctrl+C, Ctrl+D, Ctrl+G) do not break out of these locked states.

## Affected Commands

The following interactive command types cause this issue:

- `git commit` with GPG signing enabled
- Commands requiring `sudo` password input
- Interactive editors like `emacs` without batch mode
- Any command that requires user input in an interactive prompt

## Steps to Reproduce

1. Start Claude Code in interactive mode: `claude`
2. Run any of the following commands:
   - `git commit` (with GPG signing configured)
   - `sudo apt update` (or any sudo command requiring password)
   - `emacs file.txt` (without `-batch` flag)

## Expected Behavior

Claude Code should either:
- Allow these commands to work with proper input handling, or
- Gracefully detect interactive commands and prevent them from locking the terminal
- Ensure keyboard interrupts can always break out of running processes

## Current Behavior

- REPL becomes completely unresponsive
- No keyboard interrupts work (ESC, Ctrl+C, Ctrl+D, Ctrl+G)
- Terminal must be force closed or the process killed externally

## Workarounds

- For git: Use `git commit -m "message"` instead of interactive mode
- For sudo: Run elevated commands outside of Claude Code
- For editors: Use non-interactive options (`emacs -batch`) or Claude Code's built-in editing capabilities

## Technical Analysis

This appears to be due to:
1. The way Claude Code's REPL handles TTY/PTY allocation
2. Signal handling limitations in the current implementation
3. Lack of detection for commands that require interactive input

## Related Issues

- Issue #XXX: Alternative terminal modes
- Issue #YYY: Signal handling improvements