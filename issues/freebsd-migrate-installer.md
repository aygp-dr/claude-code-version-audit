# FreeBSD Compatibility Issue with /migrate-installer Command

## Description

The `/migrate-installer` command in Claude Code fails on FreeBSD systems, resulting in a non-functioning executable.

## Environment

- Operating System: FreeBSD 14.2-RELEASE
- Architecture: amd64
- Node.js version: v22.13.1
- Bash version: GNU bash 5.2.37(0)-release
- Claude Code version: 0.2.56

## Symptoms

- Local installation process completes successfully
- Resulting executable file exists with proper permissions
- Error when executing: `-bash: /home/jwalsh/.claude/local/claude: cannot execute: required file not found`

## Technical Analysis

The issue appears to be platform-specific assumptions in the local wrapper script that don't account for FreeBSD's environment differences from Linux/macOS. The underlying script at `~/.claude/local/node_modules/@anthropic-ai/claude-code/claude-restart.sh` works correctly when executed directly.

## Workarounds

**Method 1: Direct Invocation**
```bash
alias claude="/home/jwalsh/.claude/local/node_modules/@anthropic-ai/claude-code/claude-restart.sh"
```

**Method 2: Custom Wrapper Script**
```bash
mkdir -p ~/bin
cat > ~/bin/claude << 'EOF'
#!/usr/bin/env bash
exec /home/jwalsh/.claude/local/node_modules/@anthropic-ai/claude-code/claude-restart.sh "$@"
EOF
chmod +x ~/bin/claude
```

## Version History

The `/migrate-installer` command appears to have been introduced around version 0.2.48, based on our version auditing research.

## Proposed Solutions

A proper fix would likely involve:
1. Updating the local installer to account for FreeBSD paths and environment
2. Adding BSD compatibility to the migration scripts
3. Testing installation on multiple BSD variants