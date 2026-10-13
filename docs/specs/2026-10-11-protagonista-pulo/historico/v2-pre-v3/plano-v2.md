# Plano — animação de pulo do protagonista

**Estado atual:** o runtime V2 continua integrado e importado pelo editor Godot 4.7.2, mas o usuário rejeitou sua direção artística por falta de mobilidade e peso; pareceres estáticos de código não representam aprovação estética. A prancha V3 fornecida pelo usuário foi reproduzida em Aseprite, e o principal aceitou o contact comparativo para esta entrega de arte. Os novos arquivos ainda não substituem o runtime e não têm aprovação final do usuário. V1/V2, seus documentos e o draft autoral V3 rejeitado permanecem preservados.

## Objetivo

Trocar as três poses congeladas da V1 por quadros articulados em ciclos de subida, ápice, queda e aterrissagem. O corpo acompanha o impulso em 1–2 px, joelhos e tornozelos mudam de posição entre quadros, e as solas se mantêm apoiadas durante a compressão curta de aterrissagem. A fase é escolhida pela velocidade vertical real do Player; animação não antecipa input nem modifica a física.

## Escopo

- Preservar idle 0–5, walk 6–13 e dash 14–16 exatamente, inclusive durações.
- Substituir os antigos quadros de pulo 17–19 por nove desenhos 17–25 no atlas de 26 quadros.
- Criar clipes SpriteFrames jump_rise, jump_apex, jump_fall e jump_land. Os três primeiros repetem por tempo enquanto o Player permanece na fase; jump_land não repete e dura 135 ms, com compressão do torso 2→1→0 px e solas apoiadas.
- Selecionar a fase aérea pela velocity.y atual, com janela de ápice de ±80 px/s. O ápice usa 45 ms por quadro; subida e queda usam 85 ms por quadro.
- Prioridade visual: morte, dash, fase aérea, aterrissagem e walk/idle. Dash, novo salto, morte e reset cancelam a aterrissagem sem bloquear movimento ou input.
- Só tocar aterrissagem após observar contato válido com o chão, saída para o ar e retorno ao chão. Spawn/reset limpa esse histórico para evitar pouso falso.
- Preservar fontes e saídas Aseprite/Lua, input atlas congelado, atlas, manifest, metadata, contact e GIFs demonstrativos em duas direções.

## Limites

Não alterar movement_controller, física, gravidade, jump height, colisores, combate, input ou cenas. A translação vertical do personagem nos GIFs é somente composição demonstrativa. Os dois GIFs são exportados a 4× nearest (256×512); cada pose do ápice permanece 110 ms apenas para leitura, enquanto o runtime usa 45 ms por pose. O JSON é um manifest manual produzido pelo Lua, não metadados automáticos do exportador.

Não executar testes, gameplay ou quality audit. A importação pelo editor é apenas validação de recursos/scripts e não substitui conferência visual em jogo. Nenhum commit ou push faz parte do plano.

