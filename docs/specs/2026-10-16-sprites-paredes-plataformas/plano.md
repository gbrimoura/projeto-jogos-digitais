# Sprites dos inimigos, paredes laterais e plataformas

**Versão:** V3, revisada documentalmente em R3; implementação pendente.  
**Estado:** plano de implementação futura; esta entrega alterou somente documentação.  
**Branch/base:** `corrigir-sprites-salas-plataformas`, main `90b2e59`.  
**Escopo:** fixtures existentes `main` e `second_room`; sem fechar regras do GDD.

## Objetivo e decisão

Investigar o relato de inimigos invisíveis, tornar visíveis as paredes laterais e propor plataformas reproduzíveis com suporte previsível para TrainingTarget. A causa de invisibilidade não foi provada por leitura estática, então arte não deve ser refeita nem shader removido sem localizar uma divergência.

Proponho manter limites laterais sólidos em toda a altura e desenhar as faixas dentro do viewport com o atlas atual. ExitDoor standalone é só sensor/interação para troca de cena; não cria abertura na parede. As seis plataformas ficam fixas nas posições da spec e TrainingTarget escolhe suporte primário/fallback determinísticos. Antes de entrar no combate, Main valida a fixture fora da árvore e rejeita layout inválido.

## Fatos e hipóteses

Viewport é 1152×648. Os atuais colliders laterais estão em x=-16 e 1168, inteiramente fora do quadro; teto já bloqueia fisicamente y=-32..0. O player nasce em (160,560) em main e (128,560) em second_room. As cápsulas 28×76 deixam 6 unidades até a primeira borda de A e 78 até West; os valores centro-a-borda são 20 e 92. ShotOrigin fica em (0,-38), e BallLauncher deriva snapshot da configuração e testa o spawn com cast/consulta de forma. Preservar esse fluxo e as máscaras. Referências e inventário estão na spec.

ExitDoor não tem corpo físico: é Area2D layer0/mask2 que emite transição após sala limpa + E. Managed remove a porta. TrainingTarget atual tem collider 72×96 e sorteia plataforma/X em vez de respeitar posição serializada; worker tem corpo 46×64 e patrulhas já cabem entre as novas faces internas.

O relato de invisibilidade é fato, mas causa permanece hipótese entre imagem/alpha, import/UID/região, frame/clip, transform/modulate, material/shader, canvas/z, clipping e oclusão/spawn. O atlas tem pixels alfa; não é prova de render correto.

## Plano por etapas

**Etapa 1 — isolar sprites.** Se o usuário pedir explicitamente verificação/testes em Godot, percorrer a sequência da spec por TrainingTarget e RivetWorker e registrar o primeiro estágio divergente. Corrigir só essa causa local. Não remodelar atlas/arte por tentativa. Critério visual/ataques/LOS fica pendente até execução autorizada; se não localizar causa, preservar arte e reportar inconclusivo.

**Etapa 2 — limites visuais e porta.** Em cada fixture, substituir apenas os colliders laterais por retângulos 64×648 centrados (32,324) e (1120,324). Adicionar `WallVisuals` z=-1 entre SandboxVisual (-10) e Floor (0), com `LeftWallVisual`/`RightWallVisual` nas posições x=0 e 1088. O helper obrigatório `scripts/world/factory_wall_visual.gd` desenha nearest as células atuais do atlas; espelhar/orientar acabamento para dentro se necessário. Dez segmentos 64×64 e recorte final 64×8 fecham 648 unidades. Piso segue 1152×88, cobre a visualização entre y=560..648 e sobrepõe colisores nos cantos sem vão. Teto fica fisicamente bloqueado, sem parede visual superior.

Mover ExitDoor de Main para (1040,522): sensor x=992..1088, painel x=1016..1064. Interação ocorre dentro do sensor após sala limpa; jogador não atravessa a parede. Managed remove a porta, a parede não tem cutout e second_room não ganha saída.

**Etapa 3 — fixture autoral e validação antes de spawn.** Desativar `randomize_position` e `randomize_width` nas instâncias existentes das seis plataformas e aplicar a tabela da spec. Criar `Main.prepare_authored_layout() -> bool`, idempotente, usando somente coordenadas locais e shapes declarados, sem `@onready` nem consultas ao espaço físico. Managed chama antes de `add_child`; standalone chama em `_enter_tree`, antes de os filhos entrarem/prontos. Validar os AABBs de player/worker/alvo, suportes e World layer1 conforme tolerâncias da spec. Não construir validador geral ou alterar gerador procedural.

