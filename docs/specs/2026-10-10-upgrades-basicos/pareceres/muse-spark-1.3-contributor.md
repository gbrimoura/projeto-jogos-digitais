# Parecer — Muse Spark 1.3 Contributor xhigh

- Data: 10/10/2026
- Ferramenta: OpenCode
- Escopo: QA e critérios de aceite
- Revisão: v0.1
- Status de execução: done
- SHA-256 plano: AB4220380AEAEF630E6FA4C1DCB54C238DFC66626AE915259804701555ECCF63
- SHA-256 spec: 4B753A6905461FBE6E6C9FF86880A7E9E7C69813F84934843C7090F57807AE07
- Registro original: muse-r1.stdout.json
- Avaliação do coordenador: será registrada no consolidado; prioridades do modelo não são aprovação automática.

## Saída do revisor


> plan · muse-spark-1.3-contributor

Revisão QA focada em aceite testável — lendo plano congelado e base.
→ Read AGENTS.md
→ Read agent.md
→ Read docs/README.md
→ Read docs/specs/2026-10-10-upgrades-basicos/plano.md
→ Read docs/specs/2026-10-10-upgrades-basicos/spec.md
Plano e spec lidos; buscando pareceres, GDD e código para validar aceite.
→ Read docs/specs/2026-10-10-upgrades-basicos/pareceres/README.md
✱ Glob "docs/specs/2026-10-10-upgrades-basicos/**/*" 3 matches
✱ Glob "**/*.gd" 24 matches
→ Read scripts/world/main.gd
→ Read scripts/world/room_transition.gd
→ Read scripts/world/combat_room.gd
→ Read scripts/world/exit_door.gd
→ Read scripts/projectile/ricochet_ball.gd
→ Read scripts/player/player.gd
→ Read scripts/player/movement_config.gd
→ Read scripts/projectile/projectile_config.gd
→ Read scripts/player/racket_controller.gd
→ Read scripts/player/ball_launcher.gd
→ Read scripts/enemy/rivet_worker.gd
→ Read scripts/world/training_target.gd
→ Read scripts/player/movement_controller.gd
→ Read scripts/projectile/hostile_rivet.gd
Núcleo de gameplay mapeado; verificando GDD, saúde, inputs e cenas.
→ Read scripts/player/player_health.gd
✱ Glob "**/project.godot" 1 match
✱ Glob "scenes/**/*" 10 matches
✱ Glob "**/04-combate-e-builds.md" 0 matches
→ Read project.godot
✱ Grep "uid://|PackedScene|resource_path|get_tree\.paused|process_mode|reload_current_scene|F6|KEY_F6|interact|parry|launch_ball|dash" 100 matches
→ Read scenes/second_room.tscn
→ Read scenes/main.tscn
✱ Glob "resources/**/*" 2 matches
STATUS: done
SUMMARY: Revisão QA read-only v0.1 (plano.md+spec.md) na frente UI/input/pausa, configuração, transfer UID/fail/retry/reset, carga/targets/expiry/bounce. Achados priorizados abaixo; sem execução Godot/testes por restrição.
CHANGED_FILES: none
TESTS: leituras estáticas — docs/README.md, AGENTS.md, agent.md, docs/specs/2026-10-10-upgrades-basicos/plano.md v0.1, spec.md v0.1, pareceres/README.md; scripts/world/main.gd, room_transition.gd, combat_room.gd, exit_door.gd, projectile/ricochet_ball.gd, projectile_config.gd, hostile_rivet.gd, player/player.gd, movement_config.gd, movement_controller.gd, ball_launcher.gd, racket_controller.gd, player_health.gd; project.godot [input]/layers; scenes/main.tscn, second_room.tscn; resources/player_movement_config.tres, projectile_config.tres; grep uid/paused/F6/input.
RISKS: P1: (1) expiry 2.2s em spec/plano contradiz regra autoritativa usuário (charge só até consumo/fim mesma bola, lifetime restante preservado); (2) contrato bool take_damage proposto vs void atual inimigos — aceite "alvo rejeita" intestável; (3) cópia config por bola exigida vs referência compartilhada atual; (4) pausa/bloqueio input subespecificado + vazamento clique oferta→launch/parry; (5) transfer UID/build vs HP-only atual + second_room sem uid + gating oferta só Sala01 ausente + semântica retry/R com static payload. P2: F6 sem binding/impl, morte-durante-oferta, queda y=760 com bola carregada, discriminação bola própria vs rebite hostil, E enfileirado durante oferta, sala-que-já-inicia-limpa. P3: combinado 4 como proposta não-aceite v1, visual brilho sem asserção testável.
NEXT_STEP: Agente principal ajustar spec/plano para remover 2.2s, tipar bool dano, cópia idempotente, pausa/process_mode/guard-frame, payload canônico+clear+gate Sala01, F6/queda/E testáveis; só então liberar Fase A Luna6 xhigh com revisões obrigatórias.

