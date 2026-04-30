#!/bin/bash
# Activates iTerm and switches to the tmux "notes" window.

osascript -e 'tell application "iTerm" to activate'
sleep 0.1
tmux select-window -t notes 2>/dev/null
