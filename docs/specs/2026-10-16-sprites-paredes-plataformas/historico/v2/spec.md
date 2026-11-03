# Especificação V2 — sprites, paredes e distribuição de plataformas

**Escopo:** duas fixtures existentes, proposta provisória. Sem editar GDD ou implementação runtime.  
**Revisão:** R1 Gemini/Muse integrada. Cópias V1 em historico/v1; arquivos de entrada e hashes em pareceres/review-input-r1 permanecem imutáveis.

## 1. Diagnóstico: fatos versus hipóteses

### Fatos

- Viewport 1152×648 (project.godot:21–25). Em ambas as cenas, as shapes laterais atuais medem 32×648 e ficam centradas em x=-16 e x=1168; teto físico 1152×32 centrado em y=-16 (scenes/main.tscn:13–20,244–254; scenes/second_room.tscn:12–19,110–120).
- As cenas dos inimigos configuram BodySprite em scale 2, centralizado no TrainingTarget, offset y=-48 no RivetWorker e shader de flash compartilhado (scenes/training_target.tscn:27–34; scenes/rivet_worker.tscn:44–52).
- SpriteFrames do TrainingTarget incluem disabled, idle, impact; o script seleciona idle e impact. disabled existe no recurso, mas não é selecionado por _update_visuals (resources/enemy/training_target_sprite_frames.tres:17–42; scripts/world/training_target.gd:288–293). Fases visuais do ataque (hidden, windup, active, recovery) pertencem ao efeito separado da área, não a novos frames do corpo (training_target.gd:252–277).
- SpriteFrames do RivetWorker têm idle, walk, aim, fire e recovery; seu script escolhe esses nomes conforme movimento/ataque (resources/enemy/rivet_worker_sprite_frames.tres:25–69; scripts/enemy/rivet_worker.gd:589–607).
- Collider do TrainingTarget é 72×96, retângulo local centrado na origem. Atualmente a rotina de spawn escolhe plataforma e X aleatórios (scenes/training_target.tscn:8–23; scripts/world/training_target.gd:318–375).
- Collider do RivetWorker é 46×64, shape local centrada em (0,-32). A patrulha Main fica entre x=420 e 920; somando meia largura 23, bounds do corpo são x=397..943. Na second_room, patrulha x=760..1040 e bounds x=737..1063. Ambos permanecem entre as futuras faces internas x=64 e x=1088 (scenes/rivet_worker.tscn:8–10,38–40; scenes/main.tscn:299–315; scenes/second_room.tscn:170–190).
- A saída é uma Area2D com CollisionShape2D de sensor (collision_layer=0, mask=2), sem corpo de colisão de parede: o script registra o jogador em alcance e, após sala liberada, E emite transition_requested; Main valida e carrega o destino (scenes/exit_door.tscn:5–14; scripts/world/exit_door.gd:46–81; scripts/world/main.gd:325–360). Main managed remove a porta inteira (main.gd:63–73).

### Hipóteses ainda sem confirmação

A causa relatada de sprites invisíveis não foi localizada estaticamente. Atlas/alpha, região e UID, frame, animação, modulate/self_modulate, transforms, material/shader, z, clipping ou oclusão podem ser investigados, sem declarar nenhum como culpado antes de observar o render em ambiente autorizado. As imagens dos atlases têm pixels opacos; isso não prova que o Godot os carregou ou os desenha.

## 2. Isolamento visual reproduzível

Se o usuário pedir explicitamente verificação/testes no Godot, investigar nesta ordem e registrar o primeiro estágio que falha:

1. PNG em disco: dimensão, alfa e conteúdo do frame usado.
2. Resource: UID/path e source region de cada AtlasTexture.
3. AnimatedSprite2D: SpriteFrames, nome do clip, frame selecionado, autoplay e chamadas de play.
4. CanvasItem: visible, modulate, self_modulate, escala, offset, facing, z_index, canvas e posição final na viewport.
5. Shader/material: bypass local somente no diagnóstico; comparar com e sem shader sem alterar o resource compartilhado global.
6. Oclusão/posição: ordem entre cenário, plataformas e corpos; clipping; transform do pai; spawn final do alvo.

