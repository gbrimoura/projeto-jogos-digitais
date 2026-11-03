# Cospe-Rebite projectile art

Native static projectile sprite, 32x16 pixels, facing right (+X). The intended pivot is (20, 8); runtime placement uses the native image with Sprite2D offset (-4, 0), while its circular gameplay hit area remains radius 6.

The Aseprite Lua generator builds a hand-authored ASCII pixel map using 13 colors from the project-approved palette. Pixels use only full opacity or full transparency. The 8x preview is nearest-neighbor; the contact preview compares the existing rivet worker and projectile at 2x for inspection, not runtime scale.

The generated Godot ImageTexture is packed as RGBA8 from the same map and palette, with no pending PNG import dependency. reference-imagegen.png is the original ImageGen concept, copied intact for provenance. It was used as visual direction only; the native sprite was drawn as original pixel art, not filtered or downsampled from that image.

Reference SHA-256: 1F71E628F071972EC6486E1E3B435A9E9CBB171BFF645ADC9080C65AD2DF7A61.

Palette: #00000D, #192031, #373F4D, #F5E9D8, #CFC3B7, #FFFCF0, #70432C, #925A36, #B37949, #D94B4B, #F0524E, #FF7256, #F5A84F.
The generated art, texture resource, provenance and hashes are indexed in metadata.json.