# Plano — travessia e transição entre salas

**19/10/2026 · Prospectivo; revisar arquitetura antes de runtime.**

## Objetivo e base

Após clear, recompensa e guarda, o jogador deve andar pela saída lateral e trocar de sala ao cruzar o túnel para a direita, sem E. Manter entrada unidirecional fechada, HP/build, morte/restart e terminal. Lidos `docs/README.md`, `AGENTS.md`, planos/specs/pareceres de porta lateral, geração de salas e game loop, e GDD `04-combate-e-builds.md` §3. O novo pedido substitui a interação por E, mantendo o contrato gerenciado de 18/10.

## Proposta

- Abrir a colisão lateral direita x=[1088,1152), y=[432,560) por um gate: dividir a parede acima/abaixo e manter o gate sólido até a liberação atual de Main (clear + recompensa + guard). Acrescentar contenção exterior contínua x=[1152,1160), y=[0,648) nas duas cenas, para segurar o jogador se a troca falhar. Não alterar parede esquerda ou piso.
- Usar a área ExitDoor somente sobre o túnel; emitir uma vez quando o centro do Player cruza x=1120 para +X. Main revalida saída/guard/sala/Player; proximidade sem cruzar nunca avança. Ao aceitar, congela o Player no Main. Falha standalone restaura o estado e permite recuar/recruzar.
- Um fade owner por fluxo: RunController controla managed após eventual recompensa de chefe; um CanvasLayer persistente na SceneTree root controla standalone atravessando `change_scene_to_packed`. Fade ~180 ms para preto + troca + ~220 ms para revelar. Main não aguarda depois de descarregado. `RoomTransition` continua apenas snapshot one-shot HP/build.
- Destino standalone vazio (SecondRoom) é terminal: gate fechado, `ETAPA CONCLUÍDA`, sem saída ao vazio. Managed mantém decisão de progresso/vitória do RunController.

Main atualiza o validador autoral das paredes/gate/outer guard e usa o gate; callbacks após await revalidam identidade da sala e estado. Em falha: limpar snapshot, pausa/fade/lock; não continuar sala obsoleta. Arquivos propostos: `exit_door.gd/.tscn`, `main.gd`, `run_controller.gd`, novo `room_transition_overlay.gd`, `main.tscn`, `second_room.tscn`. Preservar arte lateral V2 e `room_transition.gd` se `clear_pending_snapshot()` bastar. Evitar tocar Player/movement_controller.

Aceite estático: gate físico abre na hora certa; cruzamento +X interno dispara uma vez; E/proximidade não transitam; HP/build e managed/standalone preservados; outer guard segura falha sem saída livre; terminal não permite cair; restart não deixa overlay/pausa/lock preso. Sem Godot/import/testes/QA. Escopo exclui combate/recompensas, controles/movimento, spawns/piso/plataformas, gerador, arte/atlas/imports, `project.godot`, plugins, GDD e Git.
