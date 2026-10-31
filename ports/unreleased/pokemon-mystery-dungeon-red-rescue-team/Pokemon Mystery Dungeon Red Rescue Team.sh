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
trap pm_finish EXIT

GAMEDIR="/$directory/ports/pokemon-mystery-dungeon-red-rescue-team"
GAME="$GAMEDIR/PokemonMysteryDungeonRedRescueTeamRecomp"
LOG="$GAMEDIR/log.txt"

mkdir -p "$GAMEDIR/saves" "$GAMEDIR/userdata"
cd "$GAMEDIR" || exit 1
: > "$LOG"
exec > >(tee -a "$LOG") 2>&1

echo "=== Pokemon Mystery Dungeon: Red Rescue Team Recomp ==="
echo "Firmware: ${CFW_NAME:-unknown}"
echo "Architecture: $(uname -m)"
echo "Kernel: $(uname -sr)"
echo "Renderer: SDL2 software renderer"
echo "Resolution: original 240x160 game view"
echo "Game directory: $GAMEDIR"
echo "Date: $(date)"

if [ ! -x "$GAME" ]; then
  echo "ERROR: executable not found: $GAME"
  pm_show_error "PMD Red Rescue Team executable is missing. Reinstall the port."
  exit 1
fi

if [ ! -f "$GAMEDIR/bios/gba_bios.bin" ]; then
  echo "ERROR: missing bios/gba_bios.bin"
  pm_show_error "Add your own GBA BIOS as bios/gba_bios.bin. See ASSETS_REQUIRED.txt."
  exit 1
fi

if [ ! -f "$GAMEDIR/roms/pokemon_mystery_dungeon_red_rescue_team.gba" ]; then
  echo "ERROR: missing Red Rescue Team ROM"
  pm_show_error "Add your own Red Rescue Team ROM in the roms folder. See ASSETS_REQUIRED.txt."
  exit 1
fi

if [ -d "$GAMEDIR/libs" ]; then
  export LD_LIBRARY_PATH="$GAMEDIR/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# The GBA runtime uses SDL2's 2D renderer. No OpenGL, GL4ES, KMS, or DRM
# renderer path is required by this port.
export SDL_RENDER_DRIVER=software
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GBARECOMP_NO_VSYNC=1

# PortMaster handles the handheld controls and Start + Select exit shortcut.
pm_platform_helper "$GAME" || true

set +e
"$GAME" >> "$LOG" 2>&1
GAME_STATUS=$?
set -e

echo "Game exited with status $GAME_STATUS"
exit "$GAME_STATUS"
