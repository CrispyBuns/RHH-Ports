#!/bin/bash
# PORTMASTER: chaotix-recompiled.zip, Chaotix Recompiled.sh

export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

# Fail clearly if PortMaster's shared launcher functions are unavailable.
if [ ! -r "$controlfolder/control.txt" ]; then
  echo "PortMaster control.txt not found at: $controlfolder/control.txt" >&2
  exit 1
fi

source "$controlfolder/control.txt"
if [ -f "${controlfolder}/mod_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/mod_${CFW_NAME}.txt"
fi
get_controls

GAMEDIR="/$directory/ports/chaotix-recompiled"
ROMDIR="$GAMEDIR/ROM"
ROM="$ROMDIR/chaotix.32x"
USERDIR="$GAMEDIR/userdata"

mkdir -p "$ROMDIR" "$USERDIR" || {
  pm_show_error "Could not create the Chaotix Recompiled ROM or userdata directory."
  pm_finish
  exit 1
}
cd "$GAMEDIR" || {
  pm_show_error "Could not access the Chaotix Recompiled port directory."
  pm_finish
  exit 1
}

export LD_LIBRARY_PATH="$GAMEDIR/libs:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Select SDL3-shim drivers while preserving PortMaster's patched SDL2
# driver choices when the custom firmware provides them.
GAME_SDL_VIDEODRIVER=""
if [ -n "${SDL_VIDEODRIVER:-}" ]; then
  export SDL3SHIM_SDL2_VIDEODRIVER="$SDL_VIDEODRIVER"
  GAME_SDL_VIDEODRIVER=sdl2
fi

GAME_SDL_AUDIODRIVER=""
if [ -n "${SDL_AUDIODRIVER:-}" ]; then
  export SDL3SHIM_SDL2_AUDIODRIVER="$SDL_AUDIODRIVER"
  GAME_SDL_AUDIODRIVER=sdl2
fi

run_chaotix() {
  SDL_VIDEODRIVER="$GAME_SDL_VIDEODRIVER" \
  SDL_AUDIODRIVER="$GAME_SDL_AUDIODRIVER" \
    "$GAMEDIR/ChaotixRecompiled" "$@"
}

# Keep the PortMaster control UI cleanup in one place. The EXIT trap also
# covers errors and interruption, without calling pm_finish more than once.
GPTOKEYB_PID=""
PORTMASTER_FINISHED=0
finish_portmaster() {
  if [ "$PORTMASTER_FINISHED" -eq 1 ]; then
    return
  fi
  PORTMASTER_FINISHED=1

  if [ -n "$GPTOKEYB_PID" ]; then
    kill "$GPTOKEYB_PID" 2>/dev/null || true
    wait "$GPTOKEYB_PID" 2>/dev/null || true
    GPTOKEYB_PID=""
  fi

  pm_finish
}
trap finish_portmaster EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [ ! -x "$GAMEDIR/ChaotixRecompiled" ]; then
  pm_show_error "Chaotix Recompiled executable is missing. Reinstall the port."
  exit 1
fi

# ROMs for the port live in the main port directory's ROM folder.
# No ROM is included with the port.
if [ ! -f "$ROM" ]; then
  shopt -s nullglob
  rom_candidates=("$ROMDIR"/*.32x "$ROMDIR"/*.bin)
  shopt -u nullglob

  if [ "${#rom_candidates[@]}" -eq 1 ]; then
    ROM="${rom_candidates[0]}"
  elif [ "${#rom_candidates[@]}" -gt 1 ]; then
    pm_show_error "Multiple ROM files found in $ROMDIR. Keep one .32x or .bin ROM, or name the preferred file chaotix.32x."
    exit 1
  else
    pm_show_error "ROM not found. Place one legally obtained .32x or .bin ROM in /roms/ports/chaotix-recompiled/ROM/. No ROM is included."
    exit 1
  fi
fi

pm_message "Installing Chaotix ROM..."
run_chaotix --user-dir "$USERDIR" --install "$ROM"
result=$?
if [ "$result" -ne 0 ]; then
  pm_show_error "ROM installation failed. Check that it is Knuckles' Chaotix (Japan, USA) or Sonic in Chaotix Revision 2. See log.txt."
  exit "$result"
fi

# Start the controller mapper only when PortMaster supplied it.
if [ -n "${GPTOKEYB:-}" ] && [ -x "$GPTOKEYB" ]; then
  "$GPTOKEYB" "ChaotixRecompiled" -c "$GAMEDIR/chaotix.gptk" &
  GPTOKEYB_PID=$!
fi

pm_platform_helper "$GAMEDIR/ChaotixRecompiled" > /dev/null
run_chaotix --user-dir "$USERDIR" >> "$GAMEDIR/log.txt" 2>&1
exit $?
