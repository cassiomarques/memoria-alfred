#!/bin/bash
# Activates the iTerm window that contains the tmux session with the "notes"
# window (where Memoria runs), and switches tmux to that window.
# Works correctly even with multiple iTerm windows open by matching the
# client tty rather than relying on the iTerm window title.

# Find which tmux session has the "notes" window and switch to it.
SESSION=$(tmux list-windows -a -F '#{session_id}' -f '#{==:#{window_name},notes}' 2>/dev/null | head -1)

if [ -z "$SESSION" ]; then
    # Fallback: just activate iTerm
    osascript -e 'tell application "iTerm" to activate'
    exit 0
fi

tmux select-window -t "${SESSION}:notes" 2>/dev/null

# Find the tty of the client connected to that session.
CLIENT_TTY=$(tmux list-clients -t "$SESSION" -F '#{client_tty}' 2>/dev/null | head -1)

if [ -z "$CLIENT_TTY" ]; then
    osascript -e 'tell application "iTerm" to activate'
    exit 0
fi

# Activate iTerm and select the window whose session matches that tty.
osascript -e "
tell application \"iTerm\"
  activate
  repeat with w in windows
    repeat with t in tabs of w
      repeat with s in sessions of t
        if tty of s is \"$CLIENT_TTY\" then
          select w
          return
        end if
      end repeat
    end repeat
  end repeat
end tell" 2>/dev/null
