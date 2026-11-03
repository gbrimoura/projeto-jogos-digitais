# First-floor factory backgrounds

The production background is assembled in `scenes/main.tscn` from one of two 576×324 wall bases, one of two complete left-side machinery modules, and one of two complete right-side modules. The 2× nearest-neighbor render fills the fixed 1152×648 room. The three independent choices yield eight visual combinations while preserving the room’s existing layout and gameplay.

The anonymous visual script reads only `get_prepared_room_layout_seed()` at runtime in both `scenes/main.tscn` and `scenes/second_room.tscn`. Seed bit 0 selects the wall base, bit 1 selects the left module, and bit 2 selects the right module. This is a deterministic cosmetic mapping; combinations can repeat, and it does not change or consume RNG from the room generator. The editor uses exported fallback variants without calling the room script; `second_room.tscn` keeps the maintenance base, cabinets, and press as its fallback, also used if the getter is unavailable.

Production sources and previews:

- `background_floor1.lua` is the reproducible Aseprite source. It also retains the approved full V2 compositions as visual studies.
- `modular/factory-floor1-bases.aseprite` and `modular/factory-floor1-modules.aseprite` contain editable Aseprite layers.
- `modular/factory-floor1-bases-atlas.png` contains the two opaque 576×324 bases stacked vertically. `modular/factory-floor1-modules-atlas.png` contains the compact transparent module regions; exact atlas rectangles and room anchors are in `modular/regions-and-anchors.json`.
- The native ImageTexture and AtlasTexture resources under `resources/environment/factory_floor1_*` feed the scene script directly, without pending PNG import.
- `modular/factory-floor1-procedural-contact.png` and `modular/context-seed-*.png` are static hierarchy previews. Their sample player/platform arrangement is illustrative only, not a runtime capture or a promise about procedural gameplay. `modular/context-captions.txt` maps the contact quadrants.
- The original ImageGen reference is retained intact as `reference-imagegen.png`. Earlier approved V1 and full V2 source/art are preserved under `variants/v1/` and `variants/v2-complete/`; the earlier contact layout is preserved under `variants/modular-contact-before-base-fix/`.

The artwork uses the 17 local colors locked in the spec, with fully opaque base pixels and binary transparency on modules. This is a local production palette, not the GDD’s final palette. The Notion GDD direction is industrial maintenance, steam, rust, restrained amber, propaganda, and 1930s–40s noir; final typography and slogans remain pending.

No physics, platforms, doors, actors, HUD, progression, or room-generation code is part of these background assets.