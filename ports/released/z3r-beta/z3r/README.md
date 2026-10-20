# Z3R-Beta for RG35XXX-H / KNULLI

This ARM64 build of [Z3R-Beta](https://github.com/CrispyBuns/Z3R-Beta) is set up for KNULLI on the RG35XXX-H. The build recipe compiles the game executable; it does not include a ROM or generated game data.

## Prepare the game data on your PC

Use your own legally obtained USA game copy. Apply the A Link to the Past Retranslation Redux v10.1 IPS patch to a copy of that ROM and follow the Z3R-Beta asset instructions to extract the Redux dialogue and compile `zelda3_assets.dat` with the `redux` language enabled. Do not upload or redistribute the ROM, patch-applied ROM, or generated asset pack.

## Install on KNULLI

1. Copy the contents of this package into the device's `/roms/ports/` folder, preserving `Z3R-Beta.sh` and the `z3r-beta/` directory.
2. Copy your PC-generated `zelda3_assets.dat` into `/roms/ports/z3r-beta/`.
3. Launch Z3R-Beta from Ports.

The package includes `zelda3.user.ini`, which selects Redux dialogue, uses a 4:3 fullscreen SDL display, enables autosaves, and sets the RG35XXX-H gamepad mapping. Keep your save data in `z3r-beta/saves/`.

If the game reports missing assets, confirm the generated file is named exactly `zelda3_assets.dat` and is beside `zelda3`.
