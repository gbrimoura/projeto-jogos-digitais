# Refinamento de braços V7 — caminhada frontal

**Estado:** arte integrada. O principal inspecionou o contact comparativo e autorizou a integração. Revisão estática V7 concluída por Gemini/Muse/Grok; Opus bloqueado por quota; aprovação visual do usuário não registrada.

## Mudança

A V7 parte da V6 e anima antebraço e luva como um cluster em arco vertical local de até ±1 px, com passos de no máximo 1 px entre fases. Os ombros permanecem ancorados; o swing horizontal V6 de até ±1 px é mantido. Pontes mínimas de articulação preservam a conexão durante o deslocamento para baixo.

A mudança altera somente pixels dos braços. Cabeça, torso/bob, pernas, botas, idle, dash, facing, índices, cadência e SpriteFrames não mudaram. Atlas de 17 quadros: idle 0–5, walk 6–13 e dash 14–16; walk 8×75 ms. Canvas 64×64 por quadro, 27 cores e alpha binário.

## Artefatos

Diretório: GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk/.

- Fonte: protagonista-walk-v7-bracos.lua; entrada congelada protagonista-walk-v6-input-atlas-960x64.png.
- Referência V6 para comparação: protagonista-walk-v7-v6-reference-atlas-1088x64.png.
- Aseprite editável: protagonista-walk-v7-bracos.aseprite.
- Spritesheet e JSON: protagonista-walk-v7-bracos-spritesheet.png/.json, 1088×64.
- Contact comparativo V6/V7: protagonista-walk-v7-bracos-contact-comparativo.png; V6 acima, V7 abaixo.
- GIFs de inspeção nearest 6×: protagonista-walk-v7-bracos-preview-esquerda.gif e protagonista-walk-v7-bracos-preview-direita.gif.
- Metadata: protagonista-walk-v7-bracos-metadata.json.

Aseprite 1.3.18.6 exportou a fonte, folha, JSON, contact e previews; os comandos terminaram com exit 0 e stderr vazio.

## Integração

O PNG e a fonte Aseprite foram copiados para assets/player/player-animations.png e assets/player/source/player-animations.aseprite. Godot 4.7.2 executou --headless --editor --path projeto-jogos-digitais --import --quit: exit 0, stderr vazio; o log reimportou player-animations.png. Foi uma importação de recurso, sem gameplay ou testes.

- PNG runtime: eb354cbe5f5b3a4eb4c07fe277f1fb118cc05e809044c8d0269bf795be3bda65
- Aseprite runtime: dc8005ee69542453e2794f2f5f46b8c7a568f0aed152ac1d3bd526213d87092e
- Lua V7: ae84159172eeaa63e71f6ab25fa7cc667c97c0a177a8f733c8eef103228add96
- Metadata JSON: 18ffc4d860e4faa30a6f5ed8f73cbe8301f5744d95073fe96361d6f5f5ce7a9a
- Input V6 congelado, 960×64: 19d218d2630eaac25d14fd2106b5298b1102de30475cbed05903a177a933a8e9

Nenhum teste, quality audit ou gameplay foi executado.