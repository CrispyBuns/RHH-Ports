# Chaotix Recompiled PGO profile data

This folder is the handoff location for GCC `.gcda` files collected by the instrumented PortMaster build.

## Workflow

1. Run the GitHub Actions workflow with `pgo_mode: profile-generate` and install its `chaotix-recompiled-autoinstall` artifact on the RG35XX-H.
2. Play representative gameplay, especially the Special Stage slowdown, then exit using START + SELECT and allow the port to shut down cleanly.
3. Copy the generated `.gcda` files from the installed port's `debug/` directory into this repository folder, preserving the directory structure and filenames. Do not copy only `BUILD_MODE.txt` or this README.
4. Commit the collected profile files to this branch.
5. Run the workflow with `pgo_mode: profile-use`. It checks that `.gcda` data exists and builds with LTO + profile-use flags.

The profiling and final builds must use the same Chaotix source revision and compatible compiler/build paths. If GCC reports missing or mismatched profile data, recollect using the current source and regenerate the final build. Do not ship the instrumented profile-generate binary as the normal release build.
