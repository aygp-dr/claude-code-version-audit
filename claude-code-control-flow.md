# Claude Code Control Flow

## Main Control Flow Diagram

```mermaid
graph TB
    Start([User runs 'claude' command]) --> Wrapper[claude-restart.sh wrapper]
    
    Wrapper --> CLI[cli.js Entry Point]
    
    CLI --> Parser[Commander.js parses arguments]
    
    Parser --> CheckMode{Interactive or Command?}
    
    CheckMode -->|Command Mode| Command[Execute specific command]
    CheckMode -->|Interactive Mode| Interactive[Start REPL/Interactive Session]
    
    Command --> ConfigCmd[config command]
    Command --> MCPCmd[mcp command]
    Command --> MigrateCmd[migrate-installer command]
    Command --> DoctorCmd[doctor command]
    Command --> UpdateCmd[update command]
    
    Interactive --> UI[React/Ink UI Components]
    UI --> Input[Handle user input]
    Input --> SlashCheck{Slash command?}
    
    SlashCheck -->|Yes| SlashCmd[Process slash command]
    SlashCheck -->|No| Process[Process regular input]
    
    SlashCmd --> Help[/help]
    SlashCmd --> Init[/init]
    SlashCmd --> MCPStatus[/mcp]
    SlashCmd --> PRComments[/pr-comments]
    
    Process --> Tools[Execute tools]
    Tools --> ToolExec[Tool execution]
    
    ToolExec --> ExitCheck{Check exit code}
    ExitCheck -->|42| RestartResume[Restart with 'resume 0']
    ExitCheck -->|43| RestartTool[Tool restart 'Keep going..']
    ExitCheck -->|Other| Cleanup[Cleanup and exit]
    
    RestartResume --> Wrapper
    RestartTool --> Wrapper
    
    ConfigCmd --> ConfigStore[Read/Write config files]
    MCPCmd --> MCPServers[Manage MCP servers]
    MigrateCmd --> LocalInstall[Migrate to local installation]
    DoctorCmd --> HealthCheck[Check installation health]
    UpdateCmd --> AutoUpdate[Check and install updates]
```

## Authentication Flow

```mermaid
graph LR
    Start([API Key needed]) --> CheckEnv{Check env vars}
    CheckEnv -->|Found| UseEnv[Use environment API key]
    CheckEnv -->|Not found| CheckConfig{Check config files}
    
    CheckConfig --> Local[Check local config]
    CheckConfig --> User[Check user config]
    CheckConfig --> Project[Check project config]
    
    Local -->|Found| UseLocal[Use local API key]
    User -->|Found| UseUser[Use user API key]
    Project -->|Found| UseProject[Use project API key]
    
    Local -->|Not found| User
    User -->|Not found| Project
    Project -->|Not found| Prompt[Prompt for API key]
```

## Tool Execution Flow

```mermaid
graph TD
    ToolRequest([Tool execution requested]) --> ValidateTool{Validate tool}
    ValidateTool -->|Valid| PrepareArgs[Prepare arguments]
    ValidateTool -->|Invalid| Error[Return error]
    
    PrepareArgs --> Execute[Execute tool]
    Execute --> CaptureOutput[Capture output/errors]
    
    CaptureOutput --> CheckSuccess{Success?}
    CheckSuccess -->|Yes| ReturnResult[Return result]
    CheckSuccess -->|No| HandleError[Handle error]
    
    HandleError --> CheckRestart{Needs restart?}
    CheckRestart -->|Yes| ExitWithCode[Exit with special code]
    CheckRestart -->|No| ReturnError[Return error to user]
```

## Configuration Management Flow

```mermaid
graph TD
    ConfigOp([Config operation]) --> OpType{Operation type}
    
    OpType -->|Get| ReadConfig[Read configuration]
    OpType -->|Set| WriteConfig[Write configuration]
    OpType -->|Remove| DeleteConfig[Delete configuration]
    OpType -->|List| ListConfig[List all configs]
    OpType -->|Add| AddConfig[Add to array config]
    
    ReadConfig --> Scope{Determine scope}
    WriteConfig --> Scope
    DeleteConfig --> Scope
    
    Scope -->|Local| LocalFile[.claude.json in current dir]
    Scope -->|User| UserFile[~/.config/claude.json]
    Scope -->|Project| ProjectFile[Project-specific config]
    
    LocalFile --> JSONOp[JSON read/write operations]
    UserFile --> JSONOp
    ProjectFile --> JSONOp
```

## MCP Server Management Flow

```mermaid
graph LR
    MCPCommand([MCP command]) --> Action{Action type}
    
    Action -->|Status| CheckServers[Check server status]
    Action -->|Add| AddServer[Add MCP server]
    Action -->|Remove| RemoveServer[Remove MCP server]
    Action -->|List| ListServers[List all servers]
    
    CheckServers --> ReadMCP[Read .mcp.json]
    AddServer --> WriteMCP[Write .mcp.json]
    RemoveServer --> WriteMCP
    ListServers --> ReadMCP
    
    ReadMCP --> DisplayStatus[Display server info]
    WriteMCP --> UpdateConfig[Update configuration]
```