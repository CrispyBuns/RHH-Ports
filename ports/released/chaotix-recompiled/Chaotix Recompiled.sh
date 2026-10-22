#!/bin/bash
# PORTMASTER: chaotix-recompiled.zip, Chaotix Recompiled.sh

# Locate PortMaster.
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

if [ -d "/opt/system/Tools/PortMaster" ]; then
    controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster" ]; then
    controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster" ]; then
    controlfolder="$XDG_DATA_HOME/PortMaster"
else
    controlfolder="/roms/ports/PortMaster"
fi

if [ ! -r "$controlfolder/control.txt" ]; then
    echo "PortMaster control.txt not found: $controlfolder/control.txt" >&2
    exit 1
fi

source "$controlfolder/control.txt"

if [ -f "$controlfolder/mod_${CFW_NAME}.txt" ]; then
    source "$controlfolder/mod_${CFW_NAME}.txt"
fi

get_controls

# RHH-Ports installation paths.
GAMEDIR="/$directory/ports/chaotix-recompiled"
ROMDIR="$GAMEDIR/ROM"
USERDIR="$GAMEDIR/userdata"
GAME="$GAMEDIR/ChaotixRecompiled"
LOGFILE="$GAMEDIR/log.txt"

mkdir -p "$ROMDIR" "$USERDIR" || {
    pm_show_error "Unable to create the ROM or userdata directory."
    pm_finish
    exit 1
}

if [ ! -d "$GAMEDIR" ] || ! cd "$GAMEDIR"; then
    pm_show_error "Chaotix Recompiled port directory is unavailable."
    pm_finish
    exit 1
fi

# Add bundled libraries without introducing an empty path component.
if [ -d "$GAMEDIR/libs" ]; then
    if [ -n "${LD_LIBRARY_PATH:-}" ]; then
        export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
    else
        export LD_LIBRARY_PATH="$GAMEDIR/libs"
    fi
fi

if [ -n "${sdl_controllerconfig:-}" ]; then
    export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
fi

# Forward PortMaster's SDL2 driver choices through SDL3-shim, if supplied.
GAME_SDL_VIDEODRIVER=""
GAME_SDL_AUDIODRIVER=""

if [ -n "${SDL_VIDEODRIVER:-}" ]; then
    export SDL3SHIM_SDL2_VIDEODRIVER="$SDL_VIDEODRIVER"
    GAME_SDL_VIDEODRIVER="sdl2"
fi

if [ -n "${SDL_AUDIODRIVER:-}" ]; then
    export SDL3SHIM_SDL2_AUDIODRIVER="$SDL_AUDIODRIVER"
    GAME_SDL_AUDIODRIVER="sdl2"
fi

run_chaotix() {
    if [ -n "$GAME_SDL_VIDEODRIVER" ] && [ -n "$GAME_SDL_AUDIODRIVER" ]; then
        SDL_VIDEODRIVER="$GAME_SDL_VIDEODRIVER" \
        SDL_AUDIODRIVER="$GAME_SDL_AUDIODRIVER" \
            "$GAME" "$@"
    elif [ -n "$GAME_SDL_VIDEODRIVER" ]; then
        SDL_VIDEODRIVER="$GAME_SDL_VIDEODRIVER" "$GAME" "$@"
    elif [ -n "$GAME_SDL_AUDIODRIVER" ]; then
        SDL_AUDIODRIVER="$GAME_SDL_AUDIODRIVER" "$GAME" "$@"
    else
        "$GAME" "$@"
    fi
}

# Centralized PortMaster cleanup.
GPTOKEYB_PID=""
PORTMASTER_FINISHED=0

finish_portmaster() {
    [ "$PORTMASTER_FINISHED" -eq 1 ] && return
    PORTMASTER_FINISHED=1

    if [ -n "$GPTOKEYB_PID" ]; then
        kill "$GPTOKEYB_PID" 2>/dev/null || true
        wait "$GPTOKEYB_PID" 2>/dev/null || true
        GPTOKEYB_PID=""
    fi

    pm_finish
}

trap finish_portmaster EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if [ ! -x "$GAME" ]; then
    pm_show_error "Chaotix Recompiled is missing or not executable. Reinstall the port."
    exit 1
fi

# The ROM is user-supplied; it is not distributed with this port.
ROM="$ROMDIR/chaotix.32x"

if [ ! -f "$ROM" ]; then
    shopt -s nullglob
    rom_candidates=("$ROMDIR"/*.32x "$ROMDIR"/*.bin)
    shopt -u nullglob

    if [ "${#rom_candidates[@]}" -eq 1 ]; then
        ROM="${rom_candidates[0]}"
    elif [ "${#rom_candidates[@]}" -gt 1 ]; then
        pm_show_error "Multiple ROMs found in $ROMDIR. Keep one .32x or .bin ROM, preferably named chaotix.32x."
        exit 1
    else
        pm_show_error "ROM not found. Place one legally obtained .32x or .bin ROM in $ROMDIR. No ROM is included."
        exit 1
    fi
fi

pm_message "Installing Chaotix ROM..."

if ! run_chaotix --user-dir "$USERDIR" --install "$ROM" >> "$LOGFILE" 2>&1; then
    pm_show_error "ROM installation failed. Verify the supported ROM and check log.txt."
    exit 1
fi

# Start the controller mapper only when both required files are available.
if [ -n "${GPTOKEYB:-}" ] &&
   [ -x "$GPTOKEYB" ] &&
   [ -f "$GAMEDIR/chaotix.gptk" ]; then
    "$GPTOKEYB" "ChaotixRecompiled" -c "$GAMEDIR/chaotix.gptk" &
    GPTOKEYB_PID=$!
fi

pm_platform_helper "$GAME" > /dev/null 2>&1

run_chaotix --user-dir "$USERDIR" >> "$LOGFILE" 2>&1
GAME_STATUS=$?

exit "$GAME_STATUS"
