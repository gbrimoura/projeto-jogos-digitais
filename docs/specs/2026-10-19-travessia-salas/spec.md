# Especificação — travessia física e transição entre salas

**R3 · 19/10/2026 · Contrato de implementação; ainda sem runtime nesta gravação.**

## Geometria e gate

Em ambas as fixtures, `WorldCollision` recebe shapes direitos: `RightWallUpper` centro (1120,216), size64×432; `RightWallLower` (1120,604), 64×88; `ExitGate` (1120,496), 64×128; `RightOuterGuard` (1156,324), 8×648. O vão segue x=[1088,1152), y=[432,560); o piso mantém topo560 e width1152. LeftWall continua sólido. Gate inicia ativo, é aberto por `set_deferred("disabled", true)` após liberação local e nunca é removido. O validador exige nós/dimensões/transform independentes do estado disabled; `_collect_authored_world_obstacles` segue considerando shapes ativos, guard é exterior e não afeta spawns/patrulha. Em terminal standalone o gate não abre.

## Amostragem e lock

ExitDoor (sem depender de `body_entered`/`get_overlapping_bodies`) consulta o Player da mesma sala a cada physics frame. Centro do collider: transformar `CollisionShape2D.shape.get_rect().get_center()` pelo `global_transform` da shape e depois para coordenadas locais da porta. Não usar Player.global_position.y: é o pé em y560, enquanto o centro está em y522 no piso. Linha de saída x=1120 local/global conforme transform da sala; y e x devem estar no retângulo do vão.

A primeira amostra só inicializa histórico. Cruzamento latch quando `previous_x < line_x && current_x >= line_x && current_x > previous_x`, centro atual dentro do vão, saída unlocked e não busy. Não exigir velocity final: colisão com OuterGuard pode zerá-la no mesmo frame. Unlock inicializa `previous=current` e arma só se jogador ainda está antes da linha. Após rollback standalone, desarmar até centro recuar para x<line, então atualizar amostra; nova tentativa exige cruzá-la de novo. Managed não faz retry.

Door emite evento latched; Main faz `call_deferred` e antes de lock revalida token, sala fonte ativa, `EXIT_RELEASED`, clear, oferta local concluída, guard off, jogador correto/vivo, gate liberado, latch e geometria atual no vão além da linha. Revalidação é geométrica, sem consultar overlap da Area nem repetir a condição previous<line. No sucesso: gravar `Player.disable_mode` e `process_mode`; set `disable_mode=KEEP_ACTIVE` antes de `process_mode=DISABLED`; zerar velocity. Em rollback: restaurar process_mode primeiro, depois disable_mode original; gate aberto. Pause/reset UI bloqueada enquanto busy. Morte/restart cancela token e helper; normal `_exit_tree` de Main no swap esperado não limpa snapshot.

## Fade, swap e recuperação

Overlay CanvasLayer único, layer acima do HUD, `PROCESS_MODE_ALWAYS`, transparente não captura mouse. Fade alpha0→1 ~180ms, swap em preto, alpha1→0 ~220ms. Standalone nunca modifica `SceneTree.paused`. Carregar PackedScene antes do fade; snapshot HP atual/máximo+Build é criado só no preto, logo antes do swap, se token válido e `tree.current_scene == source`. Helper fica na raiz (não Main), valida dono/token; depois do swap espera `current_scene != source`, válida e ready, até120 `process_frame`s. Sucesso revela nova sala e se libera. Erro imediato limpa snapshot, revela antiga e rollback/retry. Se source já saiu mas nova cena não fica ready, limpar snapshot, revelar o que existir e destruir overlay; sem preto permanente. Cancelamento de Tween/overlay em death/restart não pode deixar await pendurado; token/timer cancelável sempre termina cleanup.

Managed: RunController é dono do fade, mantém pause ownership, resolve RewardScreen de chefe existente após cruzamento e só depois troca para sala PackedScene nova. Nunca reutiliza Player nem RoomTransition snapshot; permanece HP/build atuais. Após cada await, revalidar `_run_ended` e sala concluída ainda atual. Se for dona da pausa, só despausa em sucesso normal; GameOver/vitória ficam pausados e visíveis. Falha managed revela erro e segue GameOver/restart, sem retry/recompensa duplicada. Standalone sem destino decide terminal antes de unlock: gate fechado, `ETAPA CONCLUÍDA`.

## Adendo R2 — 19/10/2026

O freeze R2 preserva o contrato R3 com quatro correções de validação e recuperação e um ajuste do tempo gerenciado:

1. A posição usada na validação deferred e pós-lock é a atual: centro do collider `x >= line_x` e dentro do vão. O evento latched já garante a sequência anterior de avanço; a validação não usa histórico nem velocidade final.
2. No timeout após swap aceito, o overlay mantém o snapshot durante o fade de recuperação. Main só desfaz o lock e limpa o snapshot se token, transição e cena fonte ainda forem os atuais. Se uma nova cena pronta assumir durante esse fade, o rollback é recusado e o snapshot é preservado; se a fonte já saiu sem nova cena pronta, o caminho de recuperação limpa o snapshot.
3. A mensagem de falha da porta precede o rótulo busy. O convite a recuar e tentar novamente só aparece com retry habilitado. Managed continua armado no unlock inicial e permanece desarmado após falha sem retry.
4. O gate é considerado aberto quando `ExitGate.disabled` é `true`, coerente com sua abertura adiada após clear e recompensa local.

O atraso de progressão gerenciada agora tem default e mínimo `0.0`, iniciando o fade imediatamente por padrão. Overrides positivos preservam o status com contagem e aguardam o timer; no valor zero, o HUD informa a preparação sem criar timer. A checagem de estado posterior permanece para overrides positivos.

## Escopo e aceite

Alterar apenas 7 runtime: `exit_door.gd/.tscn`, `main.gd`, `run_controller.gd`, novo `room_transition_overlay.gd`, `main.tscn`, `second_room.tscn`; não editar RoomTransition sem necessidade comprovada. Aceite estático: shapes/validador corretos; gate depende de clear/recompensa local/guard; entrada fechada; cruzamento geométrico +X único; E/proximidade não transita; rollback precisa recuo/recruzamento; snapshot só em swap standalone válido; managed mantém boss reward/HP/build e nova instância; terminal fechado; cancel/restart/death sem tela preta, pause ou lock órfãos. Sem Godot/import/testes/QA. Arte, Player/movement, piso, spawn, gerador, inimigos, resources, imports, project/plugin/settings e Git ficam intactos.
