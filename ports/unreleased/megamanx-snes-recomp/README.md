# Mega Man X Recompiled — RG35XX-H Port Notes

## Controller-driven ImGui interface

The project's ImGui-based runtime/launcher UI supports physical gamepad navigation. It uses the SDL2 ImGui backend's gamepad input path; gamepad navigation is armed by the upstream UI after a real controller event is received.

For the RG35XX-H / KNULLI port:

- Keep the PortMaster-provided `SDL_GAMECONTROLLERCONFIG` mapping exported by the launcher.
- Keep SDL2 controller events available to the application.
- Do not make a mouse or touchscreen the only way to navigate ImGui menus.
- Preserve the upstream ImGui gamepad-navigation behavior rather than adding an independent, conflicting button map.
- Do not assume universal A/B button labels: the effective face-button layout depends on the SDL controller mapping and upstream UI actions.

This is a porting requirement, not a claim that every menu action has been independently tested on the RG35XX-H. Verify navigation on-device after the first successful build.

## Automatic password save and restore

The ARM64 build uses the upstream `megaman-x.enhancement.password-save` mod from the
`CrispyBuns/MegaManXSNESRecomp-ARM64` source branch. The build's CMake integration
compiles the plugin and applies the generated-code password hooks; the RHH-Ports
workflow copies the preloaded mod catalog into the install package.

The mod is enabled by default for the supported USA Rev 1 game:

- When the game displays a newly generated twelve-digit password after a stage
  or game over, the mod stores it in `mmx-password.srm` beside the executable.
- On a later launch, opening **Password** on the title screen automatically
  fills the last saved password. Confirm it normally in the game.
- You can still edit the digits manually. Manual entry does not overwrite the
  remembered password.
- A previous password file is retained as `mmx-password.srm.bak` when a new
  password is written.
- The file is a small host-side password record, not emulator SRAM or a save
  state. The mod does not alter the ROM or the game's password validation.
- The mod stays inactive during netplay.

No extra ROM patch or separate install step is required. The feature is included
in the normal auto-install ZIP. See the source project's
[`docs/password-saves.md`](https://github.com/CrispyBuns/MegaManXSNESRecomp-ARM64/blob/sdl-opengles2/docs/password-saves.md)
for implementation details and validation notes.

The save hooks have upstream focused unit-test and Windows runtime validation,
but the full ARM64 PortMaster package and RG35XX-H behavior still need a
successful build and on-device test.
