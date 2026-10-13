# Snapshot de runtime anterior à correção dos ombros V3

Capturado em 12/10/2026 imediatamente antes de integrar o patch dos ombros da caminhada V8. Este é o runtime V8 V2 corrente, com atlas de 25 quadros de 64×64 (1600×64): idle 0–5, caminhada V8 V2 6–13, dash 14–16 e pulo V3 17–24. Ele preserva as pernas e botas da caminhada V8 já integradas e não deve ser confundido com o snapshot anterior à caminhada V8 em ../pre-walk-v8/.

O snapshot contém cópias byte a byte dos quatro arquivos de runtime necessários para reproduzir a integração e sua configuração:

- runtime/assets/player/player-animations.png — SHA-256 7D790057DE1C01873ACBB44E658596D0198A0CC09593081C68F7DAF6748DA8C5
- runtime/assets/player/player-animations.png.import — SHA-256 FEB38B6EC7B49D4BC2C050E2012A688027825B08A9564A30853E842FBB8C5815
- runtime/assets/player/source/player-animations.aseprite — SHA-256 9E8E40979DFE7C9D2879DBD6BE3D3E572F165C6F858F6383F85B98395F5A1C9B
- runtime/resources/player_sprite_frames.tres — SHA-256 FF45AFD4124CBFF029F564990ACD1D12DEF5945B048C9A775C970CD598DCDC30

O patch integrado alterou somente os pixels dos ombros nos quadros 6–13 do atlas e na camada da cabeça da fonte editável. O PNG de configuração .import e o recurso SpriteFrames permanecem iguais aos hashes acima. Nenhum script ou cena de gameplay faz parte desta correção.
