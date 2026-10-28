# Especificação — travessia física e troca de sala

**19/10/2026 · Contrato prospectivo para revisão; runtime sem alterações.**

## Geometria e cruzamento

As fixtures atuais têm `RightWall` 64×648 em (1120,324), piso topo y=560 (1152×88), vão visual lateral x=1088..1152/y=[432,560), e sensor ExitDoor antigo x=992..1088. Main valida dimensões de parede exatas e recolhe todos os shapes ativos de `WorldCollision`.

Em Main e SecondRoom, separar a colisão direita em: parede superior x=[1088,1152), y=[0,432); parede inferior x=[1088,1152), y=[560,648); gate x=[1088,1152), y=[432,560); contenção exterior `RightOuterGuard` x=[1152,1160), y=[0,648). Centros/tamanhos correspondentes: (1120,216)/64×432; (1120,604)/64×88; (1120,496)/64×128; (1156,324)/8×648. Gate começa ativo e abre após sala limpa, recompensa resolvida e guard encerrado. Parede esquerda permanece inteira. Main atualiza `_validate_authored_room_boundaries()` para conferir estes shapes; `_collect_authored_world_obstacles()` deve reconhecer o novo corpo sem erro. OuterGuard fica fora da viewport, não abre a saída e impede fuga durante retry/falha; piso continua inalterado.

Reposicionar/redimensionar `ExitDoor/SensorShape` para o túnel (64×128). Em cada physics step dentro da área, guardar centro anterior; emitir `passage_crossed(player)` apenas se `previous_x < 1120`, `current_x >= 1120`, `velocity.x > 0`, gate liberado e não busy. E e mera sobreposição não avançam. Na validação diferida, exigir Player correto/vivo, centro além de 1120, ainda dentro da área, clear, guard encerrado e gate aberto; depois do lock não exigir velocidade positiva. O evento é one-shot; rollback rearma.

Player usa cápsula raio14/altura76. A linha está 32 px antes da borda externa; no cruzamento, Main zera velocity e desativa temporariamente o `process_mode` do Player. Restaura em rollback. A contenção exterior suporta tentativas que avancem além da soleira durante um frame e retry após falha. Não estender piso.

## Transição e recuperação

CanvasLayer `PROCESS_MODE_ALWAYS`, sem arte nova: fade alpha0→1 em ~180 ms, troca no preto, alpha1→0 em ~220 ms. Standalone: carregar destino e preparar snapshot `RoomTransition` antes do fade; novo helper preso à raiz da SceneTree executa troca e fade-in, sem await de Main após troca. Erro limpa snapshot, revela sala e chama rollback somente se fonte ainda é válida. RunController é único dono managed: resolve eventual RewardScreen primeiro, anima, remove sala e carrega próxima. HP/build seguem seus contratos. Após cada await, verifica `_run_ended` e identidade da sala.

Gate permanece aberto enquanto a transição está ocupada. Erro de carga restaura overlay/pause/process mode, limpa snapshot, libera busy e mantém sala aberta para retry; OuterGuard impede sair do mundo. Managed failure revela GameOver/restart antes de remover overlay; restart/morte invalidam callback pendente sem deixar árvore pausada ou Player desativado. Sem destino standalone: manter gate fechado, `ETAPA CONCLUÍDA`, sem cruzamento. Managed continua decidindo progresso/vitória.

## Escopo e aceite

Propostos: `scripts/world/exit_door.gd`, `scenes/exit_door.tscn`, `scripts/world/main.gd`, `scripts/world/run_controller.gd`, novo `scripts/world/room_transition_overlay.gd`, `scenes/main.tscn`, `scenes/second_room.tscn`. Preservar `room_transition.gd`, arte lateral V2 e atlas; tocar Player/movement_controller somente se lock no Main falhar por razão demonstrável.

Aceite estático: dimensões/estados dos colliders correspondem ao túnel; gate bloqueia até clear/recompensa/guard; entrada segue fechada; OuterGuard contém exterior; cruzamento positivo em x=1120 dispara uma vez e sensor antigo/E não transitam; HP/build ficam; terminal não sai do mapa; falha/restart/morte não deixa fade, pause, lock nem await obsoleto. Sem Godot/import/testes/QA. Fora de escopo: combate/economia/build/recompensas, controles/movimento/poses, câmera, spawn/piso/plataformas, geração, arte/atlas/imports, `project.godot`, plugins, GDD e Git.
