# First-floor factory backgrounds

The production background is assembled in `scenes/main.tscn` from one of two 576×324 wall bases, one of two complete left-side machinery modules, and one of two complete right-side modules. The 2× nearest-neighbor render fills the fixed 1152×648 room. The three independent choices yield eight visual combinations while preserving the room’s existing layout and gameplay.

The anonymous visual script reads only `get_prepared_room_layout_seed()` at runtime in both `scenes/main.tscn` and `scenes/second_room.tscn`. Seed bit 0 selects the wall base, bit 1 selects the left module, and bit 2 selects the right module. This is a deterministic cosmetic mapping; combinations can repeat, and it does not change or consume RNG from the room generator. The editor uses exported fallback variants without calling the room script; `second_room.tscn` keeps the maintenance base, cabinets, and press as its fallback, also used if the getter is unavailable.

Production sources and previews:

- `background_floor1.lua` is the reproducible Aseprite source. It also retains the approved full V2 compositions as visual studies.
- `modular/factory-floor1-bases.aseprite` and `modular/factory-floor1-modules.aseprite` contain editable Aseprite layers.
- `modular/factory-floor1-bases-atlas.png` contains the two opaque 576×324 bases stacked vertically. `modular/factory-floor1-modules-atlas.png` contains the compact transparent module regions; exact atlas rectangles and room anchors are in `modular/regions-and-anchors.json`.
- The native ImageTexture and AtlasTexture resources under `resources/environment/factory_floor1_*` feed the scene script directly, without pending PNG import.
- `modular/factory-floor1-procedural-contact.png` is a 4×2 contact sheet of all eight base/left/right combinations; `modular/context-seed-*.png` contains one 1152×648 static context per seed. The sample platforms and character show hierarchy only, not a runtime capture or procedural gameplay promise. `modular/context-captions.txt` maps each cell to its seed and variants.
Re-run from the repository root with Aseprite batch mode. Pass each --script-param before --script because Aseprite executes the script when it encounters --script: Aseprite.exe -b --script-param "root=<repo>" --script-param "mode=bases-only" --script "assets/environment/factory_v1/background_floor1/background_floor1.lua". The bases-only mode refreshes both bases, the base atlas, its native texture resource, metadata, and all eight static contexts while reading existing modules. The default full mode rebuilds the studies and modular assets, then regenerates those same eight contexts.

- The original ImageGen reference is retained intact as `reference-imagegen.png`. Earlier approved V1 and full V2 source/art are preserved under `variants/v1/` and `variants/v2-complete/`; the earlier contact layout is preserved under `variants/modular-contact-before-base-fix/`.

Both wall bases reserve the same recessed window bay at native position (344,56), with a clear 38x78 glass opening. In boiler base variant 1, the distant architectural column formerly at x=354 is moved to x=420, away from the glass; all eight module combinations leave the window unobstructed.

The artwork uses the 17 local colors locked in the spec, with fully opaque base pixels and binary transparency on modules. This is a local production palette, not the GDD’s final palette. The Notion GDD direction is industrial maintenance, steam, rust, restrained amber, propaganda, and 1930s–40s noir; final typography and slogans remain pending.

No physics, platforms, doors, actors, HUD, progression, or room-generation code is part of these background assets.