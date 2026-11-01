#!/bin/bash
# PortMaster launcher for Rusty (PC-98) on RG35XX-H / KNULLI.

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

if [ -f "$controlfolder/control.txt" ]; then
  source "$controlfolder/control.txt"
  [ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
  get_controls
fi

GAMEDIR="/$directory/ports/rusty"
cd "$GAMEDIR" || exit 1
: > "$GAMEDIR/log.txt"
exec > >(tee -a "$GAMEDIR/log.txt") 2>&1

echo "=== Rusty RG35XX-H launcher ==="
echo "Date: $(date)"
echo "Firmware: ${CFW_NAME:-unknown}"
echo "CPU: $(uname -m)"
echo "Game directory: $GAMEDIR"

export LD_LIBRARY_PATH="$GAMEDIR/lib:${LD_LIBRARY_PATH:-}"
export SDL3SHIM_SDL2_LIB="${SDL3SHIM_SDL2_LIB:-/usr/lib/libSDL2-2.0.so.0}"
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig:-}"
export RUSTY_ROM_DIR="$GAMEDIR/roms"

GAME="$GAMEDIR/rusty"
if [ ! -x "$GAME" ]; then
  echo "ERROR: rusty executable missing"
  pm_finish 2>/dev/null || true
  exit 1
fi

# Rusty needs a disk image as its launch argument. Never guess between multiple images.
shopt -s nullglob
images=("$GAMEDIR"/roms/*.hdi "$GAMEDIR"/roms/*.HDI "$GAMEDIR"/roms/*.d88 "$GAMEDIR"/roms/*.D88 "$GAMEDIR"/roms/*.hdm "$GAMEDIR"/roms/*.HDM)
if [ "${#images[@]}" -eq 0 ]; then
  echo "ERROR: no .hdi/.d88/.hdm game disk image found in $GAMEDIR/roms"
  echo "See ASSETS_REQUIRED.txt"
  pm_finish 2>/dev/null || true
  exit 1
fi
if [ "${#images[@]}" -gt 1 ]; then
  echo "ERROR: multiple disk images found; leave only the desired Rusty disk image in roms/"
  printf '  %s\n' "${images[@]}"
  pm_finish 2>/dev/null || true
  exit 1
fi

echo "Disk image: ${images[0]}"
echo "SDL3 backend: SDL2 shim (firmware SDL2)"
echo "Renderer: Rusty default CPU renderer"
"$GAME" "${images[0]}"
status=$?
echo "Rusty exit status: $status"
pm_finish 2>/dev/null || true
exit "$status"
