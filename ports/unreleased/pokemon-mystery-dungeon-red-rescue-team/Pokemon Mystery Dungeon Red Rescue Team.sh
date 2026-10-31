#!/bin/bash
set +u  # PortMaster's KNULLI device_info.txt may reference unset variables.

# Start a bootstrap log before loading PortMaster scripts. On KNULLI the
# default ROM root is /userdata/roms; this captures control.txt failures too.
BOOT_GAMEDIR="/${directory:-userdata/roms}/ports/pokemon-mystery-dungeon-red-rescue-team"
mkdir -p "$BOOT_GAMEDIR"
LOG="$BOOT_GAMEDIR/log.txt"
: > "$LOG"
exec > >(tee -a "$LOG") 2>&1

echo "=== Launcher bootstrap ==="
echo "Date: $(date)"
echo "Initial log: $LOG"

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

mkdir -p "$GAMEDIR/saves" "$GAMEDIR/userdata"
cd "$GAMEDIR" || exit 1

# Switch to PortMaster's resolved path if it differs from the bootstrap path.
if [ "$LOG" != "$GAMEDIR/log.txt" ]; then
  LOG="$GAMEDIR/log.txt"
  mkdir -p "$GAMEDIR"
  : > "$LOG"
  exec > >(tee -a "$LOG") 2>&1
fi
echo "Resolved game directory: $GAMEDIR"

echo "=== Pokemon Mystery Dungeon: Red Rescue Team Recomp ==="
echo "Firmware: ${CFW_NAME:-unknown}"
echo "Architecture: $(uname -m)"
echo "Kernel: $(uname -sr)"
echo "Renderer: SDL2 software renderer"
echo "Game directory: $GAMEDIR"
echo "Date: $(date)"

if [ ! -x "$GAME" ]; then
  echo "ERROR: executable not found: $GAME"
  pm_show_error "PMD Red Rescue Team executable is missing. Reinstall the port."
  exit 1
fi

# User data layout: bios/ for the GBA BIOS and ROM/ for the game ROM.
BIOS="$GAMEDIR/bios/gba_bios.bin"
ROM_DIR="$GAMEDIR/ROM"

if [ ! -f "$BIOS" ]; then
  echo "ERROR: missing BIOS: $BIOS"
  pm_show_error "Place your GBA BIOS at bios/gba_bios.bin."
  exit 1
fi

if [ ! -d "$ROM_DIR" ]; then
  echo "ERROR: missing ROM directory: $ROM_DIR"
  pm_show_error "Create the ROM folder and place your Red Rescue Team .gba file inside it."
  exit 1
fi

ROM=""
while IFS= read -r -d '' file; do
  ROM="$file"
  break
done < <(find "$ROM_DIR" -maxdepth 1 -type f -iname '*.gba' -print0)

if [ -z "$ROM" ]; then
  echo "ERROR: no .gba file found in $ROM_DIR"
  pm_show_error "Place your Red Rescue Team .gba ROM inside the ROM folder."
  exit 1
fi

echo "BIOS: $BIOS"
echo "ROM: $ROM"

if [ -d "$GAMEDIR/libs" ]; then
  export LD_LIBRARY_PATH="$GAMEDIR/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# SDL2 2D software rendering; no OpenGL, GL4ES, KMS, or DRM.
export SDL_RENDER_DRIVER=software
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GBARECOMP_NO_VSYNC=1
export GBARECOMP_DIAGNOSTICS=0

# Start PortMaster's controller/exit helper. Without a custom .gptk file,
# gptokeyb uses the device's standard exit shortcut (Start + Select on RG35XX-H).
if [ -n "${GPTOKEYB:-}" ]; then
  "$GPTOKEYB" "$GAME" &
  GPTOKEYB_PID=$!
  echo "Started gptokeyb (PID $GPTOKEYB_PID)"
else
  echo "WARNING: GPTOKEYB is not defined by PortMaster control.txt"
fi

# Apply firmware-specific launch settings immediately before starting the game.
if declare -F pm_platform_helper >/dev/null 2>&1; then
  pm_platform_helper "$GAME"
else
  echo "WARNING: pm_platform_helper is unavailable in this PortMaster installation"
fi

set +e
"$GAME" --bios "$BIOS" --rom "$ROM" >> "$LOG" 2>&1
GAME_STATUS=$?
set -e

echo "Game exited with status $GAME_STATUS"
exit "$GAME_STATUS"
