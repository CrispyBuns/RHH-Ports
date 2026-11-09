## Information

This port follows the Ship of Harkinian PortMaster layout and build/package structure used by [JeodC's RHH-Ports](https://github.com/JeodC/RHH-Ports), but builds [Arrenton/Shipwright](https://github.com/Arrenton/Shipwright/tree/leveled-ackbar) from the `leveled-ackbar` branch.

The renderer is built with `-DUSE_OPENGLES=1`. In this fork's pinned libultraship submodule, that option explicitly enables **OpenGL ES 3 (GLES3)** and GLSL ES 3.00 shaders. SDL2 and the GLES/EGL driver are supplied by the device.

## Installation

Generate your own `oot.o2r` manually from a legally obtained, supported Ocarina of Time ROM using the Ackbar fork's asset extraction process. Copy the resulting file to:

```
/roms/ports/soh/oot.o2r
```

If you also generate Master Quest, place `oot-mq.o2r` alongside it. The port build does **not** generate, download, or package either ROM-derived archive.

The build does generate Ship's separate `soh.o2r` runtime asset archive. That file is not a replacement for `oot.o2r`.

Mods and texture packs can be installed separately in:

```
/roms/ports/soh/mods/
```

Logs are recorded automatically as `ports/soh/log.txt`. Please provide the log if you report an issue. HarbourMasters is not affiliated with PortMaster or RHH-Ports and this distribution is not officially supported by them.

## Runtime libraries

The build recursively checks the ELF dependency chain and packages required non-system libraries in `ports/soh/libs`. SDL2 and the GLES/EGL driver libraries are supplied by the device firmware and are intentionally not bundled, avoiding conflicts with device-specific SDL2 builds. SDL2_net and the other required non-system dependencies are staged with the port.

## Menu Navigation

Ship of Harkinian has built-in controller navigation for the imgui menu. Press `SELECT` to open the menu and use the `D-PAD` to choose a submenu, then press `A` to switch focus to it. Press `B` to back out of a submenu.

## Default Gameplay Controls

The port uses SDL controller mapping and controls can be remapped from the imgui menu. For devices without a right analog stick, the GPTK file allows for the `HOTKEY + ABXY` button combo to use the C-Buttons.

## Mods

You can find mods at [GameBanana](https://gamebanana.com/mods/games/16121). Install compatible mod archives in the `mods` folder shown above.

## Anchor

This version includes Anchor support. You can modify your name and room id in the launch script, then connect to Anchor from the imgui menu.

## Thanks

Nintendo for the game  
Harbour Masters for the native PC port  
Arrenton for the Ackbar fork  
Jeod and the RHH-Ports contributors for the PortMaster packaging and runtime-library approach
