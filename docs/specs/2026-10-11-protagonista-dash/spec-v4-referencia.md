# Dash v4 — referência e escopo visual

**Estado:** referência gerada, poses reproduzidas e aprovadas pelo principal; integração concluída em 13/10/2026. Gemini/Muse/Grok concluíram a revisão estática final; Opus bloqueado por quota. Nenhum teste, gameplay ou quality audit executado.

## Base confirmada

- Atlas atual: 25 quadros de 64×64 px, 1600×64 px.
- Faixas atuais: idle 0–5; caminhada V8 6–13; dash 14–16; pulo V3 17–24.
- A identidade de referência é `GDD_Dieselpunk_Noir/pitch-assets/protagonista-idle/protagonista-idle-v2-preview.png` (SHA-256 `1dea3d0ed9e53ca034e378dc97970d26942718d782f099a65a5746beceaf2430`). A cabeça em vista lateral/3⁄4 deve conservar o capacete creme, a viseira preta com ciano e a carcaça azul/amarela da antena, sem colar a cabeça frontal do idle sobre o corpo.
- A cópia imutável do atlas de 25 quadros, fonte Aseprite e três scripts de contexto está em `historico/pre-dash-v4/`; o manifesto registra os hashes e o recurso SpriteFrames congelado registra a cadência atual.

## Intenção da nova animação

Recriar somente as três poses de dash a partir da referência visual gerada, preservando a pose de perfil +X do personagem. A sequência deve comunicar: impulso já baixo e compacto; avanço com silhueta linear e curta; liberação/recuperação ainda inclinada. Cabeça e ombro permanecem conectados, braços recolhidos de forma coerente e pernas dobradas e compactas atrás do quadril, sem corrida, lunge amplo, perna projetada longa ou membros separados.

## Restrições visuais e técnicas

- A referência gerada será a guia principal de forma e sequência; a referência idle serve apenas para identidade e paleta. A imagem gerada pode conter halo ou transparência parcial: ao reproduzi-la, remover pixels de fundo, quantizar para a paleta de 27 cores e deixar alpha apenas 0 ou 255, preservando a silhueta sem erosão.
- Cada pose final ocupa um quadro 64×64. Aplicar escala uniforme e alinhamento coerente entre poses; não ajustar cada pose ao canvas por auto-fit. Usar y=56 como registro de apoio quando a pose tiver um pé apoiado.
- O dash nativo continua voltado à direita; o runtime existente espelha a imagem para a esquerda. A prévia horizontal demonstra ambos os sentidos, mas não adiciona deslocamento de raiz ao jogo.
- Manter 40/40/60 ms, 140 ms no total e reprodução não cíclica. Não alterar velocidade, duração, trilha, física, input, combate, colisor ou scripts de gameplay.
- Preservar byte/pixels, tempos e tags dos outros 22 quadros; em particular, manter caminhada V8 nos índices 6–13 e pulo V3 nos índices 17–24.

## Saídas e etapa de revisão visual

Na pasta `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-v4/`, entregar Lua reproduzível, fonte Aseprite editável, spritesheet PNG, metadata e previews. A prancha comparativa deve mostrar as três poses lado a lado e também idle/dash atuais para comparação. O GIF horizontal demonstrativo deve mostrar deslocamento de tela para ambos os lados usando apenas as poses geradas e o espelhamento nativo.

Antes da integração no atlas de runtime, o agente principal inspeciona a prancha e aprova ou pede refinamento. Até essa aprovação, não substituir `assets/player/player-animations.png` nem `assets/player/source/player-animations.aseprite`. Após a aprovação, a integração parte de `historico/pre-dash-v4/`, substitui somente os quadros 14–16 e confirma que os demais 22 permanecem idênticos. Importar pelo editor Godot em modo headless será a única etapa de engine; não executar gameplay, testes ou quality audit.

## Referências e resultado

Foram preservadas as duas imagens entregues pelo agente principal:

- Rascunho de direção v1: `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-v4/referencia-dash-v4-v1.png`, SHA-256 `01d89e6fcf2e6aeaa87ebba3c8d0a10bb29a89afc409fbe2c3b97d2d953a0581`.
- Referência final v2: `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-v4/referencia-dash-v4-v2.png`, SHA-256 `bcb6ae4e0b935f55a68bf796738888acf3a6ad64ac8f30d5e04cf74a5048440f`.

A V2 mede 1536×1024 px e tem três células 512×1024. A extração usa alpha ≥224,
escala uniforme 1:9, nearest-neighbor, centro X compartilhado (256→32) e soles
de referência 724/723/724→y=56. Não foi feito auto-fit individual. Os bounds
resultantes, cadências e paleta por quadro estão no metadata e na
[implementação](implementacao.md#dash-v4--13-10-2026).

O principal inspecionou e aceitou, antes de integrar, as imagens
`protagonista-dash-v4-contact-3poses.png` e
`protagonista-dash-v4-comparison-idle-dash.png`. A prancha mostra o perfil +X,
capacete/visor coerentes, antebraço ligado e pernas compactas. A prévia GIF
`protagonista-dash-v4-horizontal-demo.gif` demonstra ambas as direções sem
alterar a física runtime.

A integração usou somente o snapshot `historico/pre-dash-v4/` e mudou os
quadros 14–16 em `assets/player/player-animations.png` e
`assets/player/source/player-animations.aseprite`. A verificação do integrador
confirmou os outros 22 quadros pixel a pixel, as 25 durações e todas as tags
preservadas. Godot 4.7.2 importou os recursos em modo headless (exit 0, stderr
vazio; `.ctex` presente). Os hashes completos e a reprodução estão no
`README.md` dos artefatos congelados. Esta etapa não executou testes, gameplay ou
quality audit.
