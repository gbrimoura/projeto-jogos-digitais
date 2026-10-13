# Snapshot anterior à caminhada V8

Capturado em 12/10/2026, antes de qualquer alteração de walk V8. Os arquivos são cópias byte a byte do runtime local com atlas de 25 quadros: idle 0–5, walk V7 6–13, dash 14–16 e pulo V3 17–24. A pasta preserva os quatro recursos necessários para reproduzir a base e suas referências de importação; scripts de gameplay/visual não fazem parte desta mudança de arte.

- runtime/assets/player/player-animations.png: 1b3b6a8fc75e7c55346b3d2de86c2fa20bb82712a81db5a207962a29ae023f36
- runtime/assets/player/player-animations.png.import: feb38b6ec7b49d4bc2c050e2012a688027825b08a9564a30853e842fbb8c5815
- runtime/assets/player/source/player-animations.aseprite: 74922dd3bc240dd981c807f7866f9e92f4da73c48292b35ad88c3285bfd24d0b
- runtime/resources/player_sprite_frames.tres: ff45afd4124cbff029f564990acd1d12def5945b048c9a775c970cd598dcdc30

Os quadros 0–16 e 17–24 são a entrada imutável para a integração V8. O extrator deve abrir apenas o PNG/Aseprite deste snapshot para preservar os quadros não caminhados, nunca reutilizar a saída runtime já alterada.