Critério do corpo: TrainingTarget visível em idle e impact; RivetWorker em idle, walk, aim, fire e recovery. Também observar o hit flash sem apagar o corpo. O clip disabled do alvo não deve ser requisito de aceite enquanto o código não o selecionar. Verificar separadamente a área de ataque windup/active/recovery e que a apresentação não cobre o corpo. Corrigir apenas a primeira divergência demonstrada; preservar atlas/desenho se o problema estiver no carregamento ou composição.

## 3. Paredes laterais totalmente sólidas

### Colisão e limites

Reutilizar somente os colliders laterais existentes em ambas as cenas, sem duplicar shapes:

| Parede | Centro da shape | Dimensão | Cobertura física | Face interior |
|---|---:|---:|---:|---:|
| esquerda | (32,324) | 64×648 | x=0..64, y=0..648 | x=64 |
| direita | (1120,324) | 64×648 | x=1088..1152, y=0..648 | x=1088 |

Ambas permanecem retângulos únicos e sólidos de cima a baixo. Não criar abertura física ou visual na direita, nem recortar parede para a porta. O teto atual fica como colisor físico em y=-32..0, sem faixa visual superior: aparência do topo aberta, mas fisicamente bloqueada. O centro seguro do Player, cápsula de raio14, fica x=78..1074; a faixa de câmera continua x=0..1152.

O Floor permanece 1152×88, top y=560 e base y=648 (scenes/main.tscn:256–258; scenes/second_room.tscn:122–124). As colisões de parede e Floor se sobrepõem nos cantos: é intencional para não criar vão, e o Floor não deve ser encurtado. Em render, o Floor de z=0 cobre a porção visual das paredes entre y=560..648.

### Apresentação com atlas existente

Adicionar em cada cena:

- Node2D WallVisuals com z_index=-1, acima do SandboxVisual (-10) e atrás do Floor (0).
- Filhos LeftWallVisual e RightWallVisual sob WallVisuals.
- Helper local scripts/world/factory_wall_visual.gd, sem class_name global, desenha os source rects com filtro nearest; não adiciona colisão.

A textura é atlas source id 0 do TileSet existente, grade 32×32 (resources/environment/factory_tileset_v1.tres:3–23). Para as bordas laterais, usar os tiles de fileira 1: tile id (0,1)/alternative 0, sourceRect Rect2(0,32,32,32) na esquerda; tile id (2,1)/alternative 0, sourceRect Rect2(64,32,32,32) na direita. A organização do atlas identifica essas peças como lateral esquerda e lateral direita, com preenchimento em (1,1) (docs/specs/2026-10-14-tileset-fabrica/plano.md:17–25).

Cada região 32×32 desenha 64×64 unidades em escala 2×. Repetir do topo y=0 dez segmentos completos, cobrindo até y=640. Fechar y=640..648 com o recorte superior de 4 pixels da mesma célula, sourceRect de 32×4 a partir de y=32 e destino de 64×8. Esse recorte é ancorado ao topo e mantém nearest. Paredes visuais ficam atrás do Floor e dos atores; as físicas mantêm as faixas completas já descritas. Não criar arte nova nesta etapa.

## 4. ExitDoor em Main standalone

Reposicionar ExitDoor para (1040,522). Sem escala nova:

- Sensor 96×108 ocupa x=992..1088 e y=468..576, contido no interior jogável até a face da parede x=1088.
- DoorPanel mede 48 unidades de largura, logo x=1016..1064. Permanece inteiro no espaço interno, separado 24 unidades da parede direita.
- O jogador pode entrar na Area e pressionar E após a sala ficar limpa. A porta solicita a troca de cena; ela não representa uma passagem física pela parede.

