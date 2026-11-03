# Especificação: sprites, paredes e distribuição de plataformas

**Natureza:** proposta concreta, provisória e limitada às fixtures atuais. Não altera GDD nem autoriza implementação runtime.

## Fatos e pendências

### Confirmado estaticamente

- Viewport: 1152×648 e canvas stretch (project.godot:21–25). Piso das duas cenas: 1152×88 centrado em (576,604), logo topo y=560 (scenes/main.tscn:256–258, scenes/second_room.tscn:122–124).
- Colliders laterais atuais: shape 32×648 nos centros x=-16 e x=1168; faces interiores estão exatamente nos limites visíveis e toda a largura fica fora da viewport. Teto 1152×32 centrado em y=-16 (main.tscn:13–20,244–254, second_room.tscn:12–19,110–120).
- Atlases dos inimigos têm SpriteFrames de regiões 64×64 e UID/path correspondente; as cenas configuram sprites em escala 2 e idle automático. O worker tem offset visual y=-48; os dois sprites usam o shader de flash compartilhado (scenes/training_target.tscn:11–34, scenes/rivet_worker.tscn:11–52, resources/enemy/training_target_sprite_frames.tres:3–18, resources/enemy/rivet_worker_sprite_frames.tres:3–26).
- TrainingTarget escolhe uma plataforma em runtime após a criação dos nós; sua posição gravada é placeholder, não ponto final (scripts/world/training_target.gd:329–375). O alvo e o worker fazem consulta de linha de tiro contra layer1; o worker também usa a mesma máscara para projétil (training_target.gd:11,112, scripts/enemy/rivet_worker.gd:29,80–94).
- Configuração do player: move 260, gravity 1600, jump velocity 640, dash speed 720 por 0,14 s (resources/player_movement_config.tres:7–20). Estimativa física de salto ideal: 128 unidades na vertical e duração de subida+descida até mesmo nível de 0,8 s. À velocidade máxima constante, a distância horizontal teórica em voo no mesmo nível é 208 unidades; aceleração, input, corte e colisões reduzem o alcance jogável.
- Layout atual é mutável por aleatoriedade aplicada plataforma a plataforma e condicionada às âncoras já posicionadas; default room_rect é 1280×720 e o viewport é 1152×648. O gerador valida cada plataforma contra âncoras já posicionadas, não a cadeia global completa, spawns, LOS ou suporte autoral (scripts/world/solid_platform.gd:32–62,81–179).

### Não confirmado

- Ainda não há causa observada para os sprites invisíveis. Não se conclui que atlas, regiões, UID, shader, modulação, escala, animação, z-index, camada ou posicionamento estejam errados.
- Não se sabe se a parede ausente é percebida por recorte visual, expectativa de design ou outro estado de cena. A inspeção estática mostra colisão lateral sem faixa visual dentro da viewport.
- O GDD não define sala superiormente fechada, layout final de plataformas ou geração procedural final. main e second_room são fixtures de demonstração (../GDD_Dieselpunk_Noir/04-combate-e-builds.md:37–43,65).

## A. Isolamento reprodutível dos sprites

Reproduzir separadamente TrainingTarget e RivetWorker, primeiro no estado idle e depois nas poses/estados acionados no combate. Registrar o primeiro estágio que falha nesta ordem, inspecionando A e B lado a lado quando o passo for compartilhado:

1. **PNG:** dimensões e bounding box de alfa; abrir atlas sem conversão e conferir pixels nos frames realmente usados.
2. **Regiões:** confirmar UID resolvido, textura de cada AtlasTexture, coordenadas e tamanho da região de todas as poses; verificar que frame idle contém os pixels esperados.
3. **Animação:** confirmar SpriteFrames carregado, nome do clip, seleção do frame/idle, autoplay, chamadas posteriores a play, e que o frame selecionado não é vazio.
4. **CanvasItem:** observar visible, modulate, self_modulate, scale, z_index, show_behind_parent, canvas/layer e bounds reais do sprite, inclusive o offset do worker. Conferir transform/global position do pai e spawn final do alvo.
5. **Material:** bypassar o material/shader localmente em ambiente de diagnóstico; comparar render sem alterar o recurso compartilhado global. Se isso recuperar a imagem, isolar o parâmetro/código do shader antes de propor correção.
6. **Oclusão/posicionamento:** conferir ordem de desenho das paredes, plataformas e atores; posição em relação à viewport/câmera; clipping e sobreposição com cenário; repetir em cada fixture e com plataformas finais.

Corrigir apenas o primeiro estágio que demonstrar divergência. O shader atual guarda COLOR em vertex e combina textura/fator de modulação no fragment (scripts/enemy/enemy_hit_flash.gdshader:1–16); ele é fator compartilhado a investigar, não culpado presumido. Não redesenhar sprites nem substituir arte enquanto o fluxo de render não for localizado.