TrainingTarget nas duas fixtures recebe `fixed_support_path` e `fallback_support_path` relativos ao próprio alvo; modo autoral explícito faz o alvo usar a posição calculada já validada em `_ready`, sem `randf_range` ou colocação deferida. Caminhos primário/fallback: Main `../PlatformC` / `../PlatformA`; second_room `../UpperPlatform` / `../WestPlatform`. Primário inválido tenta somente fallback; se ambos falharem, rejeitar sala. Fora das duas fixtures, modo autoral desligado conserva comportamento existente.

RunController valida/configura antes de `room_container.add_child`; falha descarta a sala, chama `_fail_run` e não conta vitória. Standalone Main valida em `_enter_tree`, antes do `_ready` dos filhos. Se falhar, marcar estado antes dos inimigos, bloquear ativação e input, manter porta bloqueada, exibir erro e opção de reinício após a árvore pronta; sem `room_cleared`, vitória ou spawn duplicado. Se necessário, gate mínimo nos inicializadores de TrainingTarget/RivetWorker. Nenhum caminho de falha restaura layouts, cria alvo extra ou sorteia coordenadas.

Layout e suporte não devem exigir dash. A rota para Upper precisa permitir combate com alvo sólido no caminho; validar passagem ao redor do alvo e travessia completa após `queue_free` na derrota. East→Upper tem margem balística teórica, não comprovada em movimento.

## Arquivos previstos

- `scenes/main.tscn`, `scenes/second_room.tscn`: paredes existentes, visuals, posições/flags das plataformas, paths/flags do alvo e ExitDoor standalone.
- `scripts/world/main.gd`, `scripts/world/run_controller.gd`: preparação/validação autoral e falha antes de adicionar/ativar a sala.
- `scripts/world/training_target.gd`: suporte por path e posição determinística, gate quando sala inválida.
- `scripts/enemy/rivet_worker.gd`: somente gate de ativação em sala inválida se a arquitetura exigir.
- `scripts/world/factory_wall_visual.gd`: helper visual obrigatório, local e sem `class_name`.
- Recursos de sprite/atlas/shader somente se a sequência encontrar causa. Não alterar `scripts/world/solid_platform.gd`, BallLauncher, GDD, TileSet existente ou arte sem evidência.

## Invariantes e aceite

Preservar RunRoot, câmera fixa, spawns, player, Worker, interação standalone/managed, movement, salto, parry, ShotOrigin, snapshot/cast da bola, collision masks, ricochete, retorno, AoE, colisões e cadência. Nenhuma câmera, pickup ou arte nova.

Aceitar quando: sprites forem legíveis nos clips realmente usados, sem atirar através de obstáculos; paredes visuais coincidirem com retângulos sólidos x=0..64 e x=1088..1152; piso/teto/ricochetes/retorno continuarem coerentes; porta standalone funcionar sem atravessar a parede e managed seguir sem porta; layouts forem reproduzíveis e validados antes do combate; suporte primário/fallback estiver centrado, apoiado e sem RNG; spawns não tiverem interseção positiva com obstáculos; rotas e LOS forem conferidos sem dash obrigatório. Os limites quantitativos e estados estão detalhados na spec.

## Verificação e rollback

Esta tarefa alterou somente documentação; nenhum Godot/import/runtime/teste foi executado. Implementar não autoriza, por si só, abrir/executar/importar Godot nem rodar testes; isso exige pedido explícito de verificação/testes. Etapas independentes podem avançar com revisão estática após autorização de implementação, deixando critérios visuais e de rota como pendentes quando não testados.

Antes de cada etapa, salvar SHA-256 dos arquivos runtime tocados. Baseline inicial 90b2e59; cada etapa aceita define baseline para a seguinte. Reverter apenas os arquivos da etapa rejeitada, nunca reset global nem alterações alheias. Geração procedural e regras futuras seguem pendentes do GDD.

Revisão final: Gemini, Muse, Grok e Opus via Antigravity encerraram R3 sem bloqueios documentais. Opus via Cursor indisponível por quota. [Pareceres, limites e clarificações do principal](pareceres/README.md). Nenhuma implementação runtime nesta entrega.
