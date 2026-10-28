# Plano — travessia e transição entre salas

**19/10/2026 · R3 prospectivo; contrato autorizado após revisão arquitetural.**

## Objetivo e base

Após clear, recompensa local e guard, o jogador atravessa a saída lateral andando para a direita, sem E. Manter a entrada fechada, HP/build, morte/restart e terminal. R3 incorpora o delta do principal em `pareceres/plano-r3-delta-input.txt` e README de pareceres; R1/R2 estão preservados em `historico/`. Fonte: docs/README, AGENTS, planos/specs de porta lateral, geração e game loop, GDD §3.

## Decisões executáveis

- RightWall superior/inferior: 64×432 em (1120,216) e 64×88 em (1120,604); gate 64×128 em (1120,496); RightOuterGuard 8×648 em (1156,324), todos como shapes de `WorldCollision`. Gate começa sólido, abre por `set_deferred(disabled=true)` após clear+recompensa local+guard, nunca é freed. Validador confere nomes/geometrias sem depender do disabled já aplicado; guard mantém retry dentro do mapa.
- ExitDoor amostra Player conhecido da mesma sala em todo physics frame, independentemente de sinais/overlaps de Area. Usa centro real do `CollisionShape2D` transformado para a porta; Player.origin é os pés (y=560), não o centro (y=522). Cruza se `previous_x < 1120 <= current_x`, `current_x > previous_x`, e centro dentro do vão. No unlock, amostra é inicializada em current; retry standalone rearma somente após recuar abaixo de 1120. Revalidação deferred usa latch do cruzamento e geometria atual, nunca exige Area overlap ou velocidade positiva final.
- Só após revalidar source/state/player viva/clear/local reward/guard/gate/latch/yx, Main salva `disable_mode` e `process_mode`, define `KEEP_ACTIVE` antes de `PROCESS_MODE_DISABLED`, zera velocity e prossegue. Rollback restaura process_mode antes do disable_mode; gate fica aberto e retry requer recuo/recruzamento.
- Managed: RunController, único dono de fade, recebe a saída, oferece a recompensa de chefe existente após o cruzamento e anima antes de substituir sala; nova instância Player/HP/build segue o fluxo atual. Standalone: helper CanvasLayer root `PROCESS_MODE_ALWAYS`, sem pausar SceneTree, controla token, fade ~180/220 ms e troca. Snapshot HP/build só é preparado no preto, imediatamente antes do swap, após source=current_scene e token válidos. Main não aguarda após swap legítimo.
- Helper espera nova current_scene pronta, até120 frames, cancela limpo em death/restart/owner obsoleto, limpa snapshot/revela cena existente se o swap falhar; Main._exit_tree normal de swap não cancela snapshot/helper. Pause/reset UI é bloqueada durante busy. Managed pausa só se for dona, sem despausar GameOver/vitória.
- Terminal standalone sem destino é decidido antes do unlock: gate permanece sólido, `ETAPA CONCLUÍDA`. Retry só existe em standalone; managed failure segue GameOver/restart e não reapresenta/reaplica recompensa de chefe.

## Adendo de execução R2 — 19/10/2026

Este adendo mantém o contrato R3 e registra correções pontuais após a leitura do freeze R1:

- A validação deferred exige que o centro atual do collider ainda esteja em `x >= line_x`, além de permanecer dentro do vão. O latch continua provando o cruzamento positivo anterior; não se repete `previous_x < line_x` na validação.
- Se o swap aceito mantiver a cena fonte ativa por 120 frames, o overlay só tenta rollback depois de revelar a cena e revalidar token, transição e fonte atual. O snapshot só é limpo nesse rollback validado; se uma nova cena pronta concluir durante o fade, ela preserva o snapshot. Se a fonte sair sem destino pronto, o snapshot é limpo como recuperação sem fonte.
- A porta confirma aberta por `ExitGate.disabled == true`. Erros aparecem antes do estado busy; a mensagem de recuo/retry só é exibida em standalone. Managed permite armamento inicial ao liberar a porta, mas não rearma depois de uma falha sem retry.
- `RunController.transition_delay` passa a ter default e mínimo `0.0`: com zero, mostra status de preparação e começa o fade sem timer; um override positivo continua mostrando a contagem e aguardando esse intervalo. A checagem de estado após o atraso permanece.

## Arquivos e limites

Runtime autorizado: `scripts/world/exit_door.gd`, `scenes/exit_door.tscn`, `scripts/world/main.gd`, `scripts/world/run_controller.gd`, novo `scripts/world/room_transition_overlay.gd`, `scenes/main.tscn`, `scenes/second_room.tscn`. Preservar RoomTransition se snapshot atual bastar, arte/player/movement/floor/spawns/gerador/inimigos/resources/imports/settings/Git. Sem Godot/import/testes/QA. Registro e baseline local acompanham o adendo; depois do freeze só documentação.
