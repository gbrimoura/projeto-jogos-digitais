# Upgrade Cards v1

Pixel-art assets authored with Aseprite 1.3.18.6 in an industrial cartoon style.
The 19-color palette is reread from assets/ui/hud_caldeira_v1/export/palette.json
before each asset. Alpha uses only 0 or 255. Card text uses a local font bundle
that keeps the HUD atlas intact and adds + and > glyphs.

## Integration geometry

- Card frame PNGs are full-frame 160x240 and opaque. Draw the frame, then draw
  the transparent illustration at local x=16, y=34, w=128, h=80.
- Frame states normal/focus/pressed share geometry and do not move text or art.
- Bitmap text zones: title x=8,y=8,w=144; summary x=8,y=121,w=144;
  topics x=20 at y=144/158/172, w=128; badge x=12,y=204,w=136,h=24.
  Recommended topic line limit is 21 glyphs. The card font bundle appends + and >
without changing the original HUD font files.
- Preview canvas is 576x324. Card origins are (36,60), (208,60), (380,60).
  It shows Ricochete de Pressão, Mola de Retorno, and Dínamo de Defesa as
  NOVO. It is a visual study, explicitly not a Godot screenshot.
- Image IDs: impacto_reforcado, motor_acelerado, carga_reativa,
  ricochete_pressao, mola_retorno, dinamo_defesa, chassi_reforcado. Runtime
  definition IDs can map to these names; this art-only front does not impose
  final catalog IDs or effects.

## Files

- export: seven transparent illustration PNGs and three card-frame PNGs.
- source: generation Lua and layered Aseprite sources for each illustration
  and the three frame states.
- preview: native and integer-upscaled studies plus a two-times art contact sheet.
- source and preview have .gdignore files.

This front generated art assets only; it did not run Godot, imports, tests,
audits, parser, linter, or simulations.
## Card bitmap font bundle

Keep the HUD's original font.json and font-atlas.png unchanged. Load the original
font bundle, replace its atlas path with assets/ui/upgrade_cards_v1/export/card-font-atlas.png,
append glyph records from assets/ui/upgrade_cards_v1/export/card-font-additions.json,
and call configure_font(bundle) on the existing HudBitmapText component. Base
glyph coordinates and font metrics remain unchanged; only + and > are appended.
