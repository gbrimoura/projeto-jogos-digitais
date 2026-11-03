# Upgrade Cards v1

Seven upgrade illustrations authored with Aseprite 1.3.18.6 in the locked
industrial HUD palette. Each illustration is drawn on a 64x40 pixel canvas and
exported at integer scale 2 to the existing transparent 128x80 asset. Each icon
uses at most six palette colors, large flat shapes, and one clear signal.

## Integration geometry

- Card frames remain opaque 160x240 PNGs. The transparent illustration stays at
  local x=16, y=34, w=128, h=80.
- Frame states normal/focus/pressed keep their existing geometry and artwork.
- Bitmap text zones and the local card font remain unchanged. The runtime shows
  the upgrade description in Summary and up to three wrapped topic lines.
- The study preview shows Carga Reativa, Mola de Retorno, and Dínamo de Defesa
  with their descriptions and gain topics. It is a visual study, not a Godot
  screenshot.

## Files

- export: seven transparent illustration PNGs, three unchanged card-frame PNGs,
  and the manifest.
- source: generate_upgrade_cards.lua is the canonical art-only generator;
  it creates the seven layered Aseprite sources and their PNG exports, then
  refreshes the two previews. It reuses the existing frame PNGs and card font.
- preview: the three-card study at native size and integer 3x, plus a seven-icon
  contact sheet at native size and integer 2x.
- Card text continues to use the local card font atlas and additions; HUD font
  sources are unchanged.

The generator does not produce frame or font assets. This change did not run
Godot, imports, tests, audits, parser, linter, or simulations.
