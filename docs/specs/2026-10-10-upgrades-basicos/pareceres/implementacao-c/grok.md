# Etapa C — Cursor Grok 4.7 XHigh Fast

Modelo exato `grok-4.7-xhigh-fast`, modo plan; revisão adversarial de C e dependências de integração. Concluída em aproximadamente 8 minutos. A/B anteriores permanecem como timeout.

STATUS: done

SUMMARY: Na etapa C congelada não há P1/P2 funcional. A bola própria passa de INACTIVE a CHARGED só no parry aceito do sweep dela, com `reactive_charge_enabled`; CHARGED não acumula e CONSUMED não rearma. O bônus do recurso (+2) entra no dano antes de `take_damage`, e só o booleano `true` consome, inclusive no golpe letal, antes do retorno por stop. Parede, rejeição e rebite não armam nem consomem. `RivetWorker` e `TrainingTarget` devolvem `true` só quando o HP cai, emitem `defeated` uma vez e não criam i-frames. A carga não altera velocidade, ricochetes, lifetime de 2,2 s desde o lançamento, física nem raio, e acaba com a bola. O `Line2D` da cena começa oculto e só fica visível em CHARGED, sem colisão. O reset deferred guarda a instância, não agenda limpeza com bola nula e não cancela um lançamento posterior. Stop/cleanup pós-flush, snapshot da build e a guarda de input, inclusive com valor zero até soltar, seguem o contrato; a oferta oculta desliga o consumo de tecla. Runtime não foi executado e não está aprovado. A/B continuam com o Grok anterior em timeout.

CHANGED_FILES: none

TESTS: leitura estática de `docs/README.md`, `AGENTS.md`, `implementacao.md`, `spec.md`, `ricochet_ball.gd`, `ricochet_ball.tscn`, `ball_launcher.gd`, `rivet_worker.gd`, `training_target.gd` e das dependências `main.gd`, `combat_room.gd`, `hostile_rivet.gd`, `projectile_config.gd`, `projectile_config.tres`, `carga_reativa.tres`, `upgrade_offer.gd`, `player.gd`, `player_health.gd`, `racket_controller.gd`, `run_build.gd` e do snapshot de 10/10 em `GDD_Dieselpunk_Noir/04-combate-e-builds.md`. Sem Godot, teste, parse, import ou Git de mutação.

RISKS: nenhum P1/P2 de código. O efeito visual e a sensação de jogo seguem sem execução. Em `spec.md`, o fecho das seções 8 e 9 ainda descreve a rodada como só documental e o GDD de 03/10 como sem estes upgrades; o snapshot de 10/10, linhas 69–81, já registra o teaser e mantém dano 1→2, dash 0,55→0,40, bônus +2 e aquisição única como provisórios, sem fechar slots, moeda, raridade ou stacks. Isso é deriva documental, não defeito da máquina de carga. Fora desta etapa: balanceamento final e qualquer `damageable` novo, que precisa continuar retornando bool.

NEXT_STEP: registrar este parecer. Esta leitura não pede correção de código da etapa C. Validação no Godot só se for pedida à parte.
