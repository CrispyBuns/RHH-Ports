# MaternalBound Redux — Native ARM64 Port

This is an experimental native C/C++ port target for ARM64 Linux handhelds, including the Anbernic RG35XX-H running KNULLI.

## Runtime files

Expected install layout:

```text
ports/ebredux/
├── MaternalBound Redux.sh
├── earthbound
├── gamedata/
│   └── assets.pak
├── libs/                 # only if the build needs bundled libraries
└── log.txt               # generated at runtime
```

The launcher passes the pack explicitly using `--assets`; it does not expect a `redux.sfc` ROM at runtime. The pack must be generated from a compatible MaternalBound Redux build and is intentionally not included in this repository.

## Status

Early port scaffolding. The ARM64 executable still needs to be built and tested on KNULLI. Renderer/input compatibility, profile selection, audio, save handling, and any required shared libraries must be verified before calling this playable.

## Source and licensing

The native implementation is based on the pinned upstream source and the patches maintained in [CrispyBuns/earthbound-companion](https://github.com/CrispyBuns/earthbound-companion). Review that project's legal and attribution notes before redistributing binaries or source-derived assets.
