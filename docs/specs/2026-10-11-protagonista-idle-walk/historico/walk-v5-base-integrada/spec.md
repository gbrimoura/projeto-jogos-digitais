# Especificação de arte — caminhada frontal v5

## Estado e referência

Esta especificação descreve arte v5 integrada. O principal inspecionou o contact final e autorizou a integração; Gemini/Muse/Grok concluíram revisão estática (Opus por quota) e aprovação visual do usuário não registrada. A v4 artística foi rejeitada pelo usuário; seus documentos foram preservados em historico/walk-v4-rejeitada/.

A pose-base é o idle aprovado no primeiro quadro do atlas congelado de 960×64. Os pixels de cabeça, antena, visor, tronco, peito, ombros, mãos e botas orientam a identidade e as proporções. A caminhada é frontal como o idle, sem mudança para perfil ou 3/4 lateral. A silhueta permanece compacta e deve medir no máximo 32 px de largura.

## Arte

- Canvas de cada pose: 64×64 px.
- Caminhada: oito fases frontais: contato, compressão, passagem e elevação para cada lado.
- Articular pixels existentes em quadril, joelho, tornozelo, bota e antebraço. Os clusters de pernas e mãos mantêm volume do idle.
- Cada pé se desloca horizontalmente no máximo 2 px. O pé em balanço sobe até 2 px além de bob; o pé de apoio mantém sola em y=56.
- Corpo fica neutro nos contatos e passagens, desce 1 px nas compressões e sobe 1 px nas elevações, com cabeça e torso seguindo o movimento. Braços contrabalançam a perna avançada com deslocamento curto de até 2 px.
- Paleta de 27 cores; alpha totalmente opaco ou transparente; sem anti-aliasing.

## Arquivos e exports

Fonte: protagonista-walk-v5.lua, com entrada congelada protagonista-walk-v5-input-atlas-960x64.png. O input v5 deve permanecer idêntico ao snapshot v4, SHA-256 19d218d2630eaac25d14fd2106b5298b1102de30475cbed05903a177a933a8e9.

A saída de arte tem 17 quadros como destino de exportação: idle 0–5, walk 6–13, dash 14–16. A fonte editável foi copiada para assets/player/source/player-animations.aseprite e a folha PNG para assets/player/player-animations.png. O PNG foi importado pelo editor Godot 4.7.2 headless.

- Aseprite fonte: protagonista-walk-v5.aseprite.
- Spritesheet e metadata: protagonista-walk-v5-spritesheet.png / .json, 1088×64.
- Contact sheet: protagonista-walk-v5-contact.png, oito poses em arranjo 4×2, escala nearest 6×.
- GIFs de inspeção: protagonista-walk-v5-preview-esquerda.gif e protagonista-walk-v5-preview-direita.gif, 960×384, deslocamento horizontal com facing coerente.

## Cadência e integração

O recurso SpriteFrames já seleciona 17 quadros: idle 0–5, walk 6–13 e dash 14–16. As durações existentes (idle 420, 140, 180, 140, 540 e 80 ms; walk 8×75 ms; dash 40, 40 e 60 ms) permanecem. O PlayerVisual mantém o speed_scale baseado em abs(velocity.x)/260 e o facing nativo existente. Nenhuma física, colisão, combate, controle ou estado de dash mudou nesta integração.
