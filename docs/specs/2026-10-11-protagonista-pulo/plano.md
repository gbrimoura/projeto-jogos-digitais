# Plano — animação de pulo do protagonista

**Estado atual:** runtime V3 integrado e importado pelo editor Godot 4.7.2. O principal aceitou a arte reproduzida da prancha; revisão estática da integração concluída por Gemini/Muse/Grok; Opus bloqueado por quota, avaliação visual do usuário no jogo pendente. O runtime V2, rejeitado por falta de mobilidade e peso, foi preservado em historico/v2-pre-v3/, junto dos documentos anteriores. O restante deste plano descreve a revisão V2 histórica; os critérios vigentes desta integração estão no adendo runtime V3 ao final.

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
## Adendo runtime V3 — 12/10/2026

O runtime integrado usa as oito poses reproduzidas da prancha fornecida, sem redesenho. O atlas é horizontal, 25×64×64 px (1600×64). Frames 0–16 de idle/walk/dash e suas cadências são preservados pixel a pixel. Rise frames 17–19 são impulso/subida/recolhimento (110/95/110 ms), não-loop e seguram o último quadro. Apex 20 e fall 21 são poses únicas mantidas. Land 22–24 dura 45 ms por pose, total 135 ms. Mantém-se a prioridade visual existente death > dash > ar > land > walk/idle e a classificação aérea por velocity.y com limiar ±80 px/s; não se reinicia um clipe não-loop por tick. Spawn/reset não cria pouso falso.

Registro: baseline da sola idle y=56. Foi aplicada translação comum inteira Y=-5 às oito poses. Somente a pose compressão recebe compensação adicional de registro +1 px (offset líquido Y=-4), decisão autorizada pelo principal para manter as solas apoiadas. Não há autofit por pose, escala variável ou arco de translação. A direção nativa do jump permanece esquerda; os primeiros 17 quadros preservam as direções originais, inclusive dash à direita.

A física, movimento, input, colisores, combate e cenas permanecem fora de escopo. A geração Lua usa o snapshot V2 como fonte reproduzível e escreve o Aseprite, PNG, contact 3×3 e metadata em GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/; V2 foi arquivada antes da substituição em historico/v2-pre-v3/. A importação do editor Godot 4.7.2 terminou com exit 0. Sem testes, gameplay ou quality audit. Revisões estáticas da implementação e inspeção manual no jogo ainda pendentes.
