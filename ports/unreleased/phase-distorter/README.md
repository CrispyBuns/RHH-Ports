# Phase Distorter — RG35XX-H / KNULLI test build

This experimental PortMaster package is built on Ubuntu 24.04 ARM64 for the Anbernic RG35XX-H's Cortex-A53 CPU.

## Build and optimization

- AArch64 / ARMv8-A baseline, safe for the RG35XX-H Cortex-A53.
- `-mtune=cortex-a53` tunes scheduling for the handheld CPU.
- Release `-O3`, link-time optimization (LTO), function/data sections and linker garbage collection.
- Four-way parallel build to fit the GitHub ARM runner.

The workflow builds GL4ES from upstream source and bundles `libGL.so.1`. The launcher sets GL4ES to GLES 2 with OpenGL 2.1 compatibility and uses the PortMaster controller mapper when available.

## Test

1. Open the **Actions** tab in this repository.
2. Select **Build Phase Distorter RG35XX-H KNULLI autoinstall**.
3. Select **Run workflow** on branch `phase-distorter-autoinstall`.
4. Download the `phase-distorter-knulli-autoinstall` artifact from the completed run.
5. Extract the ZIP onto the SD card's `roms/ports` directory or use PortMaster's local install option.
6. Launch **Phase Distorter** and import your own supported US EarthBound or Japanese Mother 2 ROM.

No ROM or imported asset pack is included. This is an initial test build, not a claim of verified gameplay compatibility. Check `/roms/ports/phase-distorter/log.txt` after a crash.
