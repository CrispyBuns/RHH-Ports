#!/bin/bash
set -u

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

if [ ! -r "$controlfolder/control.txt" ]; then
  echo "PortMaster control.txt not found: $controlfolder/control.txt" >&2
  exit 1
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/megamanx-snes-recomp"
GAME="$GAMEDIR/MegaManXSNESRecomp"
LOG="$GAMEDIR/log.txt"

mkdir -p "$GAMEDIR/userdata"
cd "$GAMEDIR" || exit 1
: > "$LOG"
exec > >(tee -a "$LOG") 2>&1

echo "=== Mega Man X Recompiled / RG35XX-H ==="
echo "Firmware: ${CFW_NAME:-unknown}"
echo "Architecture: $(uname -m)"
echo "Kernel: $(uname -sr)"
echo "Renderer: SDL2 OpenGL ES 2"
echo "Game directory: $GAMEDIR"
echo "Date: $(date)"

if [ ! -x "$GAME" ]; then
  echo "ERROR: executable not found: $GAME"
  pm_show_error "Mega Man X Recompiled executable is missing. Reinstall the port."
  exit 1
fi

if [ -d "$GAMEDIR/libs" ]; then
  export LD_LIBRARY_PATH="$GAMEDIR/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
export SDL_RENDER_DRIVER=opengles2
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Let PortMaster set up the platform environment and its exit handling.
pm_platform_helper "$GAME" || true

set +e
"$GAME" >> "$LOG" 2>&1
GAME_STATUS=$?
set -e
echo "Game exited with status $GAME_STATUS"
pm_finish
exit "$GAME_STATUS"