A parede lateral direita fica sólida por toda altura também em frente ao sensor. Isso não bloqueia o pedido de transição, que depende da Area/interação e não de atravessar parede. Não criar moldura/portal cortando o desenho contínuo da parede. Em Main gerenciado, ExitDoor continua removida e não há recorte visual na parede; second_room continua sem saída seguinte.

## 5. Plataformas determinísticas e passagem sob superfícies

Desativar randomize_position e randomize_width apenas nas instâncias atuais destas duas fixtures. Não alterar o gerador geral nem projetar geração procedural nesta frente. Manter tamanho e espessura da cena; centro, topo, bounds horizontais e relação entre plataformas:

| Sala/plataforma | Centro | Tamanho | Topo | X esquerdo..direito |
|---|---:|---:|---:|---:|
| main / Floor | (576,604) | 1152×88 | 560 | 0..1152 |
| main / PlatformA | (290,480) | 220×24 | 468 | 180..400 |
| main / PlatformB | (615,468) | 190×24 | 456 | 520..710 |
| main / PlatformC | (915,452) | 190×24 | 440 | 820..1010 |
| second_room / Floor | (576,604) | 1152×88 | 560 | 0..1152 |
| second_room / WestPlatform | (340,480) | 240×24 | 468 | 220..460 |
| second_room / UpperPlatform | (615,385) | 190×24 | 373 | 520..710 |
| second_room / EastPlatform | (900,452) | 170×24 | 440 | 815..985 |

Saltos propostos por aresta:
- Main: Floor→A sobe92/vão20; A→B sobe12/vão120; B→C sobe16/vão110.
- Second room: Floor→West sobe92/vão92; West→Upper sobe95/vão60; Upper→East desce67/vão105.
- Retorno crítico East→Upper sobe67. Com impulso640 e gravidade1600, a raiz descendente para essa altura é aproximadamente 0,676s; a 260 unidades/s constantes, alcance teórico ~176 contra vão105, margem ~71. Esse limite pressupõe velocidade horizontal máxima imediata. Aceleração e colisões reduzem alcance, então não declarar rota validada nem margem jogável até verificação autorizada. Nenhuma transição deve exigir dash.

### Passagens no nível do piso

A folga é medida do topo do piso y=560 até a parte inferior da plataforma. A cápsula do jogador mede 76 de altura (scenes/player.tscn:19–25); o herói visual é estimado em ~88 unidades, a confirmar. Não exigir que o jogador atravesse sob as superfícies baixas:

| Plataforma | Parte inferior | Folga até o piso | Classificação da rota |
|---|---:|---:|---|
| main / A | 492 | 68 | bloqueia a cápsula; subir para A pela rota primária |
| main / B | 480 | 80 | só 4 acima da cápsula; não considerar passagem de jogador |
| main / C | 464 | 96 | passagem prevista; ~8 sobre a estimativa visual de 88 |
| second_room / West | 492 | 68 | bloqueia a cápsula; subir para West pela rota primária |
| second_room / Upper | 397 | 163 | passagem ampla |
| second_room / East | 464 | 96 | passagem prevista, bound visual a confirmar |

Assim, Main usa Floor→A→B→C; second_room usa Floor→West→Upper→East. A rota contorna A/B/West por cima. A folga de 96 sob C é compatível com worker de corpo 64 que o GDD descreve sob C (04-combate-e-builds.md:47); a passagem visual do herói continua a confirmar.

## 6. TrainingTarget: suporte fixo, posição centrada e fallback

Adicionar exports coerentes, por exemplo fixed_support_path e fallback_support_path, referentes a SolidPlatform no pai da sala:

| Fixture | Suporte primário | Fallback fixo |
|---|---|---|
| main | ../PlatformC | ../PlatformA |
| second_room | ../UpperPlatform | ../WestPlatform |

