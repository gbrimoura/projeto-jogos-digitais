# Protagonista idle e caminhada — plano

**Estado:** implementado com caminhada expressiva v3; Gemini/Muse revisados. Grok sem parecer, Opus pendente por quota; runtime não executado.

## Objetivo

Integrar no Godot o idle v2 já aprovado e acrescentar um ciclo de caminhada
lateral. Preservar a arte original, sua paleta e a pose frontal, mantendo a
animação separada da física e dos sistemas de combate.

## Escopo

- Criar uma fonte Aseprite Lua baseada no spritesheet aprovado do idle v2.
- Exportar um atlas horizontal de 12 frames de 64×64: seis de idle e seis de
  caminhada.
- Criar SpriteFrames editável com animações idle e walk.
- Trocar os polígonos do PlayerVisual por AnimatedSprite2D.
- Acionar caminhada apenas no chão, com velocidade horizontal real; reproduzir
  idle parado no chão e manter seu primeiro quadro estático no ar e durante dash.
- Espelhar apenas o sprite ao trocar de direção; manter a raquete e o estado
  físico independentes.
- Registrar os limites visuais, a escala inteira e as decisões de implementação.

## Critérios de aceite

1. Os seis quadros e as durações do idle v2 são copiados sem alteração.
2. A caminhada tem seis quadros de 100 ms, alterna braços e pés e sobe no máximo
   1 px com um pé em balanço por vez.
3. As máscaras usam pixels da arte original, sem substituição por polígonos ou
   cores novas.
4. O AnimatedSprite2D usa filtragem nearest e espelha somente a imagem.
5. Parada, salto, dash, pausa, morte e retorno ao spawn não deixam a caminhada
   ativa indevidamente.
6. Colisão e regras de movimento permanecem inalteradas.

O runtime carrega `res://assets/player/player-animations.png`; a fonte Aseprite
editável correspondente está em `assets/player/source/player-animations.aseprite`.

## Fora do escopo

Animações de salto, dano e morte; mudança da pose aprovada; colisão, controles,
movimento, mira, raquete, upgrades ou balanceamento.
