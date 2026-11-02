#!/bin/bash
# Mega Man X Recompiled - RG35XX-H / KNULLI
# Keep startup logging active even if PortMaster setup fails.

set -eo pipefail

BOOT_LOG="/roms/ports/megamanx-snes-recomp/boot.log"
mkdir -p "$(dirname "$BOOT_LOG")"
exec > >(tee -a "$BOOT_LOG") 2>&1

echo "=== MMX launcher starting: $(date) ==="
echo "Launcher: $0"
echo "Architecture: $(uname -m)"
echo "Kernel: $(uname -sr)"

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

echo "PortMaster folder: $controlfolder"
if [ ! -r "$controlfolder/control.txt" ]; then
    echo "ERROR: PortMaster control.txt not found: $controlfolder/control.txt"
    exit 1
fi

# Load PortMaster environment without nounset: control.txt may reference
# firmware-specific variables that are not present on every installation.
source "$controlfolder/control.txt"
if [ -f "${controlfolder}/mod_${CFW_NAME:-}.txt" ]; then
    source "${controlfolder}/mod_${CFW_NAME}.txt"
fi

if ! declare -F get_controls >/dev/null; then
    echo "ERROR: get_controls was not provided by PortMaster control.txt"
    exit 1
fi
get_controls

GAMEDIR="/${directory}/ports/megamanx-snes-recomp"
GAME="$GAMEDIR/MegaManXSNESRecomp"
LOG="$GAMEDIR/log.txt"

mkdir -p "$GAMEDIR/userdata" "$GAMEDIR/pgo"
exec > >(tee -a "$BOOT_LOG" "$LOG") 2>&1
echo "Game directory: $GAMEDIR"
echo "Game log: $LOG"
echo "Firmware: ${CFW_NAME:-unknown}"

if ! declare -F pm_finish >/dev/null; then
    echo "WARNING: pm_finish is unavailable; continuing without PortMaster exit hook"
else
    trap pm_finish EXIT
fi

if [ ! -x "$GAME" ]; then
    echo "ERROR: executable missing or not executable: $GAME"
    if declare -F pm_show_error >/dev/null; then
        pm_show_error "Mega Man X Recompiled executable is missing. Reinstall the port."
    fi
    exit 1
fi

if [ -d "$GAMEDIR/libs" ]; then
    export LD_LIBRARY_PATH="$GAMEDIR/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

export SDL_RENDER_DRIVER=opengles2
if [ -n "${sdl_controllerconfig:-}" ]; then
    export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
fi

echo "Setting up PortMaster platform..."
if declare -F pm_platform_helper >/dev/null; then
    pm_platform_helper "$GAME" || echo "WARNING: pm_platform_helper returned non-zero"
fi

# GPTOKEYB is optional at launch: never let a missing variable prevent the game
# from starting. Prefer PortMaster's exported path, then PATH lookup.
GPTOKEYB_BIN="${GPTOKEYB:-}"
if [ -z "$GPTOKEYB_BIN" ]; then
    GPTOKEYB_BIN="$(command -v gptokeyb || true)"
fi

if [ -n "$GPTOKEYB_BIN" ] && [ -x "$GPTOKEYB_BIN" ]; then
    echo "Starting GPTOKEYB: $GPTOKEYB_BIN"
    "$GPTOKEYB_BIN" "$GAME" &
    GPTOKEYB_PID=$!
    echo "GPTOKEYB PID: $GPTOKEYB_PID"
else
    echo "WARNING: GPTOKEYB not found; launching with native SDL controls only"
fi

echo "Launching game..."
set +e
"$GAME"
GAME_STATUS=$?
set -e
echo "Game exited with status: $GAME_STATUS"
exit "$GAME_STATUS"
