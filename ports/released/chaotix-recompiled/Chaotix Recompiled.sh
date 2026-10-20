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

GAMEDIR="/$directory/ports/chaotix-recompiled"
ROMDIR="$GAMEDIR/ROM"
ROM="$ROMDIR/chaotix.32x"
USERDIR="$GAMEDIR/userdata"

mkdir -p "$USERDIR"
cd "$GAMEDIR" || exit 1
export LD_LIBRARY_PATH="$GAMEDIR/libs:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ ! -x "$GAMEDIR/ChaotixRecompiled" ]; then
  pm_show_error "Chaotix Recompiled executable is missing. Reinstall the port."
  pm_finish
  exit 1
fi

if [ ! -f "$USERDIR/Game/chaotix.32x" ] && [ ! -f "$USERDIR/Game/Knuckles' Chaotix.32x" ]; then
  if [ ! -f "$ROM" ]; then
    shopt -s nullglob
    rom_candidates=("$ROMDIR"/*.32x "$ROMDIR"/*.bin)
    shopt -u nullglob

    if [ "${#rom_candidates[@]}" -eq 1 ]; then
      ROM="${rom_candidates[0]}"
    elif [ "${#rom_candidates[@]}" -gt 1 ]; then
      pm_show_error "Multiple ROM files found in $ROMDIR. Keep one .32x or .bin ROM, or name the preferred file chaotix.32x."
      pm_finish
      exit 1
    else
      pm_show_error "ROM not found. Place one legally obtained .32x or .bin ROM in /roms/ports/chaotix-recompiled/ROM/. No ROM is included."
      pm_finish
      exit 1
    fi
  fi
  pm_message "Installing Chaotix ROM..."
  "$GAMEDIR/ChaotixRecompiled" --user-dir "$USERDIR" --install "$ROM"
  result=$?
  if [ "$result" -ne 0 ]; then
    pm_show_error "ROM installation failed. Check that the ROM is the supported Knuckles' Chaotix (Japan, USA) image. See log.txt."
    pm_finish
    exit "$result"
  fi
fi

$GPTOKEYB "ChaotixRecompiled" -c "$GAMEDIR/chaotix.gptk" &
pm_platform_helper "$GAMEDIR/ChaotixRecompiled" > /dev/null
"$GAMEDIR/ChaotixRecompiled" --user-dir "$USERDIR" >> "$GAMEDIR/log.txt" 2>&1
pm_finish
