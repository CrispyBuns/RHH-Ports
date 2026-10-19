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

GAMEDIR="/$directory/ports/ebredux"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:${LD_LIBRARY_PATH:-}"

cd "$GAMEDIR" || exit 1
: > "$GAMEDIR/log.txt"
exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -x "$GAMEDIR/earthbound" ]; then
  pm_show_error "The native EarthBound executable is missing. Reinstall the MaternalBound Redux port."
  pm_finish
  exit 1
fi

if [ ! -f "$GAMEDIR/gamedata/assets.pak" ]; then
  pm_show_error "Missing gamedata/assets.pak. Generate the MaternalBound Redux asset pack on your PC and copy it into the gamedata folder."
  pm_finish
  exit 1
fi

chmod +x "$GAMEDIR/earthbound"
if [ -n "${GPTOKEYB:-}" ]; then
  "$GPTOKEYB" "earthbound" &
fi
pm_platform_helper "$GAMEDIR/earthbound" >/dev/null 2>&1 || true
"$GAMEDIR/earthbound" --assets "$GAMEDIR/gamedata/assets.pak"

pm_finish