---
ACHADOS (frente exclusiva QA; sem replanejar arquitetura; proposta≠decisão)

Premissas autoritativas usuário (prevalecem sobre docs): teaser ~60s 14/10/2026; 1-de-3 após vencer; 1→2 dano, dash 0.55→0.40, charge +2 próximo dano válido aceito; charge dura SOMENTE até consumo/fim da mesma bola, lifetime restante preservado, sem novo prazo 2.2s; só bola própria, parede não consome, não rebite hostil; recompensa só Sala01/terminal02-sem-oferta é RECORTE PROPOSTO v1, não universal; só documentação, nenhuma mecânica.

[P1-1] Expiry 2.2s contradiz usuário.
Arquivo/seção: spec.md §2 tabela carga_reativa + §4 "por 2,2s / mantém valor e prazo / duração 2,2s também expira"; plano.md §Três upgrades "não renova 2,2s".
Motivo: usuário proíbe novo prazo 2.2s; exige consumo/fim-da-mesma-bola com restante preservado. Reprodução: ler spec §4 vs instrução usuário; aceite "expiração 2,2s" falharia contra regra autoritativa e contra ricochet_ball.gd lifetime 2.2 base (confunde lifetime bola com timer carga).
Correção mínima: remover 2.2s de carga; definir `charge_expiry = min(consumo_primeiro_dano_aceito, fim_bola[lifetime|bounce_limit|cancel])`; parry repetido: sem acumular/renovar, mantém +2 até fim; testes com cronômetro só verificam lifetime bola, não timer carga.

[P1-2] API dano bool intestável no código atual.
Arquivo/seção: plano.md Desenho 5 + spec.md §4 "Sugere-se retorno bool"; código scripts/enemy/rivet_worker.gd:98 `take_damage->void`, scripts/world/training_target.gd:27 `->void` (early return sem valor); só player_health.gd:31 retorna bool.
Motivo: aceite "parede/alvo inválido/dano recusado não consomem" + "primeiro inimigo que aceite" exige distinguir aceito vs rejeitado; com void, `ricochet_ball._apply_impact_damage:208` e futuro charge não têm como decidir consumo. Inconsistência: spec propõe bool mas não lista migração dos 2 inimigos + hostile_rivet._apply_impact.
Correção mínima: especificar `take_damage(amount,source)->bool` true só se `health` decrementado; false se derrotado/health<=0/amount<=0; decidir invulnerabilidade (inimigos hoje sem i-frame; player tem 0.8s); aceite: stub alvo que retorna false não consome; parede (fora grupo damageable) não chama.

[P1-3] Imutabilidade/idempotência vs referência compartilhada.
Arquivo/seção: spec.md §2 "sem escrever... Cada bola recebe cópia"; plano.md Aceite "bases não alteradas, recálculos idempotentes"; código ball_launcher.gd:45-50 `ball.launch(direction,projectile_config)` + ricochet_ball.gd:33 `_config=config` (mesma instância); player.gd:40-41 movement_config export direto a MovementController.
Motivo: teste "recalcular 2x = mesmo resultado; .tres base intacto" falha se mutação in-place; dano 1→2 e dash 0.40 exigem base 1 / 0.55 preservados (confirmado resources/player_movement_config.tres:19 0.55 e projectile_config damage 1, mas sem cópia).
Correção mínima: aceite exigir `config.duplicate()` por bola no launch + `Base+RunBuild=>Runtime` sem escrita; teste: aplicar Impacto/Motor 2x, comparar base; checar ricochet visual_radius/collision_radius inalterados.

[P1-4] UI/input/pausa subespecificado; risco vazamento clique.
Arquivo/seção: plano.md Recorte + Fases B + Aceite "pausa simulação/inputs; fechar/clicar não vira arremesso/parry/pulo; duplo-clique/tecla segurada"; spec.md §3; código project.godot launch_ball=MouseLeft, parry=MouseRight; player.gd:59-61 `is_action_just_pressed` em _physics_process; racket_controller.gd:82 mesmo; exit_door.gd:44-60 _unhandled_input interact; nenhum `get_tree().paused/process_mode` no repo.
Motivo: sem mecanismo (paused vs freeze manual), mesma tecla/mouse da oferta vaza no frame fechamento; `set_input_as_handled`, mouse_filter, foco teclado (setas/Tab/Enter/E?), release pós-seleção e guarda 1-frame não definidos → critérios "uma só escolha; sem ação combate ao sair" intestáveis.
Correção mínima: definir `Main` oferta: `get_tree().paused=true` + UI CanvasLayer(>10) process_mode ALWAYS, gameplay bloqueado; consumir evento oferta; ignorar launch/parry/jump/dash/interact iniciados na oferta no frame+1; matriz teste: clique-duplo, botão segurado, Esc/fechar, E durante oferta não libera porta nem transiciona.

