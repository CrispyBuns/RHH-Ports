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
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig:-}"

# User-supplied PC-98 data lives in the Rusty recomp data folder.
# PortMaster layout: /roms/ports/rusty/rusty_data/
ROMDIR="$GAMEDIR/rusty_data"
export RUSTY_ROM_DIR="$ROMDIR"

echo "Rusty data directory: $ROMDIR"

GAME="$GAMEDIR/rusty"
if [ ! -x "$GAME" ]; then
  echo "ERROR: rusty executable missing"
  pm_finish 2>/dev/null || true
  exit 1
fi

if [ ! -d "$ROMDIR" ]; then
  echo "ERROR: Rusty data directory missing: $ROMDIR"
  echo "Create rusty_data/ inside the Rusty port folder and place your PC-98 files there."
  pm_finish 2>/dev/null || true
  exit 1
fi

# Rusty needs a disk image as its launch argument. Never guess between multiple images.
shopt -s nullglob
images=("$ROMDIR"/*.hdi "$ROMDIR"/*.HDI "$ROMDIR"/*.d88 "$ROMDIR"/*.D88 "$ROMDIR"/*.hdm "$ROMDIR"/*.HDM)
if [ "${#images[@]}" -eq 0 ]; then
  echo "ERROR: no .hdi/.d88/.hdm game disk image found in $ROMDIR"
  echo "Required PC-98 files belong in rusty_data/"
  pm_finish 2>/dev/null || true
  exit 1
fi
if [ "${#images[@]}" -gt 1 ]; then
  echo "ERROR: multiple disk images found in $ROMDIR; leave only the desired Rusty disk image"
  printf '  %s\n' "${images[@]}"
  pm_finish 2>/dev/null || true
  exit 1
fi

# These are also user-supplied PC-98 resources used by Rusty.
for required in FONT.ROM ym2608_adpcm_rom.bin; do
  if [ ! -f "$ROMDIR/$required" ]; then
    echo "ERROR: missing $required in $ROMDIR"
    pm_finish 2>/dev/null || true
    exit 1
  fi
done

echo "Disk image: ${images[0]}"
echo "FONT.ROM: $ROMDIR/FONT.ROM"
echo "YM2608 ADPCM ROM: $ROMDIR/ym2608_adpcm_rom.bin"
echo "SDL3 backend: SDL2 shim (firmware SDL2)"
echo "Renderer: Rusty default CPU renderer"
"$GAME" "${images[0]}"
status=$?
echo "Rusty exit status: $status"
pm_finish 2>/dev/null || true
exit "$status"
