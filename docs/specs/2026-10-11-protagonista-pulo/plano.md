# Plano — animação de pulo do protagonista

**Estado atual:** correção de escala V4 integrada e importada pelo Godot 4.7.2 após aprovação do principal. Revisão estática Gemini/Muse/Grok em andamento; Opus bloqueado por quota. A avaliação visual do usuário no jogo permanece pendente. V2 e os estados anteriores foram preservados nos snapshots já registrados; os adendos V3 e V4 descrevem o runtime atual.

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

## Adendo de escala V4 — 13/10/2026

O diagnóstico mediu o casco+visor do idle no frame 0 em 17×18 px e a média dos oito envelopes de pulo nos frames 17–24 em aproximadamente 21,3×21,8 px. As dimensões totais das poses variam com a abertura de braços e pernas e não foram usadas como proxy de escala; o torso central mede aproximadamente 13–14×13 px e já era próximo ao idle. O fator uniforme 0,85 reduz a cabeça, sem redesenho, para preservar leitura, articulação e peso.

O principal aprovou previamente o contact comparando idle0, poses runtime originais e poses redimensionadas, em grade 4×. Foram transformados de modo uniforme apenas os oito frames de pulo por nearest-neighbor inverse sampling. O pivot foi X=32; impulso 17 e pouso 22–24 usam Y=56; frames aéreos 18–21 usam Y=32. A paleta permanece em 27 cores, com alfa 0/255. Cadência original mantida: 110/95/110, 45, 85 e 45/45/45 ms.

A integração partiu do snapshot atual de 28 frames (1792×64), preservando exatamente os frames 0–16 e 25–27 (20 frames, incluindo hurt). Aseprite Lua confirmou os 28 timings, 8 tags e o tamanho do atlas; `resources/player_sprite_frames.tres` e scripts/cenas não foram alterados. Godot 4.7.2 recovery import (`--headless --editor --recovery-mode --path <repo> --import --quit`) terminou com exit 0. Sem testes, gameplay ou quality audit. Os arquivos e hashes congelados estão no adendo V4 de `spec-escala-v4.md`; a revisão externa está registrada em `pareceres/escala-v4/`.

## Encerramento da revisão de escala V4 — 13/10/2026

Gemini, Muse e Grok concluíram revisão estática sem correções obrigatórias. Opus bloqueado por quota. [Pareceres originais, decisões e hashes](pareceres/escala-v4/README.md). Arte aprovada pelo principal e integrada/importada; avaliação estética do usuário no jogo pendente.
