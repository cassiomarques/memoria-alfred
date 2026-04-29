# Memoria Alfred Workflow

An [Alfred](https://www.alfredapp.com/) workflow for quick note and todo capture with [Memoria](https://github.com/cassiomarques/memoria).

## Features

- **Quick Note from Clipboard** — hotkey to instantly save clipboard contents as a new note
- **Quick Todo** — keyword trigger to create a todo with optional due date

## Requirements

- [Memoria](https://github.com/cassiomarques/memoria) installed and running (the TUI must be open)
- Alfred 5 with Powerpack
- macOS

## Installation

1. Download the latest `.alfredworkflow` file from [Releases](https://github.com/cassiomarques/memoria-alfred/releases)
2. Double-click to import into Alfred

## Usage

### Create Note from Clipboard

**Hotkey:** `⌥⇧N` (Option+Shift+N)

Saves your current clipboard contents as a new Memoria note. You'll be prompted for the note name.

**Keyword:** `mn` followed by the note name

```
mn meeting-notes
```

### Create Todo

**Keyword:** `mt` followed by the todo title

```
mt buy groceries
mt fix auth bug --due 2 weeks
mt deploy app --due 2026-05-01 --tags work,urgent
```

**Supported flags:**
- `--due <date>` — due date (YYYY-MM-DD or relative like "2 weeks", "3 days")
- `--tags <tag1,tag2>` — comma-separated tags
- `--folder <path>` — custom folder (default: TODO)

## How It Works

The workflow calls `memoria` CLI subcommands which communicate with the running TUI via IPC (Unix socket). The TUI must be running for commands to work.

If the TUI isn't running, you'll get a notification saying Memoria is not available.

## Development

The workflow is a standard Alfred workflow bundle. Edit in Alfred's workflow editor or modify the scripts directly in the `workflow/` directory.

