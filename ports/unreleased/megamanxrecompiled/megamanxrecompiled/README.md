# Mega Man X Recompiled for PortMaster

This experimental package targets 64-bit ARM handhelds such as the RG35XX-H.
It uses the project's SDL2 compatibility backend and PortMaster's SDL2
runtime.

The autoinstall archive does not include game ROMs. Copy your own
Mega Man X (USA) (Rev 1) ROM into the mmx folder as mmx.sfc. The launcher
creates rom.cfg on first run and keeps a valid ROM selection unchanged.

Optional Mega Man X2 and X3 ROMs can be selected from the game's Mods screen.
They are not required for the base game and are not included in the archive.

Each launch writes the launcher and game output to log.txt beside the
executable.
