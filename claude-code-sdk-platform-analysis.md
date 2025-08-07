# Claude Code SDK: Programmable Platform Deep Dive

## Executive Summary

Version 1.0.67 transformed Claude Code from a CLI tool into a **programmable platform** by introducing an SDK that enables developers to integrate Claude's capabilities directly into their applications. This analysis explores the full scope of programmable options and their implications.

## Core SDK Architecture

### 1. Primary Query Interface

```typescript
export function query({ prompt, abortController, options }: Props): Query
```

The SDK provides a streaming async generator interface that yields messages in real-time:

```typescript
const response = query({ 
  prompt: "Help me write a function", 
  options: {} 
})
for await (const message of response) {
  console.log(message)
}
```

### 2. Message Types

The SDK supports four distinct message types:

- **SDKUserMessage**: User inputs with session tracking
- **SDKAssistantMessage**: Claude's responses  
- **SDKResultMessage**: Execution results (success/error)
- **SDKSystemMessage**: System initialization info

## Programmable Platform Capabilities

### 1. Tool Execution Control

The SDK exposes **21 distinct tools** that can be programmatically controlled:

#### File Operations
- `FileRead`: Read files with offset/limit control
- `FileWrite`: Create/overwrite files
- `FileEdit`: Precise text replacements
- `FileMultiEdit`: Batch edit operations

#### Code Search & Analysis
- `Grep`: Regex search with ripgrep integration
- `Glob`: Pattern-based file discovery
- `LS`: Directory exploration with filtering

#### Development Workflow
- `Bash`: Execute shell commands with timeout control
- `Agent`: Spawn specialized sub-agents for complex tasks
- `TodoWrite`: Task management with priority levels
- `NotebookEdit`: Jupyter notebook manipulation

#### Web Integration
- `WebFetch`: Fetch and analyze web content
- `WebSearch`: Programmatic web searches with domain filtering

#### MCP (Model Context Protocol)
- `McpInput`: Interact with MCP servers
- `ListMcpResources`: Discover available resources
- `ReadMcpResource`: Access MCP resource data

### 2. Execution Modes

```typescript
export type PermissionMode =
  | 'default'        // Interactive permission prompts
  | 'acceptEdits'    // Auto-accept file edits
  | 'bypassPermissions' // Full automation
  | 'plan'          // Planning-only mode
```

### 3. Advanced Options

```typescript
export type Options = {
  // Execution Control
  maxTurns?: number           // Limit conversation turns
  maxThinkingTokens?: number  // Control reasoning depth
  abortController?: AbortController
  
  // Tool Restrictions
  allowedTools?: string[]      // Whitelist specific tools
  disallowedTools?: string[]   // Blacklist tools
  
  // Environment
  cwd?: string                 // Working directory
  executable?: 'bun' | 'deno' | 'node'
  
  // MCP Integration
  mcpServers?: Record<string, McpServerConfig>
  
  // Session Management
  continue?: boolean           // Continue previous session
  resume?: string             // Resume from checkpoint
  
  // Model Selection
  model?: string              // Primary model choice
  fallbackModel?: string      // Backup model
}
```

### 4. MCP Server Types

Three types of MCP server configurations:

```typescript
// Standard I/O process
McpStdioServerConfig: {
  command: string
  args?: string[]
  env?: Record<string, string>
}

// Server-Sent Events
McpSSEServerConfig: {
  type: 'sse'
  url: string
  headers?: Record<string, string>
}

// HTTP REST API
McpHttpServerConfig: {
  type: 'http'
  url: string
  headers?: Record<string, string>
}
```

## Use Case Implementations

### 1. Automated Code Review Bot

```typescript
import { query } from '@anthropic-ai/claude-code'

async function reviewPR(files: string[]) {
  const response = query({
    prompt: `Review these files for issues: ${files.join(', ')}`,
    options: {
      allowedTools: ['FileRead', 'Grep', 'Agent'],
      permissionMode: 'bypassPermissions',
      maxTurns: 10
    }
  })
  
  for await (const message of response) {
    if (message.type === 'result') {
      return message.result
    }
  }
}
```

### 2. CI/CD Pipeline Integration

```typescript
async function runTests() {
  const response = query({
    prompt: "Run all tests and fix any failures",
    options: {
      allowedTools: ['Bash', 'FileEdit', 'FileRead'],
      permissionMode: 'acceptEdits',
      cwd: process.env.GITHUB_WORKSPACE
    }
  })
  // Process results...
}
```

### 3. Interactive Development Assistant

```typescript
async function* interactiveCoding(userInput: AsyncIterable<string>) {
  const userMessages = convertToSDKMessages(userInput)
  
  const response = query({
    prompt: userMessages, // Streaming input
    options: {
      permissionMode: 'default',
      mcpServers: {
        'project-context': {
          type: 'stdio',
          command: 'mcp-server',
          args: ['--project', '.']
        }
      }
    }
  })
  
  // Can interrupt mid-execution
  response.interrupt()
}
```

