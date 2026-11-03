# Especificação — travessia física e troca de sala

**19/10/2026 · Contrato prospectivo para revisão; runtime sem alterações.**

## Geometria e cruzamento

As fixtures atuais têm `RightWall` 64×648 em (1120,324), piso topo y=560 (1152×88), vão visual lateral x=1088..1152/y=[432,560), e sensor ExitDoor antigo x=992..1088. Main valida dimensões de parede exatas e recolhe todos os shapes ativos de `WorldCollision`.

Em Main e SecondRoom, separar a colisão direita em superior x=[1088,1152), y=[0,432), inferior y=[560,648), e gate x=[1088,1152), y=[432,560). Gate inicia ativo e abre após sala limpa, recompensa resolvida e guard encerrado. Esquerda permanece sólida e unidirecional. Main atualiza o validador para conferir estes shapes e o estado inicial do gate.

Reposicionar/redimensionar `ExitDoor/SensorShape` para o túnel (64×128). Em cada physics step dentro da área, guardar centro anterior; emitir `passage_crossed(player)` apenas se `previous_x < 1120`, `current_x >= 1120`, `velocity.x > 0`, gate liberado e não busy. E e mera sobreposição não avançam. Na validação diferida, exigir Player correto/vivo, centro além de 1120, ainda dentro da área, clear, guard encerrado e gate aberto; depois do lock não exigir velocidade positiva. O evento é one-shot; rollback reseta ocupação e possibilita novo cruzamento.

O Player usa cápsula radius14/height76. A linha está a 32 px da borda externa; mesmo passo de dash de até12 px deixa o centro no piso existente. No aceite, Main zera velocity e desativa temporariamente o `process_mode` do Player; restaura em rollback. Não criar extensão de piso/parede externa.

## Transição e recuperação

CanvasLayer `PROCESS_MODE_ALWAYS`, sem arte nova: fade alpha0→1 em ~180 ms, troca no preto, alpha1→0 em ~220 ms. Standalone: carregar destino e preparar snapshot `RoomTransition` antes do fade; novo helper preso à raiz da SceneTree executa troca e fade-in, sem await de Main após a troca. Erro limpa snapshot, revela sala e chama rollback só se fonte ainda é válida. RunController é o único dono managed: depois de resolver RewardScreen, anima, remove sala e carrega próxima; HP/build atuais seguem seus campos/snapshot existentes. Após awaits, verificar `_run_ended` e identidade da sala antes de tocar estado.

Gate permanece aberto enquanto a transição está ocupada. Erro de carga restaura overlay/pause/process mode, limpa snapshot, libera busy e mantém sala aberta para retry. Managed failure revela GameOver/restart antes de remover overlay; restart/death/terminal invalidam callback pendente e não deixam árvore pausada ou Player desativado. Sem destino standalone: manter gate fechado, `ETAPA CONCLUÍDA` e sem cruzamento. Managed continua tratando progresso ou vitória final.

## Escopo e aceite

Propostos: `scripts/world/exit_door.gd`, `scenes/exit_door.tscn`, `scripts/world/main.gd`, `scripts/world/run_controller.gd`, novo `scripts/world/room_transition_overlay.gd`, `scenes/main.tscn`, `scenes/second_room.tscn`. Preservar `room_transition.gd`, arte lateral V2 e atlas; tocar Player/movement_controller somente se lock no Main falhar por razão demonstrável.

Aceite estático: gate bloqueia até clear/recompensa/guard e libera o túnel de 64×128; entrada segue fechada; cruzamento positivo em x=1120 dispara uma vez e sensor antigo/E não transitam; HP/build ficam; terminal não sai do mapa; load failure/restart/morte não deixa fade, pause, lock nem await obsoleto. Sem execução Godot/import/testes/QA. Fora de escopo: combate/economia/build/recompensas, controles/movimento/poses, câmera, spawn/piso/plataformas, geração, arte/atlas/imports, `project.godot`, plugins, GDD e Git.
