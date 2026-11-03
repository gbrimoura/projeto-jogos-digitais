# Upgrade Cards v1

Seven cartoon upgrade illustrations and their 128×80 transparent PNGs remain unchanged. The normal/focus/pressed card frames keep their 160×240 geometry; the three isolated copper squares beside the topic rows were removed from all states. The editable three-frame Aseprite source remains the source of those frames.

## Integration geometry

- The illustration stays at local x=16, y=34, w=128, h=80.
- Titles, summaries, the two-line rank footer, card size, frame borders, separators, and local bitmap font keep their existing layout.
- Each effect is a topic prefixed by a cyan dash. Continuation lines indent by two spaces, with 22 content glyphs plus the two-column prefix, up to three rows total.
- Topic text uses the existing local bitmap font. Labels and current comparison values are gray, the dash is cyan, and nominal gains/new comparison values are amber.
- The summary backdrop stays opaque. A flat navy layer sits under topic rows (local y=143..187) and before the text, covering leftover decorative markers while leaving the divider at y=188 visible.
- A row of faceted pixel prisms sits above the footer: exactly 3, 5 or 10 prisms for those actual rank caps, acquired ranks in cyan, the next offered rank in amber, and empty slots in metal outline. Other caps have no prism row; recovery never uses its accounting cap as prism levels. The two-line text footer shows NOVO or EVOLUIR, adding - MÁXIMO at the offered cap, followed by NÍVEL atual > próximo / máximo.
- The core study shows Carga 0→1/3, Mola 1→2/3 (2.4→2.6 s), and Dínamo 2→3/3 (0.10→0.15 s), including their prism rows, at native and 3× sizes. The complementary post-build study shows exact caps 10 and 5 plus recovery without prisms. These are visual studies, not Godot screenshots.


## Files

- `export`: seven transparent illustration PNGs, three 160×240 frame PNGs, local card font assets, and the manifest.
- `source`: canonical Aseprite Lua generator and editable artwork/frame sources. `preview_only=true` reuses the seven existing icons without exporting them and can regenerate the four paired core and post-build study previews. Only the explicit `clean_frames=true` combination edits the three isolated topic markers in the frame source and refreshes the frame PNGs.
- `preview`: the core and post-build three-card studies at native and integer 3× sizes, plus the unchanged seven-icon contact sheets.
- Card text continues to use the local card font atlas and additions; HUD font sources are unchanged.

No Godot, import, test, parser, linter, audit, render audit, or simulation was run.