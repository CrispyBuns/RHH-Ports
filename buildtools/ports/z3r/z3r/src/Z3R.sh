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

GAMEDIR="/$directory/ports/z3r"
cd "$GAMEDIR" || exit 1
mkdir -p "$GAMEDIR/saves"

if [ ! -f "$GAMEDIR/zelda3_assets.dat" ]; then
  pm_message "Missing zelda3_assets.dat. Generate it on your PC from your own game copy with Redux dialogue, then copy it into ports/z3r. See README.md."
  pm_finish
  exit 1
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
"$GPTOKEYB" "$GAMEDIR/zelda3" &
pm_platform_helper "$GAMEDIR/zelda3"
"$GAMEDIR/zelda3"
pm_finish
