# Etapa B — Muse Spark 1.3 xhigh

Modelo exato via OpenCode, agente plan. Revisão somente leitura; sem Opus por autorização do usuário.

STATUS: done
SUMMARY: Etapa B confere com spec v0.3 no estado congelado: oferta única de 3 cartões nativos na Sala 01, Sala 02 com `reward_enabled=false` sem porta e sem recompensa, máquina `INACTIVE->VICTORY_PENDING->OFFER_OPEN->SELECTED->EXIT_RELEASED` mais `CANCELLED/COMPLETED`, morte prevalecendo, cleanup pós-flush antes de UI/pausa, guarda 0,25 s e porta só em `EXIT_RELEASED`. Nenhum defeito funcional bloqueante encontrado. Ausência de carga/dano energizado é escopo de C, não defeito de B.
CHANGED_FILES: none
TESTS: apenas leituras/análise estática, sem execução de testes, Godot, import, parse ou comandos de mutação. Lidos `upgrade_offer.gd`, `upgrade_offer.tscn`, `main.gd`, `combat_room.gd`, `exit_door.gd`, `player.gd`, `racket_controller.gd`, `ball_launcher.gd`, `ricochet_ball.gd`, `hostile_rivet.gd`, `main.tscn`, `second_room.tscn`, mais `run_build.gd`, `projectile_config.gd`, `exit_door.tscn`, `spec.md`, `implementacao.md`, `docs/README.md`, `AGENTS.md`.
RISKS: nenhum bloqueante. Observações de prioridade baixa, todas atuais de B:
- `scripts/world/exit_door.gd:46-48` — `_unhandled_input` filtra só `InputEventKey`; se `interact` tiver botão de joypad, a porta não abre por joypad, enquanto `main.gd:122-127` consome evento genérico. Condição: interact via joy. Verificar mapa de inputs; teclado/E está correto.
- `scripts/world/main.gd:116-119` — consumo de `interact` em `OFFER_OPEN` em `Main._input` é inócuo com árvore pausada (`Main` é `INHERIT`); o consumo efetivo é `scripts/ui/upgrade_offer.gd:59-62` (`WHEN_PAUSED`). Funciona, apenas redundância documental.
- `scripts/world/main.gd:217-229` — falha de `present_options` vai a `CANCELLED` com porta bloqueada e sem retry; só ocorre com definição nula/duplicada, improvável com `preload` fixo de 3. Aceitável, mas resulta em sala limpa sem saída até morte/R.
- `scenes/upgrade_offer.tscn` — botões sem `grab_focus`/vizinhos explícitos; mouse ok, só-teclado depende de Tab. Não bloqueia teaser.
- Aliasing benigno: `ball_launcher.gd:36-37` guarda referência a `RunBuild` de `Main`; `clear()` pós-morte reflete sem re-apply, mas bola já foi limpa e reload cria nova `Main`/build. Configs derivadas usam `duplicate(true)`, bases preservadas.
Etapas futuras, não defeitos de B: lógica de carga `INATIVA/CARREGADA/CONSUMIDA`, bônus +2, consumo só em `take_damage()->true` e contrato booleano dos inimigos são de C.
NEXT_STEP: manter B congelado e liberar etapa C após confirmação das demais revisões exigidas (Gemini, Grok); sem nova ação de código em B.

