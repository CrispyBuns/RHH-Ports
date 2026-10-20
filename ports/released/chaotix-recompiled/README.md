# Chaotix Recompiled — RG35XX-H / KNULLI

This is an experimental PortMaster-style package for the Anbernic RG35XX-H running KNULLI.

## Build a test package

1. Open the [Build Chaotix Recompiled (KNULLI) workflow](../../actions/workflows/build-chaotix-recompiled-knulli.yml).
2. Choose **Run workflow** on branch `chaotix-recompiled-knulli`.
3. Download the `chaotix-recompiled-knulli-aarch64` artifact from the completed run.
4. Extract the ZIP and copy `ports/Chaotix Recompiled.sh` and `ports/chaotix-recompiled/` to `/roms/ports/` on the SD card.

## ROM

Supply your own legally obtained *Knuckles' Chaotix (Japan, USA)* ROM. The launcher expects:

```
/roms/ports/ROM/chaotix.32x
```

No ROM or 32X BIOS is bundled. The program validates the ROM and stores its installed copy and saves under `ports/chaotix-recompiled/userdata/`.

## Status

Early test build. The upstream project and committed generated source files are used as the build input. The build workflow does not need the ROM, but the game needs a supported ROM at runtime. Rendering performance, controller mappings, and KNULLI-specific behavior still need device testing.
