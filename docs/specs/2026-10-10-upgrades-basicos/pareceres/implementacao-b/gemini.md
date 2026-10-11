# Etapa B — Gemini 3.8 Flash High

Somente análise estática inline; modelo exato via AGY, modo plan. Sem aprovação de runtime.

STATUS: done
SUMMARY: Avaliação estática da Etapa B concluída sobre as fontes integrais fornecidas inline. A implementação satisfaz os requisitos arquiteturais e de fluxo: a máquina de estados em `Main` gerencia corretamente o ciclo de vida (`INACTIVE` -> `VICTORY_PENDING` -> `OFFER_OPEN` -> `SELECTED` -> `EXIT_RELEASED`, com ramificações `CANCELLED` e `COMPLETED`), a seleção única é idempotente e imune a cliques duplicados, a morte prevalece sobre a vitória em callbacks simultâneos, a pausa é restrita ao proprietário com UI em `PROCESS_MODE_WHEN_PAUSED`, os sweeps utilizam flags síncronas de parada retornando sem tocar árvore/física antes do flush, o cleanup engloba a bola própria e todos os `hostile_projectile` (inclusive rebites refletidos), a guarda de 0,25 s bloqueia somente ações discretas liberando locomoção/mira, a porta só libera em `EXIT_RELEASED` revalidando o overlap existente em novo pressionamento de E, e as bases da Etapa A foram estritamente preservadas.

CHANGED_FILES: none

TESTS: análise estática inline
1. Máquina de estados e fluxo da oferta (`main.gd`):
   - Transição ordenada: `_on_room_cleared` registra `VICTORY_PENDING` e enfileira resolução pós-flush via `call_deferred`.
   - Na Sala 01 (`reward_enabled = true`, `run_build.total_count() == 0`), abre `OFFER_OPEN`. Ao selecionar, assume `SELECTED`, aplica build ao jogador, atualiza HUD e comuta para `EXIT_RELEASED`.
   - Na Sala 02 (`reward_enabled = false` e sem `ExitDoor`), pula a oferta pós-flush e encerra diretamente como `COMPLETED`.
2. Seleção válida e rejeição de duplicatas (`main.gd`, `upgrade_offer.gd`):
   - `_on_upgrade_selected` valida `_upgrade_flow_state == OFFER_OPEN`, jogador vivo, ID presente na lista oferecida e ausência prévia na build (`MAX_UPGRADES == 1`).
   - O estado muda para `SELECTED` antes de mutar a build; cliques subsequentes ou sinais repetidos são imediatamente descartados pela checagem de estado e contagem.
3. Prevalência de morte simultânea (`main.gd`):
   - `_on_player_died` marca `_death_pending = true` e cancela o fluxo.
   - Em `_resolve_after_physics_flush`, a checagem de morte (`_death_pending` ou `player.is_dead`) antecede qualquer avaliação de vitória. A morte prevalece: fecha oferta, limpa build/snapshot, trava a porta, restaura pausa e chama `finish_death_after_physics`.
4. Callbacks assíncronos e cleanup pós-flush (`combat_room.gd`, `ricochet_ball.gd`, `hostile_rivet.gd`):
   - Nos callbacks de vitória/morte, `_request_hostile_projectile_stops` e `ball_launcher.request_stop_active_sweep` apenas ativam `_stop_sweep_requested = true`. Nenhuma mutação de colisão, remoção de nó ou `_finish` ocorre no callback.
   - Os loops de sweep em `RicochetBall` e `HostileRivet` verificam `_has_finished or _stop_sweep_requested` imediatamente após impactos, parries e bounces, abortando o processamento do frame sem efeitos colaterais.
   - O descarte efetivo (`cancel()`, remoção de camada e `queue_free`) é delegado a `cleanup_active_ball_after_flush` e `cleanup_hostile_projectiles_after_flush` após o flush de física e estritamente antes de abrir UI ou pausar.
   - Rebites redirecionados permanecem no grupo `hostile_projectile` e são expurgados no mesmo ciclo.
5. Propriedade da pausa e modos de processamento (`main.gd`, `upgrade_offer.gd`, `upgrade_offer.tscn`):
   - `_owned_offer_pause` registra se `Main` originou a pausa (`not get_tree().paused`). A despausa em `_close_owned_offer_pause` só atua se `_owned_offer_pause` for verdadeiro.
   - `UpgradeOffer` opera em `process_mode = PROCESS_MODE_WHEN_PAUSED` (valor 2). A raiz da gameplay permanece pausável por herança.
   - Teardown em `_exit_tree` limpa a oferta sem despausar a árvore, preservando o estado herdado pela cena sucessora.
6. Guarda de input de 0,25 s e prioridade de consulta (`main.gd`, `player.gd`, `racket_controller.gd`, `exit_door.gd`):
   - `DISCRETE_INPUT_ACTIONS` restringe o bloqueio a `launch_ball`, `parry`, `dash`, `jump` e `interact`. Movimentação horizontal (`move_left`/`move_right`) e mira (`aim_controller`) não integram a lista e operam livremente.
   - `_begin_input_guard` detecta teclas retidas (`_any_discrete_input_pressed`), aguardando liberação para iniciar a contagem regressiva de `post_upgrade_input_guard_seconds`.
   - Novas ações discretas em `_input` ou `_process` durante a guarda consomem o evento via `set_input_as_handled` e reiniciam o intervalo quieto.
   - Ordem de execução: `RacketController` (prioridade de física -100) consulta `player.is_discrete_input_blocked(&"parry")` antes de registrar o golpe; `Player` consulta antes de disparar pulo/dash/lançamento; `ExitDoor` consulta antes de despachar a interação.
7. Comportamento da porta e interação E (`exit_door.gd`, `main.gd`):
   - A porta só aceita transição no estado `EXIT_RELEASED`.
   - Jogador posicionado previamente na área mantém registro em `_players_in_range`. No novo pressionamento de E, `_get_live_player_in_range` revalida `is_player_in_range` via `get_overlapping_bodies` e confirma se o jogador está vivo sem demandar nova saída/entrada física.
8. Preservação da Etapa A e HUD:
   - Duplicações profundas (`duplicate(true)`) garantem integridade dos recursos `.tres`.
   - `RoomTransition` preserva schema v1, validação canônica e consumo único do snapshot.
   - Build é aplicada antes de `_release_exit_or_complete`, e o HUD reflete `"BUILD: " + display_name.to_upper()` em `CombatRoom/HUD/BuildLabel`.

RISKS:
1. `scripts/world/exit_door.gd`: linha 46 — Prioridade Baixa — Condição: a guarda inicial em `_unhandled_input` descarta eventos onde `not event is InputEventKey`. Se futuramente a ação `interact` for associada a botões de gamepad ou clique de mouse, a interação não será processada por esta checagem restritiva. Para o escopo do teaser em teclado/PC (tecla E), o comportamento é funcional e estável.
2. `scripts/world/exit_door.gd`: linha 54 — Prioridade Baixa — Condição: dupla verificação de input (`key_event.is_action_pressed("interact")` e `Input.is_action_just_pressed("interact")`). Como `_input` em `Main` já consome o evento durante a oferta e a guarda, a redundância é inofensiva no fluxo atual, mas depende de sincronia entre o evento de chave e o buffer global da ação.

NEXT_STEP: Registrar parecer formal estático da Etapa B e disponibilizar o repositório estável para o início da Etapa C (carga energética e contrato booleano de dano dos inimigos). Sem aprovação de runtime nesta fase.