## B. Geometria e arte das paredes laterais

### Proposta de coordenadas

O retângulo visível da viewport é [0,1152] × [0,648]. Em ambas as salas, substituir as transformações dos nós LeftWall/RightWall (sem criar outros corpos):

| Parede | Centro | Shape | Faixa física e visual | Face interna |
|---|---:|---:|---:|---:|
| Esquerda | (32, 324) | 64×648 | x=0..64, y=0..648 | x=64 |
| Direita | (1120, 324) | 64×648 | x=1088..1152, y=0..648 | x=1088 |

Colocar preenchimento/laterais do atlas de fábrica existente alinhado à mesma faixa; célula fonte 32×32 px em escala 2× representa 64 unidades (docs/specs/2026-10-14-tileset-fases/spec.md:7–15). Repetir verticalmente e ajustar o último recorte para cobrir 648 unidades (10 células de 64 + 8 unidades). Priorizar a borda de fábrica já desenhada; não criar nova textura para esta proposta. Renderizar atrás das plataformas, inimigos, jogador e bola. O skin não adiciona colisão.

### Limites espaciais distintos

- **Retângulo técnico da sala para geração futura:** Rect2(64, 0, 1024, 648), área entre as faces internas. Se SolidPlatform._is_valid usar esse rect, aplicar wall_margin às dimensões completas e não deixar uma plataforma invadir a faixa de parede.
- **Centro seguro do player (cápsula atual):** com raio horizontal 14 e faces em 64/1088, centro entre x=78 e x=1074. É limite de corpo, não retângulo de geração das plataformas. A cápsula atual tem raio 14 e altura 76 (scenes/player.tscn:19–25); sprites/colisores maiores exigem bounds próprios.
- **Spawns:** manter os spawns atuais x=160 na main e x=128 em second_room dentro do espaço seguro. Manter worker/patrulha atual e verificar bounds do alvo após posicionamento final.
- **Teto:** não adicionar uma faixa visual ou collider novo. Manter o collider de teto atual. O topo continua sem parede visual, mas permanece fisicamente bloqueado; não afirmar que o nível precisa de teto visual fechado.

### Porta

ExitDoor está em (1080,522); sensor 96×108, máscara Player; o painel tem 48 unidades de largura (scenes/main.tscn:287–288, scenes/exit_door.tscn:5–28). A parede visual deve formar moldura/portal nesse trecho, sem desenhar opaco por cima do portal. A geometria física lateral continua sólida acima/abaixo e preserva a face limite do quarto. Verificar o sensor com o jogador junto à face x=1088; mover porta ou abrir collider somente se teste revelar bloqueio, preservando limite lateral sem duplicar collider. No modo gerenciado, Main.configure_run_managed remove a saída antes de entrar na árvore (scripts/world/main.gd:63–73); manter as mesmas paredes sem porta.

## C. Layout autoral para fixtures existentes

Usar dimensões e plataformas já existentes. Desligar randomize_position e randomize_width nas seis instâncias. Preservar espessura 24 e manter o piso. A tabela mostra centro, tamanho e topo (Y diminui para cima):

| Sala/plataforma | Centro proposto | Tamanho | Topo | Relação de salto nominal |
|---|---:|---:|---:|---|
| main / Floor | (576,604) | 1152×88 | 560 | início |
| main / PlatformA | (290,480) | 220×24 | 468 | sobe 92; spawn player x=160, vão horizontal até a borda 20 |
| main / PlatformB | (615,468) | 190×24 | 456 | sobe 12; vão entre bordas 120 |
| main / PlatformC | (915,452) | 190×24 | 440 | sobe 16; vão entre bordas 110; suporte autoral do alvo |
| second_room / Floor | (576,604) | 1152×88 | 560 | início |
| second_room / WestPlatform | (340,480) | 240×24 | 468 | sobe 92; spawn player x=128, vão horizontal até a borda 92 |
| second_room / UpperPlatform | (615,385) | 190×24 | 373 | sobe 95; vão entre bordas 60; suporte autoral do alvo |
| second_room / EastPlatform | (900,452) | 170×24 | 440 | sobe 67 no retorno para Upper; gap de aresta 105; queda de 67 no trecho Upper→East |

Gaps de aresta são calculados entre os limites horizontais das plataformas, não centros. Para o retorno mais exigente, East→Upper sobe 67 unidades. Com jump_velocity=640 e gravity=1600, a raiz descendente para essa altura é aproximadamente 0,676 s; a 260 unidades/s constantes isso daria 176 unidades contra gap de 105, cerca de 71 unidades de margem ideal. Esse teto teórico supõe velocidade horizontal máxima imediata; aceleração e colisões reduzem a margem, portanto não se afirma sucesso em jogo. Validar ida e retorno pelas rotas principais, controle, coyote time, corte do pulo e colisões; dash não deve ser obrigatório.

### Passagens no piso e obstáculos contornáveis

