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

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_AUDIODRIVER="alsa"

cd "$GAMEDIR" || exit 1

if [ ! -f "$GAMEDIR/zelda3_assets.dat" ]; then
  pm_show_error "Z3R needs zelda3_assets.dat.\n\nGenerate it from your legally dumped USA A Link to the Past ROM on a PC, then copy zelda3_assets.dat to:\n\n$GAMEDIR"
  pm_finish
  exit 1
fi

$ESUDO chmod +x "$GAMEDIR/zelda3"
pm_platform_helper "$GAMEDIR/zelda3" > /dev/null

./zelda3

pm_finish