[P1-5] Transfer UID/fail/retry/reset + gating Sala01.
Arquivo/seção: plano.md Desenho 3/Reconstrução + Aceite falha/retry; spec.md §5; código main.gd:84-100 load+canonical resource_path+prepare_health_transfer, room_transition.gd só `_pending_health_transfer` HP; second_room.tscn:1 sem `uid`, next_room_scene_path=""; main.tscn uid dlgvrryxeujdh.
Motivo: (a) aceite "transferência por UID" impossível p/ Sala02 sem uid — usar path canônico até UID atribuído; (b) payload hoje só HP, sem snapshot build; static sobrevive `reload_current_scene` → R/retry pode reaplicar/duplicar se não limpar; (c) CombatRoom._ready:46-47 auto-clear se sala inicia limpa + Main._on_room_cleared sem gate abriria oferta em qualquer sala limpa, violando recorte "só Sala01 rota principal".
Correção mínima: atribuir uid a second_room ou rebaixar aceite p/ path canônico; especificar payload one-shot {HP+build+destino canônico}, consumo só após destino aplicar, clear em falha + em _ready não-transição + em R/morte; gate oferta `sala==Sala01 && room_cleared único && vivo`; teste: falha load mantém origem jogável, retry não duplica; Sala02 terminal sem oferta/sem crash com destino "".

[P2-1] F6 sem definição testável.
Arquivo/seção: plano.md "F6 sala teste fresca" + spec §5; grep F6 zero; project.godot sem ação F6.
Correção mínima: definir input F6 (ação vs keycode direto), destino fixture, HP 5/build vazia + limpeza payload; ou marcar pendente manual, fora aceite auto.

[P2-2] Morte-durante-oferta sem transição estado.
Arquivo/seção: spec §7 "Morte durante oferta fecha UI e limpa pausa/input"; combat_room.gd:27-32 R só após derrota; player._on_died cancela racket/ball.
Correção mínima: máquina `oferta_aberta --died--> fechada+unpause+sem seleção`; teste: kill (hostile restante? cancelados em _clear_room) — definir fonte morte válida nesse estado ou declarar inalcançável+teste negativo.

[P2-3] Queda y<760 com bola ativa/carregada.
Arquivo/seção: plano Aceite queda preserva HP/build; main.gd:37-39 só `reset_to_spawn`, não toca BallContainer.
Correção mínima: definir bola/charge preservada (lifetime correndo) vs cancelada; teste queda com bola carregada + parry pendente.

[P2-4] Discriminação bola própria vs rebite hostil.
Arquivo/seção: plano "só bola jogador, nunca rebite hostil" + spec §4; código ambos is_parryable true; hostile_rivet._apply_parry:108-119 vira friendly, troca mask 9, source=player.
Correção mínima: charge só se `ball is RicochetBall && launched-by-player && !_has_finished`; parry hostil (mesmo pós-friendly) nunca concede/consome; teste parry hostil→hit não dá +2.

[P2-5] Porta E enfileirado.
Arquivo/seção: exit_door.gd is_player_in_range + transition_requested; plano "porta só após seleção".
Correção mínima: E durante oferta ignorado (não enfileira); após seleção exigir soltar+re-pressionar E em alcance; teste segurar E na seleção não transiciona sozinho.

[P2-6] Último inimigo morto em callback dano + ricochete/limpeza mesmo ciclo.
Arquivo/seção: plano Checagens "derrota último inimigo durante callback"; combat_room erase+emit; main cancela hostis.
Correção mínima: teste: hit carregado mata último → carga consumida uma vez, sem double-defeated, oferta abre uma vez; bola que vencer+morte jogador mesmo frame: morte prevalece, sem oferta.

[P3-1] Combinado 2+2=4 é hipótese, não aceite v1 (uma aquisição/run, sem acúmulo). Manter fora matriz v1; se citado, rotular "futuro, não testar".
[P3-2] Visual brilho/aro nativo sem asserção: definir nó (modulate/Line2D existente, sem novo CollisionShape, raio/colisão/velocidade/ricochetes inalterados); teste estático cena + runtime screenshot/teaser apenas.
[P3-3] Roteiro teaser 0-60s não é critério funcional; não bloquear aceite.

Conformidades verificadas: estado v0.1 congelada corretamente (docs/README + pareceres/README sem pareceres fabricados); recorte terminal02-sem-oferta e 1/run sem slots/raridade/economia/multiball/procedural explicitamente fora escopo; base dash 0.55 coincide código+tres (pendência runtime ok); números marcados provisórios, não balanceamento.

---
SUGESTÕES OPCIONAIS (separadas, não bloqueiam):
- Aceite redigir como tabela Given/When/Then por frente (ex.: Given Sala01 vencida+oferta aberta When duplo-clique cartão A Then build=[A] 1x, porta libera, sem launch/parry no unpause).
- Tolerância float dash 0.40±0.02 via get_status; dano exato int (2, 3 carregado sem Impacto).
- Checar `Input.is_action_just_pressed("interact")` duplicado em exit_door + oferta com `set_input_as_handled` para evitar E fantasma.


