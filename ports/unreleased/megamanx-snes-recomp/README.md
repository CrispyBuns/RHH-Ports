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
