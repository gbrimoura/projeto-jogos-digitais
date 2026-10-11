# Especificação — protagonista idle e caminhada

## Fonte visual

- Referência aprovada: GDD_Dieselpunk_Noir/pitch-assets/protagonista-idle/protagonista-idle-v2.aseprite.
- O spritesheet aprovado de 384×64 fornece os seis quadros de idle e a pose
  base do primeiro quadro.
- Cada frame final mede 64×64; a pose nativa mede 24×50, com origem em (20, 7),
  e mantém a paleta amostrada de 27 cores.
- A caminhada usa máscaras retangulares somente para separar os pixels
  existentes dos braços e das pernas. O corpo, os membros e a paleta não ganham
  formas ou cores desenhadas à parte.
- O primeiro frame walk reconstrói o primeiro frame aprovado, comparado pixel a
  pixel pelo script gerador.

## Temporização

| Animação | Quadros | Duração por quadro | Ciclo |
|---|---:|---|---:|
| idle | 6 | 420, 140, 180, 140, 540, 80 ms | 1.500 ms |
| walk | 6 | 100 ms cada | 600 ms (10 fps) |

Em Godot, o recurso SpriteFrames usa velocidade base de 1 fps e os campos
duration como multiplicadores em segundos, preservando os tempos acima.

## Exibição e física

- AnimatedSprite2D usa escala inteira 2×, filtro nearest e região de atlas
  64×64. A pose opaca mede aproximadamente 48×100 pixels no mundo, acima do
  colisor de 28×76; pés ficam alinhados ao chão com posição local y=-50.
- O tamanho visual maior mantém pixels inteiros e deixa o colisor intacto.
- Caminhada exige is_on_floor(), velocidade horizontal absoluta acima de
  8 px/s e ausência de dash. A direção vem do controlador de movimento.
- Apenas AnimatedSprite2D.flip_h é espelhado. PlayerVisual, DashTrail,
  raquete, origem de tiro e nós de colisão não são espelhados como grupo.
- Parado no chão, o sprite reproduz idle. No ar e durante dash, mantém o
  primeiro quadro estático de idle; não há caminhada aérea nem animação própria
  de dash. A cena pausada herda a pausa do AnimatedSprite2D. Morte interrompe a
  reprodução. Reiniciar no spawn volta ao primeiro quadro de idle.

## Estado e pendências

Esta especificação cobre somente apresentação visual. Não foram solicitadas nem
executadas validações no Godot, testes ou quality audit. Jump/hurt/death frames
permanecem futuras animações.

## Correção das pernas — v2

As quatro linhas superiores de cada máscara de perna ficam ancoradas; joelho/tornozelo articulam por deslocamento horizontal máximo de 1px. As botas (y=54..56) sobem 1px alternadamente nos índices walk 2 e 5 (3ª e 6ª poses); a perna de apoio mantém sua bota no chão. A bota de balanço sobrepõe o tornozelo na junção para evitar fenda. Substitui o deslocamento rígido de toda a perna em até 2px. Idle, paleta, atlas, timings, escala e integração Godot preservados. Fonte atual protagonista-walk-v2.aseprite, copiada para assets/player/source/player-animations.aseprite.
