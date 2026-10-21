#!/bin/bash
# PortMaster launcher for Phase Distorter (RG35XX-H / KNULLI)
set -e

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_DATA_HOME

PORT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PORT_DIR"

# GL4ES exposes an OpenGL 2.1-compatible interface and translates it to GLES 2.
# Prefer the bundled aarch64 runtime; KNULLI/PortMaster ports commonly package
# this as gl4es.aarch64/. Do not override an existing system setup if absent.
GL4ES_DIR="$PORT_DIR/gl4es.aarch64"
if [ -d "$GL4ES_DIR" ] && [ -f "$GL4ES_DIR/libGL.so.1" ]; then
    export LIBGL_ES=2
    export LIBGL_GL=21
    export LIBGL_FB=4
    export SDL_VIDEO_GL_DRIVER="$GL4ES_DIR/libGL.so.1"
    if [ -f "$GL4ES_DIR/libEGL.so.1" ]; then
        export SDL_VIDEO_EGL_DRIVER="$GL4ES_DIR/libEGL.so.1"
    fi
    export LD_LIBRARY_PATH="$GL4ES_DIR:$PORT_DIR/lib:${LD_LIBRARY_PATH:-}"
elif [ -d "$PORT_DIR/lib" ]; then
    export LD_LIBRARY_PATH="$PORT_DIR/lib:${LD_LIBRARY_PATH:-}"
fi

if [ ! -x "$PORT_DIR/Phase-Distorter" ]; then
    echo "Phase Distorter executable is missing."
    read -r -p "Press Enter to exit..."
    exit 1
fi

exec "$PORT_DIR/Phase-Distorter" "$@"
