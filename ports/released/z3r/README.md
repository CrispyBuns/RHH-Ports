# Z3R

Z3R (Zelda 3 Reborn) is a native reimplementation of The Legend of Zelda: A Link to the Past with widescreen and enhanced rendering.

## Required game data

Z3R does not include Nintendo's game ROM or the generated runtime asset archive.

You need your own legally dumped USA copy of **The Legend of Zelda: A Link to the Past**.

On a Linux/macOS/WSL PC with the Z3R source tree, generate the asset archive with:

```bash
python3 -m venv venv
source venv/bin/activate
python -m pip install -r requirements.txt
python assets/restool.py --extract-from-rom
```

This generates `zelda3_assets.dat`. Copy it to:

```text
/roms/ports/z3r/zelda3_assets.dat
```

Do not copy or redistribute the original ROM or generated asset archive with the port.

## Controls

Z3R uses SDL2 gamepad input directly. PortMaster supplies the CFW controller mapping through `SDL_GAMECONTROLLERCONFIG`.

- D-pad: movement
- A/B/X/Y: game buttons
- L/R: shoulder buttons
- Start: Start
- Select: Select
- L2: Z3R settings menu

## Credits

Z3R source: https://github.com/xander-haj/Z3R

PortMaster packaging: CrispyBuns/RHH-Ports
