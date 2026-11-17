#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/z3r-beta"
cd "$GAMEDIR" || exit 1
mkdir -p "$GAMEDIR/saves"

# Start a fresh runtime log on each launch. Both launcher and game output
# (stdout/stderr) are captured here for PortMaster troubleshooting.
LOGFILE="$GAMEDIR/log.txt"
: > "$LOGFILE"
exec >> "$LOGFILE" 2>&1

echo "=================================================="
echo " Z3R-Beta runtime log"
echo " Started: $(date)"
echo " Game directory: $GAMEDIR"
echo " Firmware: ${CFW_NAME:-unknown}"
echo "=================================================="

if [ ! -f "$GAMEDIR/zelda3_assets.dat" ]; then
  echo "[ERROR] Missing zelda3_assets.dat"
  pm_message "Missing zelda3_assets.dat. Generate it on your PC from your own game copy with Redux dialogue, then copy it into ports/z3r-beta. See README.md."
  pm_finish
  exit 1
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

echo "[INFO] Starting GPTOKEYB: $GPTOKEYB"
"$GPTOKEYB" "$GAMEDIR/zelda3" &
GPTOKEYB_PID=$!
echo "[INFO] GPTOKEYB PID: $GPTOKEYB_PID"

echo "[INFO] Running PortMaster platform helper"
pm_platform_helper "$GAMEDIR/zelda3"

echo "[INFO] Launching Z3R-Beta: $(date)"
if "$GAMEDIR/zelda3"; then
  GAME_STATUS=0
else
  GAME_STATUS=$?
fi

echo "[INFO] Z3R-Beta exited with status $GAME_STATUS at $(date)"
echo "[INFO] Runtime log finished"

pm_finish
exit "$GAME_STATUS"
