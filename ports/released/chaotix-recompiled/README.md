# Chaotix Recompiled — RG35XX-H / KNULLI

This is an experimental PortMaster-style package for the Anbernic RG35XX-H running KNULLI. It is registered in RHH-Ports' standard **Build Ports** workflow.

## Build a test package

1. Open the [Build Ports workflow](../../actions/workflows/build_ports.yml) while on branch `chaotix-recompiled-knulli`.
2. Choose **Run workflow**.
3. Set **Which port to consider** to `chaotix-recompiled` (not `all`).
4. Run it and open the completed run. Download the workflow artifact if using **force-build**; otherwise the workflow syncs the build output into this branch's port payload folder.
5. For a force-build test artifact, extract the ZIP and copy the included `Chaotix Recompiled.sh` and `chaotix-recompiled/` folder into `/roms/ports/`.

## ROM

Supply your own legally obtained *Knuckles' Chaotix (Japan, USA)* ROM. The launcher expects:

```
/roms/ports/chaotix-recompiled/ROM/chaotix.32x
```

No ROM or 32X BIOS is bundled. The program validates the ROM and stores its installed copy and saves under `ports/chaotix-recompiled/userdata/`.

## Status

Early test build. The build recipe uses the committed generated source files from the upstream project and does not require a ROM during compilation. Rendering performance, controller mappings, and KNULLI-specific behavior still need device testing.