O retângulo local de colisão atual é Rect2(-36,-48,72,96). Validar width ≥ 72 + 2×8 = 88 e bounds sem interseção com outra geometria. Usar margem de suporte 8, não a seleção aleatória atual. Posicionar de forma determinística com body = _get_collision_rect(): X da origem = centro global da plataforma menos centro X local do body; Y da origem = topo global da plataforma menos body.end.y. Como o collider atual é centrado, isso dá:

- main / PlatformC: centro X=915, topo440 → TrainingTarget em (915,392).
- second_room / UpperPlatform: centro X=615, topo373 → TrainingTarget em (615,325).
- fallback main / PlatformA: centro X=290, topo468 → (290,420).
- fallback second_room / WestPlatform: centro X=340, topo468 → (340,420).

Não usar randf_range ou um pool aleatório no caminho fixo. O BodySprite atual é centered, scale2 e sem offset no TrainingTarget; o frame nominal de 64 px desenha 128 unidades. A inspeção alfa agregada do atlas indica conteúdo y=12..55; isso coloca a borda visível inferior cerca de 2 unidades acima do topo da plataforma quando a colisão termina no topo, apenas como estimativa a conferir por pose. No worker, o offset visual -48 e scale2 devem ser conferidos contra collider y=-64..0; alpha agregado y=25..55 sugere conteúdo visível perto de root-62..root-2, sem provar clipping. Inspecionar bounds/offset por frame no render autorizado antes de qualquer ajuste.

Se o suporte primário falhar por caminho inválido, largura insuficiente ou colisão, escolher o fallback explícito da tabela, também centralizado. Se ele falhar, restaurar e validar a tabela autoral de plataformas acima antes de criar inimigos. Se a validação continuar falhando, rejeitar o carregamento da sala com erro explícito; não começar combate com alvo flutuando, invisível ou sorteado para outro lugar.

## 7. Worker, LOS e estados de combate

O worker permanece no piso, com bounds físicos atuais:

| Sala | Centro dos limites de patrulha | Intervalo dos markers | Extensão do collider incluindo meia largura 23 | Dentro de x=64..1088 |
|---|---:|---:|---:|---|
| main | 670 | 420..920 | 397..943 | sim |
| second_room | 900 | 760..1040 | 737..1063 | sim |

Main tem Worker spawn x=650 e second_room x=900 (scenes/main.tscn:299–315; scenes/second_room.tscn:170–190). Com root y=560 e collider offset -32, o corpo ocupa aproximadamente y=496..560. Os corredores de 96 sob C/East comportam esse collider; o corredor de 80 sob B também excede os 64 do worker em 16 unidades. Não alterar os bounds de patrulha nesta proposta.

Verificação manual de LOS, sem nova frequência ou contagem:
- TrainingTarget: com jogador dentro do alcance já configurado e raio de consulta sem obstáculo, observar windup, ativo e recovery; colocar parede/plataforma no raio e confirmar que o ataque não aplica através do bloqueio. Verificar alvo visível e apoiado em ambas as posições fixas.
- RivetWorker: em posição configurada de combate, confirmar que há orientação e disparo com raio limpo; testar obstrução por parede/plataforma e confirmar que não dispara através da superfície. Permitir o reposicionamento existente e confirmar uma posição de linha livre.
- Não fixar intervalo de ataque, número de disparos ou exigência de fogo contínuo. Critério é existir linha de visão manualmente demonstrável em um posicionamento previsto da sala e respeitar o bloqueio físico.

## 8. Fora de escopo e verificação

Geração procedural final permanece pendente no GDD. Não especificar validador genérico, novos algoritmos ou diversidade de salas. Não editar GDD, arte-fonte ou TileSet existente.

Apenas revisão estática documental nesta V2. Godot, importação, gameplay e testes somente mediante pedido explícito do usuário para verificar/testar.