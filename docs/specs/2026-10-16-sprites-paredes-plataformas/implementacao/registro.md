# Registro de implementação

Branch de trabalho: corrigir-sprites-salas-plataformas; baseline original 90b2e592bd70e1b2ff3e5828af8a9029031e1c66.

Antes das edições originais de runtime, salvei cópias prospectivas dos seis arquivos então existentes e seus SHA-256 em baseline-90b2e59/sha256.json. O novo scripts/world/factory_wall_visual.gd não existia no baseline. V1, V2, V3 e a documentação de planejamento foram preservadas.

Antes desta rodada de correções, também salvei R1 em baseline-r1-precorrecao/sha256.json, com cópias dos arquivos de cena, validador, helper e deste registro. Esse snapshot conserva exatamente o estado anterior às correções descritas abaixo. Antes desta correção final, salvei R2 em baseline-r2-precorrecao/sha256.json, preservando scenes/main.tscn e scripts/world/main.gd com seus hashes pré-edição.

## Resultado

As duas fixtures desenham paredes laterais com o atlas de fábrica existente. WallVisuals fica em z=-1, entre o fundo em -10 e o piso em 0. Cada lateral desenha dez blocos 64×64 e recorta quatro pixels da célula-fonte para o trecho final de 64×8, totalizando 64×648. O helper usa nearest e reflete horizontalmente a célula inteira e o recorte final; os acabamentos das células (0,1) e (2,1) ficam voltados para dentro.

Os colliders laterais medem 64×648 e ficam centrados em (32,324) e (1120,324). O piso segue 1152×88 e o teto existente é preservado. A cena Main original tinha a porta em (1080,522); ela foi movida para (1040,522), onde o sensor herdado 96×108 cobre x=992..1088. A configuração managed remove a porta, e não há abertura física na parede nem saída em SecondRoom.

As seis plataformas têm posições e flags determinísticas:

| Fixture | Plataforma | Centro | Tamanho |
| --- | --- | ---: | ---: |
| Main | PlatformA | (290,480) | 220×24 |
| Main | PlatformB | (615,468) | 190×24 |
| Main | PlatformC | (915,452) | 190×24 |
| SecondRoom | WestPlatform | (340,480) | 240×24 |
| SecondRoom | UpperPlatform | (615,385) | 190×24 |
| SecondRoom | EastPlatform | (900,452) | 170×24 |

Todas as instâncias desativam randomize_position e randomize_width. Main grava explicitamente os shapes físicos de Floor (1152×88) e das plataformas A (220×24), B e C (190×24), cada qual local à cena. SecondRoom já continha o override explícito de Floor (1152×88) e dos três shapes das plataformas. A validação verifica esses shapes antes de qualquer _ready. Em Main, o piso usa a skin de bloco (factory_surface_style=1) e A/B/C usam a skin de plataforma (style=0), com factory_skin_enabled=true nas quatro instâncias.

O TrainingTarget usa suporte primário/fallback por caminho relativo, posição fixa calculada e pré-validada, e spawn aleatório desligado nas duas fixtures. O getter de posição autoral devolve Vector2 somente para o alvo validado em layout preparado; fora desse caso (incluindo layout desativado/inválido), devolve null, que o caller já valida pelo tipo.

## Validação e fluxo

Main.prepare_authored_layout() -> bool é idempotente e trabalha com coordenadas, nós e shapes locais antes de _ready, sem @onready, transforms globais ou espaço físico. Agora detecta exatamente uma das duas trincas de plataformas; rejeita plataforma desconhecida, fixture incompleta/mista e membro ausente. Verifica também Floor e os três shapes de WorldCollision. A coleta de obstáculos usa StaticBody2D com World layer 1 e ignora Area2D.

O validador constrói AABBs estáticos, verifica spawn de jogador e Worker separadamente, faixa completa de patrulha, alvo vivo em layer 8 e Player.collision_mask == 9, largura/margem do suporte, contato vertical e sobreposição positiva acima de 0,01. Os deslocamentos de AABB usam Rect2(posição + deslocamento, tamanho), sem Rect2.translated.

Standalone valida em _enter_tree, antes do _ready dos filhos. Falha bloqueia Player, Worker, alvo, combate, input, porta e resolução de sala; apresenta erro de layout e botão de reinício. Managed valida antes de remover ExitDoor ou adicionar a sala à árvore. RunController descarta a sala inválida e encaminha a causa a _fail_run; não anuncia vitória. Os gates do alvo e Worker preservam a inscrição em combat_enemy antes de desativar processamento em sala inválida. Sem authored_layout_enabled, o comportamento legado permanece ativo.

Funções adicionadas ou alteradas para revisão:
- main.gd: _detect_authored_platform_set e _matches_authored_platform_set selecionam/rejeitam fixtures; _validate_authored_room_boundaries valida piso e paredes; prepare_authored_layout, validação de spawns, patrulha, obstáculos e alvo; gates de fluxo; configure_run_managed valida antes de remover a porta.
- training_target.gd: exports de suporte autoral; _ready aplica posição pré-validada no modo autoral e preserva a colocação antiga fora dele; _parent_room_allows_enemy_activation bloqueia ativação em sala inválida.
- rivet_worker.gd: _ready mantém grupos e bloqueia configuração/ativação se o layout autoral do pai for inválido.
- run_controller.gd: falha de configure_run_managed inclui o diagnóstico antes de descartar a instância pré-árvore.
- factory_wall_visual.gd: helper local, sem class_name, que desenha o atlas nearest, reflete ambos os segmentos e recorta o trecho final.

## Diagnóstico estático dos sprites

O log preexistente da execução de 16/10/2026 às 15:24 identifica falha de carregamento/importação para os sprites invisíveis: os caches training_target-atlas...ctex e rivet_worker-atlas...ctex não foram encontrados; em seguida os recursos SpriteFrames falharam ao carregar e o log registrou animações idle/walk/aim ausentes. As evidências preservadas em evidencias/log-importacao-existente.txt e evidencias/log-origem.json incluem o caminho de origem e SHA-256 do log. Isso aponta à falta dos imports locais nessa execução, sem evidência para alterar shader ou arte. BodySprite não declara visible=false; os false próximos pertencem a BodyBorder e overlays. Os .import indicam as texturas PNG de origem; alpha e materiais não foram alterados. A reimportação para regenerar os .ctex está pendente de autorização explícita e não foi executada.

## Validação executada e limites

A validação desta rodada incluiu inspeção estática das cenas/scripts e leitura do log preexistente preservado acima. Não executei Godot, importação, runtime, testes ou QA visual. A reimportação dos PNGs para gerar os .ctex permanece pendente de autorização; aparência das paredes e interação final da porta ainda não foram observadas em runtime.

## Fechamento da revisão estática

Gemini e Muse concluíram R2 sem P1/P2 após as correções. Grok forneceu parecer útil em R1; R2 terminou com exit0 e somente CRLF, sem parecer aproveitável. Claude Opus via Cursor ficou indisponível por limite de uso nas duas rodadas. Consulte [pareceres, decisões e limites](pareceres.md). Saídas originais e hashes de runtime estão nas pastas pareceres-r1 e pareceres-r2. Implementação estática integrada; reimportação e aceite em jogo pendentes; sem commit ou push.