O espaço vertical entre o piso (y=560) e a face inferior de cada plataforma determina se há passagem por baixo; não inferir isso apenas pelo gap de salto. O collider do player mede 76 unidades de altura (scenes/player.tscn:19–25).

| Sala/plataforma | Face inferior | Folga até piso | Uso previsto no piso |
|---|---:|---:|---|
| main / PlatformA | y=492 | 68 | Obstáculo; não cabe a cápsula do player. A rota sobe para PlatformA. |
| main / PlatformB | y=480 | 80 | Não contar como passagem: restam só 4 unidades sobre a cápsula, sem margem de controle/corpo visual. Contornar pela rota sobre plataformas. |
| main / PlatformC | y=464 | 96 | Passagem nominal; cerca de 8 unidades além de corpo visual do herói estimado em 88, valor a confirmar. O GDD já prevê o worker de 64 unidades sob C (04-combate-e-builds.md:47). |
| second_room / WestPlatform | y=492 | 68 | Obstáculo; não cabe a cápsula do player. A rota sobe para WestPlatform. |
| second_room / UpperPlatform | y=397 | 163 | Passagem ampla. |
| second_room / EastPlatform | y=464 | 96 | Passagem nominal, sujeita à confirmação visual do herói. |

Assim, a rota primária não depende de atravessar sob A, B ou West: o jogador sobe para A/West e segue pela rota de plataformas. As faixas sob C, Upper e East permanecem passagens. A validação deve checar circulação dos corpos e legibilidade sem transformar cada corredor sob plataforma baixa em rota obrigatória.

### Suportes e spawns

- Atribuir suporte de TrainingTarget explicitamente por sala: PlatformC em main e UpperPlatform em second_room. Validar que o caminho aponta para SolidPlatform, é suficientemente largo para a colisão do alvo com margens e permanece válido após montagem; emitir aviso claro e fallback seguro se inválido. Não escolher posição aleatória dentre toda a lista.
- Calcular posição real do alvo depois de conhecer colisão e plataforma, usando topo e bounds da colisão. Não usar position da instância como evidência do ponto em jogo. Checar sprite (corpo visual 128 de altura nominal na escala 2), colisão, câmera e linha de tiro após essa posição.
- Preservar PlayerSpawnMarker/player em x=160 e x=128; manter RivetWorker no piso em x=650 e x=900, respectivamente, com patrulhas existentes x=420..920 e x=760..1040. Checar que a patrulha cabe no piso e que as laterais não mudam sua extensão útil.
- Nenhum spawn pode ficar dentro da parede, fora da tela, sob uma plataforma que o esconda ou sem superfície de apoio. O alvo e o worker precisam ter ao menos uma linha de tiro útil no fluxo de combate. Plataformas podem bloquear LOS como cobertura, mas não devem anular toda oportunidade de ataque.

## D. Geração aleatória futura

As fixtures presentes serão autorais e determinísticas. Se geração geral voltar a ser usada, manter seed definida antes de instanciar a sala e validar todas as plataformas após geração. A validação deve rejeitar layouts desconexos ou fora do retângulo técnico; incluir largura/altura real da cápsula do jogador, margem visual, espaço sob/ao redor das plataformas, caminho alcançável de ida e retorno, spawns e suportes de inimigos, patrol area, LOS, porta, câmera e ricochetes. Um grafo de transições deve considerar subida, descida e vão de borda com os valores atuais do MovementConfig, sem contar dash como requisito. Rejeitar bloqueios visuais que cubram sprites/spawns e respeitar mínimo de uma linha de tiro ao jogador para cada inimigo. Não definir quantidade/variação final de salas, progressão procedural ou encontro de chefe.

## Critérios de verificação

1. Inspeção da árvore e do render: ambos os inimigos, animações, frames, alfa, material, modulação, transforms, z e clipping em cada sala.
2. Inspeção física: faces internas nas coordenadas previstas, player/corpos permanecem entre x=64 e x=1088 com seus bounds, bola bate e ricocheteia na parede e retorna/parry continua intacto.
3. Jogabilidade: saltos Floor→A→B→C e Floor→West→Upper→East com o pulo normal; checar rota reversa/retorno, espaços de cabeça, cobertura e LOS do worker/target.
4. Integração: porta standalone próxima à parede, managed sem porta, segunda sala sem saída; câmera/viewport não corta a faixa visual.
5. Repetibilidade: fixture mantém mesmo layout ao iniciar repetidamente; alvo sempre ocupa suporte declarado; RunRoot permanece no placeholder atual (run_root.tscn:4–9).

Os critérios estáticos podem ser conferidos durante uma futura implementação autorizada. Abertura do Godot, importação, execução de gameplay e testes ficam pendentes até que o usuário peça explicitamente verificação/testes; o pedido de implementação sozinho não autoriza essas ações. Nenhuma validação runtime faz parte deste plano documental.