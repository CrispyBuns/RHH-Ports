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

GAMEDIR="/$directory/ports/symphonyrecomp"
cd "$GAMEDIR" || exit 1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:${LD_LIBRARY_PATH:-}"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/config"

# Keep SymphonyRecomp's user data inside the port directory so saves/configuration
# survive reinstalls and do not depend on the host desktop configuration.
export XDG_CONFIG_HOME="$GAMEDIR/config"
export XDG_DATA_HOME="$GAMEDIR/config"

if [ -x "$GAMEDIR/sotn" ]; then
    GAME="./sotn"
elif [ -x "$GAMEDIR/run.sh" ]; then
    GAME="./run.sh"
else
    echo "ERROR: SymphonyRecomp executable not found."
    pm_finish
    exit 1
fi

$GPTOKEYB "sotn" -c "sotn.gptk" &
GPTK_PID=$!
pm_platform_helper "sotn" >/dev/null 2>&1 &
PLATFORM_PID=$!

$GAME
RET=$?

kill "$GPTK_PID" 2>/dev/null || true
kill "$PLATFORM_PID" 2>/dev/null || true

pm_finish
exit $RET
