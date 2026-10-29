#!/bin/bash
# PORTMASTER: megamanx-recompiled-rg35xx-h.zip, Mega Man X Recompiled.sh

set -u
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

GAMEDIR="/$directory/ports/megamanxrecompiled"
GAME="$GAMEDIR/MegaManXSNESRecomp"
ROMDIR="$GAMEDIR/mmx"
ROMCFG="$GAMEDIR/rom.cfg"
LOGFILE="$GAMEDIR/log.txt"

if ! mkdir -p "$ROMDIR"; then
    pm_show_error "Unable to create the Mega Man X ROM folder."
    pm_finish
    exit 1
fi
if ! cd "$GAMEDIR"; then
    pm_show_error "Mega Man X Recompiled port directory is unavailable."
    pm_finish
    exit 1
fi

# Start a fresh log for every launch and capture launcher and game output.
: > "$LOGFILE"
exec > >(tee -a "$LOGFILE") 2>&1
echo "Mega Man X Recompiled launched: $(date -Is)"
echo "Port directory: $GAMEDIR"

if [ -n "${sdl_controllerconfig:-}" ]; then
    export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
fi
if [ -d "$GAMEDIR/libs" ]; then
    if [ -n "${LD_LIBRARY_PATH:-}" ]; then
        export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
    else
        export LD_LIBRARY_PATH="$GAMEDIR/libs"
    fi
fi

PORTMASTER_FINISHED=0
finish_portmaster() {
    [ "$PORTMASTER_FINISHED" -eq 1 ] && return
    PORTMASTER_FINISHED=1
    pm_finish
}
trap finish_portmaster EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if [ ! -x "$GAME" ]; then
    pm_show_error "Mega Man X Recompiled is missing or not executable. Reinstall the port."
    exit 1
fi

ROM="$ROMDIR/mmx.sfc"
if [ ! -f "$ROM" ]; then
    ROM="$ROMDIR/Mega Man X (USA) (Rev 1).sfc"
fi
if [ ! -f "$ROM" ]; then
    pm_show_error "ROM not found. Copy your own Mega Man X (USA) Rev 1 ROM to $ROMDIR/mmx.sfc. No ROM is included."
    exit 1
fi

# Seed rom.cfg only when it is missing or points to a file that no longer exists.
CACHED_ROM=""
if [ -f "$ROMCFG" ]; then
    CACHED_ROM="$(head -n 1 "$ROMCFG" 2>/dev/null | tr -d '\r\n')"
fi
if [ -z "$CACHED_ROM" ] || [ ! -f "$CACHED_ROM" ]; then
    printf '%s\n' "$ROM" > "$ROMCFG"
fi

echo "Using ROM path: $ROM"
echo "Starting MegaManXSNESRecomp."
pm_platform_helper "$GAME" >/dev/null 2>&1 || true
"$GAME" >> "$LOGFILE" 2>&1
GAME_STATUS=$?
echo "MegaManXSNESRecomp exited with status $GAME_STATUS."
exit "$GAME_STATUS"
