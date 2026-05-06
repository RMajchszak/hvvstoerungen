#!/bin/bash
# Ralph Loop Stop Hook
# This script is called when the Ralph loop should stop gracefully.
# Exit 0 to allow stop, exit non-zero to prevent stop.

# Default: allow immediate stop
# Customize this script for project-specific cleanup

echo "Ralph loop stop requested"
exit 0