### 4. Documentation Generator

```typescript
async function generateDocs(sourceDir: string) {
  return query({
    prompt: `Generate comprehensive documentation for ${sourceDir}`,
    options: {
      allowedTools: ['FileRead', 'FileWrite', 'Glob'],
      disallowedTools: ['Bash', 'WebFetch'],
      permissionMode: 'bypassPermissions'
    }
  })
}
```

## Platform Integration Patterns

### 1. VS Code Extension

```typescript
// In VS Code extension
import * as vscode from 'vscode'
import { query } from '@anthropic-ai/claude-code'

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand(
    'claude.refactor',
    async () => {
      const editor = vscode.window.activeTextEditor
      const response = query({
        prompt: `Refactor this code: ${editor.document.getText()}`,
        options: {
          allowedTools: ['FileEdit'],
          cwd: vscode.workspace.rootPath
        }
      })
      // Apply edits...
    }
  )
}
```

### 2. GitHub Action

```yaml
- name: Claude Code Review
  uses: actions/github-script@v6
  with:
    script: |
      const { query } = require('@anthropic-ai/claude-code')
      const response = await query({
        prompt: 'Review changed files',
        options: {
          permissionMode: 'bypassPermissions',
          allowedTools: ['FileRead', 'Grep']
        }
      })
```

### 3. Slack Bot Integration

```typescript
import { App } from '@slack/bolt'
import { query } from '@anthropic-ai/claude-code'

app.message(/debug (.+)/, async ({ say, context }) => {
  const response = query({
    prompt: `Debug this error: ${context.matches[1]}`,
    options: {
      allowedTools: ['WebSearch', 'WebFetch'],
      maxTurns: 5
    }
  })
  
  for await (const message of response) {
    if (message.type === 'assistant') {
      await say(message.message.content)
    }
  }
})
```

## Advanced Features

### 1. Sandboxed Execution

```typescript
// Run commands in read-only sandbox
{
  command: "grep -r 'TODO'",
  sandbox: true  // No filesystem writes or network
}
```

### 2. Custom Shell Configuration

```typescript
{
  shellExecutable: '/usr/bin/zsh',
  env: {
    NODE_ENV: 'production',
    CUSTOM_VAR: 'value'
  }
}
```

### 3. Streaming Input Support

```typescript
// Real-time interaction
async function* userInputGenerator() {
  yield createUserMessage("Start the task")
  await delay(5000)
  yield createUserMessage("Add error handling")
}

const response = query({
  prompt: userInputGenerator(),
  options: { /* ... */ }
})
```

### 4. Interrupt Capability

```typescript
const response = query({ /* ... */ })

// Can interrupt mid-execution
setTimeout(() => response.interrupt(), 10000)
```

## Security & Permission Models

### 1. Granular Tool Control
- Whitelist specific tools for security
- Blacklist dangerous operations
- Tool-level permission prompts

### 2. Execution Sandboxing
- Read-only mode for analysis
- Network isolation options
- Filesystem access control

### 3. API Key Management
```typescript
export type ApiKeySource = 
  | 'user'      // User-level API key
  | 'project'   // Project-specific
  | 'org'       // Organization-wide
  | 'temporary' // Session-based
```

## Performance Optimization

### 1. Token Management
- `maxThinkingTokens`: Control reasoning depth
- `maxTurns`: Limit conversation length
- Cost tracking via `total_cost_usd`

### 2. Parallel Execution
- Multiple tool calls in single turn
- Async generator for streaming results
- AbortController for cancellation

### 3. Caching & Resume
- `continue`: Resume previous sessions
- `resume`: Checkpoint-based recovery
- Session ID tracking

## Ecosystem Integration

### 1. TypeScript First
- Full TypeScript definitions
- Type-safe tool inputs
- IntelliSense support

### 2. Framework Agnostic
- Works with any Node.js framework
- Browser compatibility (with bundler)
- Deno/Bun support

### 3. MCP Ecosystem
- Connect to any MCP server
- Resource discovery
- Protocol standardization

## Future Platform Directions

### Potential Enhancements
1. **Plugin System**: Custom tool development
2. **Workflow Orchestration**: Complex task automation
3. **Multi-Agent Coordination**: Collaborative AI systems
4. **Real-time Collaboration**: Shared coding sessions
5. **Cloud Execution**: Serverless Claude Code
6. **Mobile SDKs**: iOS/Android integration

## Conclusion

The SDK release in v1.0.67 fundamentally transformed Claude Code from a CLI tool into a **comprehensive AI development platform**. It enables:

- **Programmatic Integration**: Embed Claude in any application
- **Workflow Automation**: Build complex AI-powered pipelines  
- **Tool Ecosystem**: Extensible architecture for custom tools
- **Enterprise Ready**: TypeScript, permissions, security models
- **Developer Experience**: Streaming, interrupts, session management

This positions Claude Code as a foundational platform for AI-assisted development, competing directly with GitHub Copilot X, Cursor's API, and other AI coding platforms.