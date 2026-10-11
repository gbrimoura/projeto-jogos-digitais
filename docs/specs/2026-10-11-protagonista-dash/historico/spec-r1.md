# Especificação — dash do protagonista

## Fonte e atlas

- Fonte de entrada: `GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk/protagonista-walk-v3.aseprite`, com os doze frames aprovados de idle e caminhada.
- A fonte Lua acrescenta três frames novos ao mesmo sprite, sem alterar a fonte
  v3 no disco. O clone da composição da pose base pode ser usado para construir
  os novos desenhos.
- Cada quadro mede 64×64 px. O atlas final é horizontal, de 960×64 px: idle nos
  índices 0–5, walk nos índices 6–11 e dash nos índices 12–14.
- A arte dash mantém a paleta amostrada de 27 cores, pixels opacos ou
  transparentes e a identidade visual da cabeça e do traje. Não usa
  anti-aliasing, rotação interpolada, blur ou pixels fora do canvas.
- As três poses representam impulso, avanço e sustentação. O tronco/cabeça se
  inclinam para +X; os braços ficam recolhidos para trás; as pernas flexionam e
  permanecem ligadas aos quadris, com ao menos um pé perto do chão. A direção
  oposta continua usando o `flip_h` da imagem.
- O script aceita `out`, `source_aseprite` e `base`. O nome padrão é
  `protagonista-dash-v1`; `source_aseprite` aponta para o arquivo v3 na pasta
  `protagonista-walk`.

## Temporização

| Animação | Índices | Duração por quadro | Ciclo |
|---|---:|---:|---:|
| idle | 0–5 | 420, 140, 180, 140, 540, 80 ms | 1.500 ms, cíclico |
| walk | 6–11 | 100 ms cada | 600 ms, cíclico |
| dash | 12–14 | 40, 40, 60 ms | 140 ms, não cíclico |

O recurso `SpriteFrames` mantém velocidade base de 1 fps; `duration` permanece
como multiplicador de segundos. A última pose de dash continua visível enquanto
`_is_dashing` permanecer ativo após os 140 ms. O controlador de dash já limita a
duração em 0,14 s; esta alteração não ajusta esse valor.

## Estado visual e integração

Prioridade: morte (animação parada), dash, pose estática no ar (primeiro quadro
do idle), e, no chão, caminhada ou idle conforme o estado atual.

A transição de `set_dashing(false)` para `set_dashing(true)` reinicia o frame 0
do dash uma única vez. Mudanças de estado de chão ou caminhada enquanto o dash
está ativo não chamam `play()` novamente. Se o dash terminar antes ou depois dos
140 ms, a apresentação volta imediatamente à animação adequada para o estado
atual. Morte interrompe a animação e o reset mantém o comportamento de idle já
existente. O espelhamento continua limitado ao `AnimatedSprite2D`; a trilha
`DashTrail` conserva seu comportamento.

Não há mudança de velocidade, duração, colisão, entrada, controle, raquete,
combate ou cenas.

## Estado e pendências

Implementação de código e integração estática em andamento. O PNG de runtime e a
fonte combinada editável devem ser exportados pelo agente principal a partir do
script. As revisões requeridas e inspeção manual no Godot permanecem pendentes.
Nenhum teste, execução do Godot ou auditoria de assets é solicitado neste plano.
