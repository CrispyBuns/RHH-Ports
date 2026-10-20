# Z3R for RG35XX H / KNULLI

This is an unreleased ARM64 build of [Z3R](https://github.com/CrispyBuns/Z3R) for
KNULLI on the RG35XX H. The build recipe compiles the game executable; it does
not include a ROM or generated game data.

## Prepare the game data on your PC

Use your own legally obtained USA game copy. Apply the A Link to the Past
Retranslation Redux v10.1 IPS patch to a copy of that ROM and follow the Z3R
asset instructions to extract the Redux dialogue and compile
`zelda3_assets.dat` with the `redux` language enabled. Do not upload or
redistribute the ROM, patch-applied ROM, or generated asset pack.

## Install on KNULLI

1. Copy the contents of this package into the device's `/roms/ports/` folder,
   preserving `Z3R.sh` and the `z3r/` directory.
2. Copy your PC-generated `zelda3_assets.dat` into `/roms/ports/z3r/`.
3. Launch Z3R from Ports.

The package includes `zelda3.user.ini`, which selects Redux dialogue, uses a
4:3 fullscreen SDL display, enables autosaves, and sets the RG35XX H gamepad
mapping. Keep your save data in the `z3r/saves/` folder.

If the game reports missing assets, confirm the generated file is named
exactly `zelda3_assets.dat` and is beside `zelda3`.
