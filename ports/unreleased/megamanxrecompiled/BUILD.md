# Build the RG35XX-H PortMaster autoinstall ZIP

The manually started workflow builds the game and PortMaster ZIP on an ARM64
runner, inside an Ubuntu 20.04 ARM64 container. The game is compiled against
SDL2. GitHub's hosted runner label is ubuntu-24.04-arm; the job container
provides the Ubuntu 20.04 build environment.

The full source regeneration needs the Mega Man X (USA) (Rev 1) ROM. Keep ROMs
in a separate private GitHub repository with this layout:

    mmx/Mega Man X (USA) (Rev 1).sfc
    mmx/Mega Man X3 (USA).sfc

In the RHH-Ports repository settings, add:

- Actions variable MMX_ROM_REPO with the private repository name in
  owner/repository form.
- Actions secret MMX_ROM_REPO_TOKEN with a fine-grained token that can read
  that private repository's contents.

The workflow uses the Mega Man X ROM to regenerate and compile the game. The
X3 ROM is optional at runtime and is not needed to compile. Neither ROM is
copied into the autoinstall ZIP. The ZIP includes an mmx folder with this
instruction file; after installation, copy your own game ROM to
ports/megamanxrecompiled/mmx/mmx.sfc.

The output is a downloadable workflow artifact. Copy that ZIP to
PortMaster/autoinstall on the handheld and install it with PortMaster.

GitHub only offers manual dispatch for a workflow present on the default
branch. After this branch is reviewed and merged, choose the workflow in
Actions and run it manually.
