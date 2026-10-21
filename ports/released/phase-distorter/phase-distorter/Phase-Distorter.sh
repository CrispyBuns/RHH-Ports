#!/bin/bash
# PortMaster launcher for Phase Distorter
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_DATA_HOME
PORT_DIR="$(dirname "$0")"
cd "$PORT_DIR"
if [ ! -x "$PORT_DIR/Phase-Distorter" ]; then
    echo "Phase Distorter executable is missing."
    read -r -p "Press Enter to exit..."
    exit 1
fi
exec "$PORT_DIR/Phase-Distorter"
