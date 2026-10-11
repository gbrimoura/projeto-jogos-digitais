# Protagonista idle e caminhada — plano incremental v4

**Estado:** caminhada v4 implementada; revisão estática externa pendente. O principal inspecionou e aprovou o contact sheet antes da integração. Sem execução de gameplay, testes ou quality audit.

## Base preservada

O idle aprovado mantém seis quadros, suas durações e seus pixels. O dash preserva os três quadros atuais. O restante do atlas e os sistemas de física, colisão e combate ficam fora deste incremento. A especificação e o plano substituídos foram copiados literalmente para historico/walk-v3/.

## Incremento v4

- Redesenhar a caminhada em oito poses originais de 64×64, nativas para a esquerda e em três quartos lateral.
- Articular contato, compressão, passagem e elevação em duas metades alternadas; ampliar os arcos das pernas, contrabalançar braços e inclinar o tronco para a frente. Manter quadris e ombros ligados ao corpo e a antena com atraso de um pixel.
- Reutilizar diretamente a cabeça e a antena do idle aprovado; conservar paleta fechada de 27 cores e alpha binário.
- Exportar atlas horizontal de 17 frames: idle 0–5, walk 6–13, dash 14–16.
- Usar oito tempos de 75 ms. No walk, ajustar speed_scale com abs(velocity.x) / 260, clamp entre 0,65 e 1,35; restaurar 1,0 em idle, dash, ar, morte e reset. Não reiniciar o quadro a cada tick.
- Preservar a orientação nativa esquerda da caminhada e a orientação nativa direita do dash através da regra de facing existente.

## Critérios de aceite

1. As oito poses são distintas e legíveis, com membros conectados, contato de apoio na linha da sola y=56 e balanço alternado.
2. Cabeça, cores, identidade, idle e dash aprovados permanecem preservados.
3. Atlas e SpriteFrames concordam nos índices e tempos.
4. A cadência usa a velocidade horizontal real somente durante caminhada válida e não altera a física.
5. A fonte Lua e o Aseprite editável, contact sheet, GIFs, metadados e exportação permanecem em pitch-assets/protagonista-walk.

## Fora do escopo

Alterações de física, colisão, combate, upgrades, arte de dash, pose de idle, lógica de direção ou testes/gameplay.
