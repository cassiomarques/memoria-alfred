#!/bin/bash
# Builds the .alfredworkflow file (just a zip with a different extension)
set -e

cd "$(dirname "$0")"
rm -f Memoria.alfredworkflow

cd workflow
chmod +x new-from-clipboard.sh create-todo.sh
zip -r ../Memoria.alfredworkflow . -x ".*"

cd ..
echo "Built: Memoria.alfredworkflow"
echo "Double-click to install in Alfred."
