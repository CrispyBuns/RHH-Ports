## Information
This port is built from [Arrenton/Shipwright](https://github.com/Arrenton/Shipwright/tree/leveled-ackbar), branch `leveled-ackbar` (Ackbar fork), rather than upstream HarbourMasters/Shipwright.

The build keeps the same PortMaster layout and runtime dependency staging used by Jeod's Ship of Harkinian port. It is compiled with `USE_OPENGLES=1` for the OpenGL ES renderer.

## Installation
Generate your own `oot.o2r` from a legally obtained, supported Ocarina of Time ROM using this fork's asset extraction process. Copy the generated file to:

```
/roms/ports/soh/oot.o2r
```

If you also generate Master Quest, copy `oot-mq.o2r` into the same folder. These ROM-derived archives are user-provided and are not included in the port download.

Alternatively, you can place supported raw `.z64`, `.n64`, or `.v64` ROM files in `ports/soh/baseroms`; the launcher temporarily stages them so SoH can generate the O2R archive on first run.

Texture pack files and mods can be added to `ports/soh/mods`.

Logs are recorded automatically as `ports/soh/log.txt`. Please provide a log if you report an issue. HarbourMasters is not affiliated with PortMaster or RHH-Ports and this distribution is not officially supported by them.

## Runtime libraries
The build recursively checks the ELF dependency chain and packages required non-system libraries in `ports/soh/libs`. SDL2 and the OpenGL ES/EGL driver libraries are supplied by the device firmware and are intentionally not bundled, avoiding conflicts with device-specific SDL2 builds. SDL2_net and the other required non-system dependencies are staged with the port.

## Menu Navigation
Ship of Harkinian has built-in controller navigation for the imgui menu. Press `SELECT` to open the menu and use the `D-PAD` to choose a submenu, then press `A` to switch focus to it. Press `B` to back out of a submenu.

## Default Gameplay Controls
The port uses SDL controller mapping and controls can be remapped from the imgui menu. For devices without a right analog stick, the GPTK file allows for the `HOTKEY + ABXY` button combo to use the C-Buttons.

## Mods
You can find mods at [GameBanana](https://gamebanana.com/mods/games/16121).

## Anchor
This version includes Anchor support. You can modify your name and room id in the launch script, then connect to Anchor from the imgui menu.

## Thanks
Nintendo for the game  
Harbour Masters for the native PC port  
Arrenton for the Ackbar fork  
Jeod and the RHH-Ports contributors for the PortMaster packaging and runtime-library approach
