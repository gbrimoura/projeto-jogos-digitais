# Registro de implementação

Branch de trabalho: corrigir-sprites-salas-plataformas; baseline 90b2e592bd70e1b2ff3e5828af8a9029031e1c66.

Antes das edições de runtime, salvei cópias prospectivas dos seis arquivos que já existiam e seus SHA-256 em baseline-90b2e59/sha256.json. O novo scripts/world/factory_wall_visual.gd não existia no baseline. V1, V2, V3 e a documentação de planejamento foram preservadas.

## Resultado

As duas fixtures agora desenham laterais usando o atlas de fábrica existente: WallVisuals fica em z=-1, entre o fundo em -10 e o piso em 0. Cada lateral desenha dez blocos 64×64 e um recorte final de quatro pixels da célula-fonte, totalizando 64×648; nearest mantém a escala pixelada. As células usadas são (0,1) à esquerda e (2,1) à direita. Os colliders laterais medem 64×648 e ficam centrados em (32,324) e (1120,324). Piso 1152×88 e teto existente foram mantidos. A porta de Main já estava em (1040,522), com sensor herdado 96×108, e continua removida na configuração managed; não há abertura física nas paredes nem porta em SecondRoom.

As seis plataformas receberam posições e flags determinísticas nas cenas:

| Fixture | Plataforma | Centro | Tamanho |
| --- | --- | ---: | ---: |
| Main | PlatformA | (290,480) | 220×24 |
| Main | PlatformB | (615,468) | 190×24 |
| Main | PlatformC | (915,452) | 190×24 |
| SecondRoom | WestPlatform | (340,480) | 240×24 |
| SecondRoom | UpperPlatform | (615,385) | 190×24 |
| SecondRoom | EastPlatform | (900,452) | 170×24 |

Cada instância desativa randomize_position e randomize_width. O TrainingTarget usa suporte primário/fallback fixos por caminho relativo, começa na posição calculada e validada antes de entrar em processamento, e desativa seu posicionamento aleatório apenas nas duas fixtures.

## Validação e fluxo

Main.prepare_authored_layout() -> bool é idempotente e lê coordenadas, nós e shapes locais antes de _ready, sem @onready, transforms globais ou espaço físico. Valida os seis centros/tamanhos, flags, transforms e RectangleShape2D; cria AABBs estáticos para colisões World layer 1; verifica spawn de jogador e Worker separadamente, faixa completa de patrulha, alvo vivo em layer 8 e Player.collision_mask == 9, suporte com largura/margem, contato vertical e sobreposição positiva acima de 0,01.

Standalone valida em _enter_tree, antes do _ready dos filhos. Falha bloqueia Player, Worker, alvo, combate, input, porta e resolução de sala; apresenta erro de layout e botão de reinício. Managed valida antes de remover ExitDoor ou adicionar a sala à árvore. RunController descarta a sala inválida e encaminha a causa a _fail_run; não anuncia vitória. Os gates do alvo e do Worker mantêm a inscrição em combat_enemy antes de desativar processamento em sala inválida. Sem authored_layout_enabled, o comportamento legado permanece ativo.

Funções adicionadas ou alteradas para revisão:
- main.gd: preparação/cache, validação de plataformas, spawns, patrulha, obstáculos e alvo; falha/restart; gates em _enter_tree, _ready, _input, _physics_process, is_gameplay_action_blocked, _on_room_cleared e _resolve_after_physics_flush; configure_run_managed agora valida antes de remover a porta.
- training_target.gd: exports de suporte autoral; _ready aplica posição pré-validada no modo autoral e preserva a colocação antiga fora dele; _parent_room_allows_enemy_activation bloqueia ativação em sala inválida.
- rivet_worker.gd: _ready mantém grupos e bloqueia configuração/ativação se o layout autoral do pai for inválido.
- run_controller.gd: falha de configure_run_managed inclui o diagnóstico de layout antes de descartar a instância pré-árvore.
- factory_wall_visual.gd: novo helper local, sem class_name, que desenha o atlas nearest e recorta os quatro pixels finais.

## Diagnóstico estático dos sprites

Não encontrei causa estática conclusiva para os corpos invisíveis. Os nós BodySprite não declaram visible = false; as linhas de visibilidade falsa próximas pertencem a BodyBorder e outros overlays. Os recursos SpriteFrames apontam aos atlas PNGs e regiões usados por idle/impact e idle/walk/aim/fire/recovery. Os arquivos .import preservam o canal alpha (mapeamento alpha=3), não geram mipmaps e não usam alpha premultiplicado. Os shaders/materials de hit-flash foram mantidos: a configuração de COLOR revisada pelo agente principal é um padrão válido, sem divergência estática observada. Como não foi autorizada execução/renderização, import final e visibilidade no frame de jogo continuam pendentes; não afirmo que esta implementação corrija a invisibilidade.

## Validação executada e limites

A validação foi somente leitura estática de cenas, scripts, recursos de frames, metadados de import e atlas. Não executei Godot, importação, runtime, testes ou QA visual conforme instrução. Os corpos, rota/LOS, aparência final das paredes e comportamento da porta após interação continuam sem observação em jogo.