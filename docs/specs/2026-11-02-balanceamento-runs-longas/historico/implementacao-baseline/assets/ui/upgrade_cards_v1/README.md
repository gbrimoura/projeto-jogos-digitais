# Upgrade Cards v1

Seven cartoon upgrade illustrations and their 128×80 transparent PNGs remain unchanged. The normal/focus/pressed card frames keep their 160×240 geometry; the three isolated copper squares beside the topic rows were removed from all states. The editable three-frame Aseprite source remains the source of those frames.

## Integration geometry

- The illustration stays at local x=16, y=34, w=128, h=80.
- Titles, summaries, the two-line rank footer, card size, frame borders, separators, and local bitmap font keep their existing layout.
- Each effect is a topic prefixed by a cyan dash. Continuation lines indent by two spaces, with 22 content glyphs plus the two-column prefix, up to three rows total.
- Topic text uses the existing local bitmap font. Labels and current comparison values are gray, the dash is cyan, and nominal gains/new comparison values are amber.
- The summary backdrop stays opaque; topic rows have no square or backdrop.
- The footer shows NOVO or EVOLUIR, adding - MÁXIMO at the offered cap, followed by NÍVEL atual > próximo / máximo. The status is cyan or amber at cap; the current and maximum ranks are gray, and the offered rank is amber.
- The study preview shows Carga 0→1/220, Mola 1→2/3, and Dínamo 2→3/3 with the same footer hierarchy. It is a visual study, not a Godot screenshot.

## Files

- `export`: seven transparent illustration PNGs, three 160×240 frame PNGs, local card font assets, and the manifest.
- `source`: canonical Aseprite Lua generator and editable artwork/frame sources. `preview_only=true` reuses the seven existing icons without exporting them and can regenerate only the two study previews. Only the explicit `clean_frames=true` combination edits the three isolated topic markers in the frame source and refreshes the frame PNGs.
- `preview`: the three-card study at native size and integer 3×, plus the unchanged seven-icon contact sheets.
- Card text continues to use the local card font atlas and additions; HUD font sources are unchanged.

No Godot, import, test, parser, linter, audit, render audit, or simulation was run.