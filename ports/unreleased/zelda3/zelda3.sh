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

GAMEDIR="/$directory/ports/zelda3"
GAME="$GAMEDIR/zelda3"

# Keep the working directory beside the executable so the game's INI,
# assets, saves and diagnostic log stay together in the PortMaster folder.
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "=== Z3R-Beta RG35XX-H launch ==="
echo "Renderer: SDL-Software"
echo "NewRenderer: disabled"
echo "CPU profile: Cortex-A53 + LTO"
echo "Game directory: $GAMEDIR"
echo "Date: $(date)"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

chmod +x "$GAME"

# Let PortMaster handle platform-specific environment and exit behavior.
pm_platform_helper "$GAME"
"$GAME"

pm_finish
