# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Test Commands
- Initialize repo: `make init` (sets up git submodules)
- Run full audit: `make audit` or `make all` for init+audit
- Refresh submodules: `make refresh`
- Clean up: `make clean` (removes versions directory)
- Run a specific version audit: Edit VERSIONS array in npm-package-audit.sh
- Run specific pattern search: Add new grep patterns to npm-package-audit.sh

## Code Style Guidelines
- **Shell scripts**: Begin with shebang `#!/usr/bin/env bash` for FreeBSD compatibility
- **Bash**: Use proper error handling with `set -e` when appropriate
- **Makefile**: All targets should be listed in .PHONY declaration
- **Grep patterns**: Use `--include="*.js"` to filter by file type
- **Documentation**: Use org-mode (*.org) for README and docs
- **Git**: Use submodules for referencing external repositories
- **Version arrays**: Format as multi-line arrays with consistent indentation
- **Audit structure**: Create directories per version and extract package content
- **Error handling**: Include fallback messages with `|| echo "Not found"`

## Commit Guidelines
- **Conventional Commits**: Format as `type(scope): description`
  - Examples: `feat(audit): add support for new package format`, `fix(scripts): correct FreeBSD compatibility issue`
- **Co-authorship**: Use git trailers instead of inline attribution
  - Example:
    ```
    feat(audit): add support for new package

    Co-authored-by: Claude <noreply@anthropic.com>
    Reviewed-by: jwalsh
    ```