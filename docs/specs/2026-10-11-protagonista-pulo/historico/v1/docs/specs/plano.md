# Plano — animação de pulo do protagonista

**Estado:** três poses desenhadas e aprovadas pelo principal no contact; integradas no atlas e no seletor visual. Importação de recursos pelo editor Godot concluída. Gemini/Muse/Grok concluíram as revisões estáticas; Opus bloqueado por quota. Inspeção manual no jogo pendente; a aprovação visual final do usuário não foi registrada.

## Objetivo

Adicionar uma pose frontal compacta de subida, ápice e queda. Selecionar a pose diretamente pela velocidade vertical real do Player depois de cada passo de física, sem antecipação de input nem alteração de física.

## Escopo

- Congelar o atlas runtime de 17 quadros e preservar idle 0–5, walk 6–13 e dash 14–16.
- Acrescentar três desenhos de 64×64 px (subida, ápice e queda) nos índices 17–19.
- Integrar uma animação `jump` de três quadros estáticos em `SpriteFrames`; a fase é selecionada por `velocity.y`.
- Manter prioridade visual de morte, dash, pulo, walk/idle.
- Retornar a walk/idle ao pousar e limpar o estado aéreo ao resetar para o spawn.
- Criar fontes Aseprite/Lua, atlas, JSON, contact e GIFs demonstrativos em duas direções.
- Preservar snapshots runtime anteriores isolados da importação por `docs/.gdignore` em `historico/pre-integracao/`.

## Limites

Não alterar física, controlador de movimento, colisão, input, combate, cenas, tempos existentes ou as poses já integradas. Os GIFs demonstram o deslocamento vertical em arco; essa translação não existe nos quadros de runtime. Não executar gameplay, testes ou quality audit nesta frente.
