# Plano incremental — caminhada frontal V5 e refinamentos de braços V6/V7

**Estado:** V5 permanece como base histórica integrada; V6 e V7 de braços estão integradas. O principal inspecionou o contact V7 e autorizou a integração. Revisão estática V7 e avaliação visual do usuário pendentes. O atlas foi importado pelo editor Godot 4.7.2 sem stderr; não houve gameplay ou testes. Os estados anteriores foram preservados em histórico.

## Histórico e base preservada

A v4 lateral foi rejeitada por proporções e formas. Plano, especificação e registro anteriores estão preservados em historico/walk-v4-rejeitada/. As fontes e os exports v4 também permanecem em pitch-assets/protagonista-walk.

A caminhada v5 parte do atlas congelado de 960×64 usado pela v4, preservando idle 0–5 e dash 12–14 na fonte gerada. A pose de referência é o primeiro quadro do idle aprovado: cabeça, capacete, visor, antena, peito creme/amarelo, mãos robóticas e clusters das botas mantêm pixels e volumes do original. A direção nativa é frontal, conforme o idle.

## Incremento artístico v5

- Criar oito poses frontais distintas de 64×64, articulando joelhos, tornozelos, botas e antebraços a partir de pixels originais; evitar membros em linhas grossas e aumento de passada.
- Manter a largura da silhueta perto do idle e abaixo de 32 px; limitar o deslocamento horizontal do pé a 2 px nesta versão.
- Alternar os pés de apoio com a sola de apoio em y=56. O corpo fica neutro nos contatos e passagens, desce 1 px nas compressões e sobe 1 px nas elevações; o pé em balanço sobe até 2 px além do bob.
- Balançar os braços em oposição aos pés em arcos curtos; preservar ligação dos membros e volume das botas.
- Usar canvas 64×64, paleta fechada de 27 cores e alpha binário.
- Gerar Aseprite editável, spritesheet horizontal, contact 4×2 e GIFs demonstrativos nas duas direções em escala 6×.

## Integração v5 realizada

O PNG de 1088×64 e a fonte Aseprite v5 foram copiados para assets/player/. O recurso SpriteFrames já mapeava os 17 quadros nos índices idle 0–5, walk 6–13 e dash 14–16, com durações existentes preservadas, então seu conteúdo não precisou mudar. A importação do atlas foi executada pelo editor Godot 4.7.2 headless, exit 0 e stderr vazio. O primeiro carregamento encontrou um mapeamento de classe global obsoleto: Godot indexava PlayerVisual também em um snapshot histórico de dash dentro de docs/, com assinatura antiga de set_walking. Foi criado o arquivo vazio docs/.gdignore para excluir documentação/histórico da descoberta de classes. No reimport, o cache passou a apontar PlayerVisual para res://scripts/player/player_visual.gd e não houve erros de parsing.

Nenhuma mudança de física, colisão, combate, cadência, duração ou facing foi feita. A integração recebeu revisão estática Gemini/Muse/Grok; Opus bloqueado por quota. A avaliação visual do usuário continua pendente.
## Critérios para a arte

1. Oito poses distinguíveis com leitura frontal e articulação conectada.
2. Identidade, cabeça, peito creme/amarelo, mãos e boots originais preservados, sem abertura excessiva das pernas.
3. Pé de apoio em y=56; elevação e bob dentro dos limites acima.
4. PNG, Aseprite fonte, metadata, contact e GIFs correspondem às oito poses.
5. Revisão visual final pendente; exportações Aseprite não são testes de gameplay.


## Refinamento do balanço dos braços — V6

A V5 tinha valores laterais de braço de até ±2 px e mudanças de 2–3 px entre quadros adjacentes. A V6 mantém ombros ancorados, limita o swing de cotovelo/antebraço a ±1 px e faz follow-through vertical da mão de até ±1 px, em oposição às pernas. Cada eixo muda no máximo 1 px entre fases.

Na conferência da composição, os quadros com follow-through positivo mostraram pixels da mão separados do antebraço: a fonte deslocava apenas a linha y=44. A V6 acrescenta pontes mínimas de punho na própria região dos braços, mantendo a mão ligada sem ampliar a silhueta para fora do envelope de movimento. A cabeça, torso/bob, pernas/botas, idle, dash, cadência, índices, facing e lógica do jogo permanecem iguais à V5.

O principal inspecionou o contact comparativo após a correção e considerou as mãos mais coesas. Gemini, Muse e Grok concluíram revisão estática V6; Opus foi bloqueado por quota. A aprovação visual do usuário não foi registrada. O PNG de 1088×64 e fonte Aseprite foram integrados; a importação do editor Godot 4.7.2 terminou com exit 0 e stderr vazio. Não houve gameplay ou testes. Consulte spec-v6-bracos.md para artefatos e hashes.


## Incremento de braços V7

A V7 move antebraço e luva como um cluster em arco vertical local de ±1 px, com ombros ancorados e swing lateral V6 mantido. Não altera cabeça, torso/bob, pernas, botas, idle, dash, facing ou cadência. O principal inspecionou o contact comparativo e autorizou integrar. PNG/Aseprite foram copiados ao runtime e reimportados no Godot editor; exit 0, stderr vazio. Nenhum teste ou gameplay foi executado. Detalhes e hashes em [spec-v7-bracos.md](spec-v7-bracos.md).


## Incremento V8 — reprodução da caminhada frontal

**Estado:** V8 refinada e aceita pelo principal, integrada apenas em walk 6–13 no atlas de 25 quadros; import editor Godot exit 0. Gemini/Muse/Grok concluídos, Opus por quota. Avaliação visual pelo usuário em jogo pendente. A spec prospectiva e o snapshot reproduzível pre-V8 estão em [spec-v8-referencia.md](spec-v8-referencia.md) e [historico/pre-walk-v8/README.md](historico/pre-walk-v8/README.md).
