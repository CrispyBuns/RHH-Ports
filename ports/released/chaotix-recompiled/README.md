# Chaotix Recompiled — RG35XX-H / KNULLI

This is an experimental PortMaster package for the Anbernic RG35XX-H running KNULLI.

## Install with PortMaster autoinstall

1. Run the **Build Chaotix Recompiled autoinstall package** workflow on branch `chaotix-recompiled-knulli`.
2. Download the workflow artifact named `chaotix-recompiled-autoinstall`. It contains `chaotix-recompiled.zip`.
3. Copy `chaotix-recompiled.zip` without extracting it to KNULLI's PortMaster autoinstall folder:
   ```
   /userdata/roms/ports/autoinstall/
   ```
4. Put the SD card back in the handheld and launch PortMaster. It will install the port.

The package includes the SDL3-on-SDL2 shim, SDL3_ttf, and SDL3_image shared libraries in `chaotix-recompiled/libs/`. The SDL3 shim uses PortMaster's patched SDL2 runtime for handheld video, audio, and controller input. SDL3_image is built with AVIF disabled, so the build does not require the unavailable `libavif-dev` package.

## ROM

Supply your own legally obtained supported ROM; no ROM or BIOS is bundled. Place one `.32x` or `.bin` ROM in:

```
/userdata/roms/ports/chaotix-recompiled/ROM/
```

The launcher accepts the supported Knuckles' Chaotix ROM or Sonic in Chaotix Revision 2. It validates and installs the ROM on first launch, then stores game data and saves under `chaotix-recompiled/userdata/`.

## Status

This is an early test build. Rendering performance, controller mappings, and KNULLI-specific behavior still need device testing.
