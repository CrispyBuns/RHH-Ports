#!/bin/bash
# PORTMASTER: phase-distorter-knulli.zip, Phase Distorter.sh

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

GAMEDIR="/$directory/ports/phase-distorter"
GAME="$GAMEDIR/eb_cpp"
LOGFILE="$GAMEDIR/log.txt"
DEBUGDIR="$GAMEDIR/debug"
mkdir -p "$GAMEDIR" "$DEBUGDIR"

if [ ! -x "$GAME" ]; then
    printf '[%s] ERROR: game binary missing or not executable: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$GAME" > "$LOGFILE"
    pm_show_error "Phase Distorter is missing or not executable. Reinstall the port."
    pm_finish
    exit 1
fi

# Prefer the bundled GL4ES compatibility library, while retaining any
# libraries supplied by PortMaster or the firmware.
if [ -n "${LD_LIBRARY_PATH:-}" ]; then
    export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
else
    export LD_LIBRARY_PATH="$GAMEDIR/libs"
fi
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4

# Start a fresh log for each launch, including environment details and all
# stdout/stderr emitted by the game so failures can be diagnosed on-device.
{
    printf '[%s] Phase Distorter launcher started\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf 'Firmware: %s\n' "${CFW_NAME:-unknown}"
    printf 'Game binary: %s\n' "$GAME"
    printf 'Working directory: %s\n' "$GAMEDIR"
    printf 'Architecture: '
    uname -m 2>&1
    printf 'Kernel: '
    uname -sr 2>&1
    printf 'LIBGL_ES=%s LIBGL_GL=%s LIBGL_FB=%s\n' "$LIBGL_ES" "$LIBGL_GL" "$LIBGL_FB"
    printf '%s\n' '--- game output begins ---'
} > "$LOGFILE" 2>&1

GPTOKEYB_PID=""
finish_portmaster() {
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

if [ -n "${GPTOKEYB:-}" ] && [ -x "$GPTOKEYB" ]; then
    "$GPTOKEYB" "eb_cpp" >> "$LOGFILE" 2>&1 &
    GPTOKEYB_PID=$!
fi
pm_platform_helper "$GAME" >> "$LOGFILE" 2>&1 || true
cd "$GAMEDIR" || {
    printf '[%s] ERROR: could not change to game directory\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOGFILE"
    exit 1
}
"$GAME" >> "$LOGFILE" 2>&1
status=$?
printf '\n[%s] Phase Distorter exited with status %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$status" >> "$LOGFILE"
exit "$status"
