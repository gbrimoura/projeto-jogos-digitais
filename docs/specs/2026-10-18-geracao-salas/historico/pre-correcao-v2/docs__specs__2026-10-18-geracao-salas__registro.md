# Registro — geração coordenada de salas

## Baseline

Em 18/10/2026, antes das edições runtime, foram guardados snapshots locais e hashes SHA-256 dos scripts e cenas existentes, incluindo alterações sem commit da tarefa anterior. Consulte `historico/baseline-pre-implementacao/sha256.json`; nenhuma cópia foi obtida de `HEAD`. A primeira versão do plano/spec foi preservada em `historico/plano-v1.md` e `historico/spec-v1.md` antes de receber esclarecimentos após a revisão do plano.

## Implementação

**Estado:** implementação escrita e congelada para revisão; sem validação de runtime.  
**Seed:** `room_layout_seed = 0` randomiza uma vez por instância; qualquer seed explícita diferente de zero reproduz um layout. Um único RNG coordena os sorteios. O helper tenta até 32 layouts e usa fallback declarado; se falhar, a sala managed não entra na árvore e a standalone mantém o overlay/gates existentes. O Main registra a seed efetivamente usada.

**Geometria:** viewport 1152×648; parede x=0..64/1088..1152; piso y=560. Plataformas espessura24, largura múltipla de8 dentro de104..216 (fixtures atuais sorteiam160..216), primeira top440 e edge x=208..256, com margem de24px além do bounds do spawn. Rota ordenada por X, não descendente, gaps56..96; a subida acumulada de toda a rota é limitada a64px, com topo mínimo376; bottom<=464 assegura folga física de96px até o piso. Fallback de três instâncias: centros (320,452), (590,412), (860,388), larguras200/184/184. Limites são locais a esta tarefa, não contagem ou regra final do GDD.

**Contratos:** `prepare_authored_layout()` é idempotente e aplica posição/tamanho/shapes em `_enter_tree` standalone ou em `configure_run_managed()` antes de `add_child`/`_ready`. `get_prepared_authored_target_position()` mantém a integração determinística do TrainingTarget. A plataforma da direita é o suporte primário mais alto pela rota não descendente (última em empate); a primeira é fallback. `is_authored_layout_valid()` e `get_authored_layout_error()` preservam a interface de RivetWorker/RunController.

`ExitDoor` gerenciada permanece visível; a sala resolve-a pelo caminho exato `ExitDoor`, sem procurar grupo/tipo compartilhado com a entrada. Recompensa e guarda encerram antes do unlock. O handler verifica clear, player vivo/correto, guarda e alcance no pedido e no deferred, e só então emite o sinal de progressão uma vez. Falha deferred libera a porta para nova tentativa sem sinal; morte ou clear inválido volta a trancá-la. Falha de layout managed retorna antes de adicionar a sala; RunController libera a instância e apresenta falha no HUD com restart. Main standalone conserva snapshot HP/build e RoomTransition; SecondRoom standalone exibe `ETAPA CONCLUÍDA`. A entrada em (112,522) não tem sensor nem interação. Teto visual nearest usa o atlas existente, uma linha de 18 tiles da fonte 32px ampliados a64px, com a face acabada para baixo, e colisão y=0..64 ligada ao teto existente.

## Arquivos runtime alterados

- `scripts/world/main.gd`
- `scripts/world/exit_door.gd`
- `scripts/world/room_layout_generator.gd` (novo)
- `scripts/world/factory_ceiling_visual.gd` (novo)
- `scenes/main.tscn`
- `scenes/second_room.tscn`

`run_controller.gd`, `training_target.gd`, `solid_platform.gd` e `exit_door.tscn` não foram alterados. Os UIDs locais de `factory_wall_visual` foram preservados. A revisão inline do plano foi coordenada pelo agente principal; os esclarecimentos foram registrados na versão atual, com a primeira versão preservada.

## Verificação e riscos

TESTS: none. Por instrução, não foram executados Godot, importações, testes ou QA. Apenas leitura estática de fontes/cenas/docs; validar alcance de salto e integração/jogabilidade continua pendente.

RISKS: subida inicial de120px fica8px abaixo do limite teórico128 e não comprova que o salto funciona; segmentos de salto de até64px e gaps de até96px precisam de verificação no jogo. Bounds geométricos não comprovam conforto visual ao andar nem legibilidade do teto/portas. Parse de GDScript e carregamento de `.tscn` não foram confirmados no engine.

NEXT_STEP: revisão read-only do estado congelado; depois, abrir a tarefa separada de execução/QA em Godot para validar parse, integração e saltos.
