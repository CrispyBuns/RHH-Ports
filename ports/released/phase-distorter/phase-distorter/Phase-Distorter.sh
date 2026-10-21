#!/bin/bash
# PortMaster launcher for Phase Distorter (RG35XX-H / KNULLI)
set -e

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_DATA_HOME

PORT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PORT_DIR"

# GL4ES provides an OpenGL 2.1-compatible interface over GLES2. Use SDL's
# window/context backend; do not force DRM/KMS or a framebuffer backend.
GL4ES_DIR="$PORT_DIR/gl4es.aarch64"
if [ -d "$GL4ES_DIR" ] && [ -f "$GL4ES_DIR/libGL.so.1" ]; then
    export LIBGL_ES=2
    export LIBGL_GL=21
    export SDL_VIDEO_GL_DRIVER="$GL4ES_DIR/libGL.so.1"
    if [ -f "$GL4ES_DIR/libEGL.so.1" ]; then
        export SDL_VIDEO_EGL_DRIVER="$GL4ES_DIR/libEGL.so.1"
    fi
    export LD_LIBRARY_PATH="$GL4ES_DIR:$PORT_DIR/lib:${LD_LIBRARY_PATH:-}"
elif [ -d "$PORT_DIR/lib" ]; then
    export LD_LIBRARY_PATH="$PORT_DIR/lib:${LD_LIBRARY_PATH:-}"
fi

PD="$PORT_DIR/Phase-Distorter"
if [ ! -x "$PD" ]; then
    echo "Phase Distorter executable is missing."
    read -r -p "Press Enter to exit..."
    exit 1
fi

# Keep the user's own EarthBound ROM in the port's Rom/ folder. This folder is
# intentionally shipped empty; ROM files are not included in the installer.
ASSET_PACK="$XDG_DATA_HOME/ebsrc/EarthBoundCpp/earthbound.ebpak"
if [ ! -s "$ASSET_PACK" ]; then
    ROM=""
    if [ -d "$PORT_DIR/Rom" ]; then
        ROM="$(find "$PORT_DIR/Rom" -type f \( \
            -iname '*earthbound*.sfc' -o -iname '*earthbound*.smc' -o \
            -iname '*earth-bound*.sfc' -o -iname '*earth-bound*.smc' -o \
            -iname 'eb.sfc' -o -iname 'eb.smc' -o \
            -iname '*.sfc' -o -iname '*.smc' \
            \) ! -iname '*.gz' -print -quit 2>/dev/null || true)"
    fi

    if [ -n "$ROM" ]; then
        echo "Found EarthBound ROM in Rom/: $ROM"
        echo "Importing assets for Phase Distorter..."
        if ! "$PD" --import-rom "$ROM" --import-only; then
            echo "ROM import failed. Make sure Rom/ contains a supported US EarthBound ROM."
            read -r -p "Press Enter to exit..."
            exit 1
        fi
    else
        echo "No ROM found in $PORT_DIR/Rom/"
        echo "Copy your own supported US EarthBound ROM into the Rom/ folder, then launch again."
        read -r -p "Press Enter to continue..."
    fi
fi

exec "$PD" "$@"
