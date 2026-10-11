# Especificação de arte — caminhada frontal V5 com refinamentos de braços V6/V7

## Estado e referência

Esta especificação descreve a base frontal V5, o refinamento de braços V6 e o incremento V7 integrado. O principal inspecionou o contact comparativo V7 e autorizou a integração; revisão estática V7 e aprovação visual do usuário pendentes. A v4 artística foi rejeitada pelo usuário; os documentos V4 e a especificação V5 congelada foram preservados em histórico.

A pose-base é o idle aprovado no primeiro quadro do atlas congelado de 960×64. Os pixels de cabeça, antena, visor, tronco, peito, ombros, mãos e botas orientam a identidade e as proporções. A caminhada é frontal como o idle, sem mudança para perfil ou 3/4 lateral. A silhueta permanece compacta e deve medir no máximo 32 px de largura.

## Arte

- Canvas de cada pose: 64×64 px.
- Caminhada: oito fases frontais: contato, compressão, passagem e elevação para cada lado.
- Articular pixels existentes em quadril, joelho, tornozelo, bota e antebraço. Os clusters de pernas e mãos mantêm volume do idle.
- Cada pé se desloca horizontalmente no máximo 2 px. O pé em balanço sobe até 2 px além de bob; o pé de apoio mantém sola em y=56.
- Corpo fica neutro nos contatos e passagens, desce 1 px nas compressões e sobe 1 px nas elevações, com cabeça e torso seguindo o movimento. Braços V6 contrabalançam as pernas com swing lateral máximo de 1 px e follow-through vertical da mão de até 1 px.
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


## Incremento V6 — balanço e conexão dos braços

A V6 refina somente os braços nas oito poses da caminhada V5. Os ombros seguem ancorados ao torso; cotovelos e antebraços percorrem arco curto de até ±1 px, e a mão recebe follow-through de até ±1 px. A mão esquerda usa swing [1,1,0,-1,-1,-1,0,1] e follow-through [0,-1,-1,0,0,1,1,0]; a direita usa sinais opostos. Cada eixo muda no máximo 1 px entre quadros adjacentes.

O primeiro exame do atlas V6 mostrou que deslocar apenas y=44 no follow-through positivo abria um intervalo de um pixel até o antebraço. A fonte agora acrescenta pontes mínimas de punho, apenas na região de braço, para manter o cluster conectado. O contact comparativo final foi inspecionado pelo principal. Gemini, Muse e Grok concluíram revisão estática V6; Opus foi bloqueado por quota. A aprovação visual do usuário permanece pendente.

Os arquivos V6 e hashes estão em spec-v6-bracos.md. A base V5, atlas de 17 quadros, durações existentes e importação do editor Godot 4.7.2 permanecem conforme registrados nesta especificação.


## Incremento V7 — arco curto de antebraço e luva

A V7 parte da caminhada frontal V6 e altera somente os braços nas oito poses. Mantém os ombros ancorados nas linhas 40–41 relativas ao torso; move antebraço e luva juntos em até 1 px vertical, mantendo o swing horizontal V6 de até 1 px. As transições entre fases continuam limitadas a 1 px. Pontes mínimas de articulação mantêm a conexão quando o cluster desce.

Cabeça, torso/bob, pernas, botas, idle, dash, facing, cadência e SpriteFrames permanecem iguais à V6. O atlas continua com 17 quadros: idle 0–5, walk 6–13 e dash 14–16; caminhada 8×75 ms. A revisão estática V7 e a aprovação visual do usuário ainda não foram registradas.

Consulte [spec-v7-bracos.md](spec-v7-bracos.md) para arquivos, hashes e registro da importação Godot.
