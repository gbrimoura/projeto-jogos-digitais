# Etapa C — Muse Spark 1.3 xhigh

Revisão somente leitura, mesmo modelo e esforço via OpenCode. Após bloqueio automático de leitura externa do GDD, a revisão foi concluída com seu novo snapshot fornecido inline. Não se afirma leitura externa integral.

STATUS: done
SUMMARY: Revisão estática somente leitura da Etapa C e integração A/B no estado congelado. Máquina INACTIVE->CHARGED->CONSUMED, cálculo base+bônus antes de `take_damage`, consumo só em retorno `true`, `take_damage` com `true` só em redução de HP, `defeated` única sem i-frames, lifetime/velocidade/ricochetes/física/raio preservados, visual só carregado, reset deferred por identidade, stop/cleanup pós-flush, snapshot one-shot, guard inclusive zero até soltar e UI sem consumir outras pausas conferem com spec v0.3 e snapshot GDD inline provisório. Nenhum bug bloqueante atual.
CHANGED_FILES: none
TESTS: apenas leituras/análise estática — docs/README.md, AGENTS.md, docs/specs/2026-10-10-upgrades-basicos/implementacao.md, spec.md, scripts/projectile/ricochet_ball.gd, scenes/ricochet_ball.tscn, scripts/enemy/rivet_worker.gd, scripts/world/training_target.gd, scripts/player/ball_launcher.gd, scripts/world/main.gd, scripts/ui/upgrade_offer.gd, scripts/projectile/projectile_config.gd, scripts/progression/run_build.gd, scripts/world/room_transition.gd, scripts/player/player.gd, scripts/world/combat_room.gd, scripts/projectile/hostile_rivet.gd, scripts/world/exit_door.gd + snapshot GDD inline 10/10. Sem testes/Godot/parse/import/runtime/escrita/delegação.
RISKS:
- Nenhum defeito funcional bloqueante atual identificado nas condições exigidas:
  - `ricochet_ball.gd:102,235-238` arma só no ramo próprio de parry aceito, só se `reactive_charge_enabled` e `INACTIVE`; `CHARGED` não acumula e `CONSUMED` não rearma.
  - `ricochet_ball.gd:227-233` calcula `damage+maxi(bonus,0)` antes de `take_damage` e consome só se `typeof==TYPE_BOOL && true`, inclusive letal, dentro de `_apply_impact_damage` antes dos retornos por `_has_finished/_stop_sweep_requested` em `134-148`.
  - Parede/rejeição/rebite: `123-137` parede/limite sem `arm`/dano; `231-233` `false`/não-bool não consome; `hostile_rivet.gd:116-148` sem campos de carga, só redireciona e chama dano sem armar/consumir.
  - `rivet_worker.gd:98-110`, `training_target.gd:27-38` retornam `false` em derrotado/HP0/amount<=0, `true` só após `health=maxi(health-amount,0)` com redução, `defeated` uma vez via `_defeated_emitted`, sem i-frames, só flash visual.
  - Carga sem efeito colateral: `97` parry mantém `_config.speed`, sem toque em `max_bounces/lifetime/collision_radius/skin`; `43` lifetime de `_config.lifetime` (2.2s padrão em `projectile_config.gd:8`) sem reiniciar; `252-257` `_finish` converte `CHARGED->CONSUMED`.
  - Visual: `ricochet_ball.tscn:20-25` `ChargeVisual` Line2D nativo `visible=false` sem colisão; `240-243` visível só em `CHARGED`.
  - `ball_launcher.gd:77-100` `reset()` captura `ball_to_cleanup`, sem agendar se nula/inválida, `request_stop`+`call_deferred` com identidade; `_cleanup` só nulifica se `_active_ball==ball_to_cleanup`, sem cancelar lançamento posterior.
  - Integração B: `main.gd:164-190, combat_room.gd:72-100, player.gd:131-134` callbacks só pedem `request_stop`, cleanup de bola própria + todo `hostile_projectile` pós-flush, flag separada sem forçar `_has_finished`.
  - Integração A: `ball_launcher.gd:172-183` e `player.gd:58-66` duplicam bases, `.tres` intactos; `run_build.gd` 0/1 e `MAX_UPGRADES=1`; `room_transition.gd:56-94` valida schema v1 integral e one-shot copia+limpa; `main.gd:78-105` consome pós-`_ready` filhos, só aplica se `replace_state`+`restore` válidos; morte limpa, queda `main.gd:147-151+player.gd:110-115` preserva HP/build e cancela bola/carga.
  - Guard/UI: `main.gd:269-285,129-145,116-127` guard 0 ainda exige soltura (`_any_discrete_input_pressed`), discreta reinicia, movimento/mira ignorados; `upgrade_offer.gd:29-64` `WHEN_PAUSED`, `unhandled_key_input` só aberta, `E` consumido sem enfileirar, oculta sem consumir; `main.gd:287-290,107-114` só despausa pausa própria, teardown sem retomar.
  - Docs: `implementacao.md:15,35`, `spec.md:§1,7-9` e snapshot inline marcam dano 1→2, dash 0,55→0,40, bônus +2 e aquisição única como provisórios teaser sem moeda/slots/raridade/stacks/procedural — consistente.
- Limitação: leitura externa `C:\Users\danie\...\04-combate-e-builds.md` negada pela ferramenta; conferência GDD restrita ao snapshot inline autorizado acima, sem afirmar leitura integral externa.
- Etapas futuras (não bugs atuais): balanceamento final, slots/economia/raridade/stacks/multiball e atualização autorizada do GDD permanecem pendentes por spec.
NEXT_STEP: Manter C congelada e encaminhar este parecer ao agente principal para consolidação com Gemini/Grok, sem nova mutação até decisão.

