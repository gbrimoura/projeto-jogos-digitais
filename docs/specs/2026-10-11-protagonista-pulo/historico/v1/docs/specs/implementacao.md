# Implementação — pulo do protagonista

GPT-6 Luna xhigh; a interface não permitiu selecionar ou confirmar Fast/priority. O contact refinado foi inspecionado e aprovado pelo principal antes da integração.

## Alterações

- `scripts/player/player_visual.gd`: seleciona subida/ápice/queda usando velocidade vertical; mantém morte e dash prioritários e não reinicia walk/idle/dash em toda chamada. A pose aérea fica estática e `speed_scale=1.0`.
- `scripts/player/player.gd`: passa `velocity.y` depois de `physics_step` e zera a fase aérea ao resetar no spawn.
- `resources/player_sprite_frames.tres`: adiciona `jump` nos x=1088/1152/1216 com três quadros de 100 ms.
- `assets/player/player-animations.png` e `assets/player/source/player-animations.aseprite`: atlas 1280×64 e fonte combinada de 20 quadros. Os 17 quadros originais permanecem preservados.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/`: Lua e fonte Aseprite, entrada congelada, atlas/JSON, metadata, contact e GIFs nas duas direções.
- Snapshots dos cinco arquivos runtime anteriores à integração em `historico/pre-integracao/`.

## Validação executada

- Aseprite 1.3.18.6: script de geração e exportação horizontal atlas/JSON/GIFs; todos os processos terminaram com exit 0 e stderr vazio.
- Godot 4.7.2: `--headless --editor --path projeto-jogos-digitais --import --quit`; exit 0 e stderr vazio. O log registrou as classes Player/PlayerVisual e reimportou `player-animations.png`.
- Não foram executados testes, gameplay ou quality audit. Gemini/Muse/Grok concluíram as revisões estáticas sem achados reais; Opus bloqueado por quota. A inspeção manual no jogo permanece pendente.
- Nenhum commit/push foi feito.

## Fonte congelada

Os caminhos do estado implementado estão abaixo. Os hashes foram calculados depois da importação e do freeze dos códigos/assets.

| Arquivo | SHA-256 |
|---|---|
| `scripts/player/player_visual.gd` | `3e4fc1ccb3e71dbf9730ff9318a6e938e2e8c1b04e5dc846219b55bb3f137c2f` |
| `scripts/player/player.gd` | `09b07b62e6009ff94dc80dca9397f382cdbb4acccc8bc43ff605fc169374aa3c` |
| `resources/player_sprite_frames.tres` | `3056297f65fc731e743984dd6eb2a02981861da1f18058c0e1d3babf2edc34d3` |
| `assets/player/player-animations.png` | `73b4036c20934b9a3d3e7b9cd41ec7e4da4c92e2d4586c1710418fcf556af001` |
| `assets/player/source/player-animations.aseprite` | `92f8d2b15e08960b3acee995f7bd0bddd9ca281f5947f79893fb6e2e1002bc50` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo.lua` | `46d8597164031b243159b0186ba7d618ac57d6e0b375b5b71517eddc5ef58ad7` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo.aseprite` | `92f8d2b15e08960b3acee995f7bd0bddd9ca281f5947f79893fb6e2e1002bc50` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-spritesheet.png` | `73b4036c20934b9a3d3e7b9cd41ec7e4da4c92e2d4586c1710418fcf556af001` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-spritesheet.json` | `47167a2d11c62502e3cbf591186436d1044f39c7e8e65b55dbdcf692aa27a2f7` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-contact.png` | `91b200a34caa3950cf5a49602977d0894c5446859e7f27aec3aac8416dd6d3fb` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-preview-esquerda.gif` | `3d535e29ebb447d13bbbffa76f197045ae06e1f4d64d1278dea22b5869d24c28` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-preview-direita.gif` | `2833eb38f77a59f0fb6f908b497a2717177d4bf88636de19fae9600710efef76` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-input-atlas-1088x64.png` | `eb354cbe5f5b3a4eb4c07fe277f1fb118cc05e809044c8d0269bf795be3bda65` |
| `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-metadata.json` | `e1de56586d4b1ef01d6c69b27e7598eed60a1b40735c16f7b4787ef1c7ecb48e` |



## Revisão final

Gemini, Muse e Grok concluíram análise estática delimitada sem achados reais. Opus claude-opus-5-5-high bloqueado por quota no preflight. Fonte e assets permaneceram congelados após os pareceres. Relatórios originais, hashes e avaliação do principal em pareceres/README.md. Inspeção manual no jogo pendente; nenhuma execução de testes ou gameplay.
