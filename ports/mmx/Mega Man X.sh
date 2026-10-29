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

GAMEDIR="/$directory/ports/mmx"
cd "$GAMEDIR" || exit 1

# Always keep the complete launcher/game diagnostic in the port directory.
: > "$GAMEDIR/log.txt"
exec > >(tee -a "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-fbcon}"
export SDL_AUDIODRIVER="${SDL_AUDIODRIVER:-alsa}"
export LD_LIBRARY_PATH="$GAMEDIR/libs:${LD_LIBRARY_PATH:-}"

printf '=== Mega Man X Recompiled ===\n'
printf 'Firmware: %s\n' "${CFW_NAME:-unknown}"
printf 'Architecture: %s\n' "$(uname -m)"
printf 'Kernel: %s\n' "$(uname -sr)"
printf 'SDL_VIDEODRIVER=%s\n' "$SDL_VIDEODRIVER"
printf 'SDL_AUDIODRIVER=%s\n' "$SDL_AUDIODRIVER"
printf 'Game directory: %s\n' "$GAMEDIR"

ROM=""
for candidate in \
    "$GAMEDIR/mmx.sfc" \
    "$GAMEDIR/mmx.smc" \
    "$GAMEDIR/Mega Man X (USA) (Rev 1).sfc" \
    "$GAMEDIR/Mega Man X (USA) (Rev 1).smc"; do
    if [ -f "$candidate" ]; then
        ROM="$candidate"
        break
    fi
done

if [ -z "$ROM" ]; then
    for candidate in "$GAMEDIR/mmx/"*.sfc "$GAMEDIR/mmx/"*.smc; do
        if [ -f "$candidate" ]; then
            ROM="$candidate"
            break
        fi
    done
fi

if [ -z "$ROM" ]; then
    echo "ERROR: No Mega Man X ROM found."
    echo "Place your own Mega Man X (USA) Rev 1 .sfc/.smc ROM in: $GAMEDIR/mmx/"
    pm_show_error "Mega Man X ROM not found in ports/mmx/mmx/"
    pm_finish
    exit 1
fi

printf 'ROM: %s\n' "$ROM"

if [ ! -x "$GAMEDIR/MegaManXSNESRecomp" ]; then
    echo "ERROR: MegaManXSNESRecomp binary is missing."
    pm_show_error "Mega Man X Recompiled binary is missing."
    pm_finish
    exit 1
fi

chmod +x "$GAMEDIR/MegaManXSNESRecomp"
pm_platform_helper "$GAMEDIR/MegaManXSNESRecomp" > /dev/null 2>&1 || true

set +e
"$GAMEDIR/MegaManXSNESRecomp" --no-launcher --rom "$ROM"
STATUS=$?
set -e

echo "Game exited with status: $STATUS"
pm_finish
exit "$STATUS"
