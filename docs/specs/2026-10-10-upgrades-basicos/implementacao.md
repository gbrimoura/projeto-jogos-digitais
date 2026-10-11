# Registro de implementação — upgrades básicos

**Data:** 10/10/2026. **Plano de referência:** v0.3. O registro acompanha incrementos A/B/C sem reescrever o plano, a spec ou os pareceres originais.

## Refinamento dos cartões — 10/10/2026

Por pedido do usuário, descrição e números foram separados: texto objetivo em fonte16 acima de EffectSummary em fonte30/ciano. Recursos contêm effect_summary de apresentação: 1 → 2 de dano; 0,55 s → 0,40 s; +2 de dano. Labels nativas com mouse_filter IGNORE preservam cliques; description reserva58px e resumo40px, iguais nos três cartões. Os valores e o comportamento de escolha/gameplay permanecem intactos. Implementado por GPT-6 Luna xhigh; Gemini, Muse e Grok concluíram revisão estática sem bloqueios/P1/P2. Opus Cursor bloqueado por quota, sem parecer. Registro e saídas: [ui-numeros](pareceres/ui-numeros/README.md). Nenhum teste ou Godot/render foi executado; validação visual deste refinamento pendente. O usuário havia confirmado funcionamento dos upgrades anteriores.

## Autorização e revisão

O usuário dispensou Claude Opus 5.5 High somente para este trabalho de upgrades, incluindo a revisão final do plano e as implementações A/B/C. A dispensa não é um parecer e não altera a exigência global para outros trabalhos. Gemini 3.8 Flash High (AGY), Cursor Grok 4.7 XHigh Fast e Muse Spark 1.3 Contributor xhigh continuam previstos em cada etapa. O preflight desses três revisores foi feito pelo agente principal uma vez para esta tarefa. Na etapa A, Muse e Gemini concluíram sem bugs bloqueantes; Grok expirou após 10 minutos sem stdout, com registro de timeout em `pareceres/implementacao-a/grok.md`. Nenhuma saída Opus será criada para substituir os bloqueios por quota.

## Etapa A — dados, build e transição

**Estado:** implementação concluída e congelada. Muse e Gemini revisaram sem bugs bloqueantes; Grok expirou após 10 minutos sem stdout, registrado em `pareceres/implementacao-a/grok.md`. A sugestão defensiva do Gemini (`is_instance_valid(player)` antes de acessar a posição em `Main._physics_process`) foi integrada durante B. O stdout de Muse preservado em `pareceres/implementacao-a/muse.stdout.json` é uma síntese fiel do parecer, não uma transcrição integral. Não houve parecer Opus por dispensa explícita do usuário para este trabalho. Nenhum teste, import, parse ou runtime do Godot foi executado, conforme instrução.

### Entregas

- `UpgradeDefinitionResource` contém IDs, título, ícone, descrição e campos de efeito tipados. Os recursos `impacto_reforcado.tres`, `motor_acelerado.tres` e `carga_reativa.tres` configuram os valores provisórios: dano 2, recarga de dash 0,40 s e bônus de dano carregado +2.
- `RunBuild` é `RefCounted`, pertence à raiz `Main`, guarda apenas contagens 0/1 dos três IDs conhecidos e limita a aquisição a uma por run. `replace_state` valida e substitui estado; `to_snapshot_data` retorna cópia simples com IDs e contagens.
- `Player.apply_run_build(build)` deriva uma cópia profunda da configuração-base de movimento. `BallLauncher.apply_run_build(build)` prepara cada lançamento a partir de cópia profunda da configuração-base de projétil. Reaplicações partem sempre das bases; nenhum recurso `.tres` original é alterado.
- `ProjectileConfig` ganhou os campos tipados `reactive_charge_enabled` e `charged_damage_bonus` para a configuração individual da bola na fase C. A lógica de parry, consumo de carga e dano energizado permanece fora da etapa A.
- `RoomTransition.prepare_run_snapshot` valida o `PackedScene`, HP e schema v1 antes da troca. `consume_pending_snapshot` copia e limpa o pending uma vez, inclusive em destino incompatível ou payload inválido. O payload não guarda Resources ou instâncias de `RunBuild`.
- `Main._ready` consome o snapshot depois do `_ready` dos filhos, substitui build/HP, reconfigura o jogador e só então avalia uma sala já limpa. Falha anterior à troca mantém o estado da origem. Morte limpa build e pending; o reload cria vida 5/build vazia. O reset por queda mantém HP/build e continua cancelando a bola própria pelo fluxo existente.

### Contrato público preparado para B/C

- `RunBuild.add_upgrade(StringName) -> bool`, `has_upgrade(StringName) -> bool`, `count_for(StringName) -> int`, `replace_state(ids, counts) -> bool`, `get_upgrade_ids() -> Array[StringName]` e `to_snapshot_data() -> Dictionary`.
- `Player.apply_run_build(RunBuild)` recalcula movimento; `BallLauncher.apply_run_build(RunBuild)` define a build usada para derivar a próxima configuração de lançamento.
- `RoomTransition.prepare_run_snapshot(PackedScene, hp_current, hp_max, RunBuild) -> bool`, `consume_pending_snapshot(PackedScene) -> Dictionary` e `clear_pending_snapshot()` controlam a transferência one-shot.
- A aquisição em A permanece inativa por padrão. B controla elegibilidade/oferta/seleção antes de chamar os métodos de build; C integra os campos de carga à bola e ao dano.

## Etapa B — oferta, pausa, input e porta

**Estado:** implementação concluída e congelada. Muse e Gemini revisaram sem bloqueios; Grok expirou após ler as fontes, sem parecer concluído. O agente principal encontrou P2 na limpeza deferred sem identidade de bola; a correção foi integrada em C. B adiciona a máquina de oferta em `Main`, seleção nativa de um entre três cartões, ownership da pausa, guarda de input discreto de 0,25 s, status da build e abertura da porta após seleção válida. Com guarda configurada como zero, ainda se espera soltar entradas discretas que estavam pressionadas. A UI oculta também desativa o consumo de input não tratado. Vitória/morte pedem parada por flag; a bola própria e todos os projéteis hostis (incluindo rebites redirecionados) são limpos após o flush. A flag de parada dos sweeps é separada de `_has_finished`, e os callbacks de parry/dano retornam antes de continuar movimento ou chamar `_finish` após o pedido de parada. Nenhum teste, import, parse ou runtime do Godot foi executado.

## Etapa C — carga reativa, dano e integração

**Estado:** implementação concluída e congelada; Muse, Gemini e Grok concluíram revisão estática sem P1/P2, assim como a releitura do agente principal. Runtime permanece pendente. Cada `RicochetBall` usa `INACTIVE → CHARGED → CONSUMED`: somente a própria bola com `reactive_charge_enabled` arma em parry aceito, não acumula nem rearma, calcula base + bônus antes de `take_damage`, e consome apenas se a função retornar o booleano `true`. Parede, resultado falso/não booleano e rebite hostil não consomem. `RivetWorker` e `TrainingTarget` retornam `true` só após redução de HP (inclusive letal), retornam `false` para dano inválido/alvo derrotado e emitem `defeated` uma vez. O anel visual nativo aparece só carregado e não altera colisão. Lifetime, velocidade e ricochetes permanecem inalterados. Também foram corrigidos o reset deferred pela identidade da bola e dois casos de input da B: guarda zero ainda aguarda soltura; oferta oculta não consome input. Nenhum teste, import, parse ou runtime do Godot foi executado.

### Pareceres C e fontes

- Gemini 3.8 Flash High: [parecer](pareceres/implementacao-c/gemini.md), [stdout JSON](pareceres/implementacao-c/gemini.stdout.json); recebeu as fontes e o GDD integral inline.
- Muse Spark 1.3 Contributor xhigh: [parecer](pareceres/implementacao-c/muse.md), [stdout JSON](pareceres/implementacao-c/muse.stdout.json). A primeira leitura externa do GDD foi bloqueada automaticamente; o parecer final usou o snapshot do GDD fornecido inline, sem afirmar leitura externa integral. O bloqueio está preservado em [muse-bloqueio.stdout.json](pareceres/implementacao-c/muse-bloqueio.stdout.json).
- Cursor Grok 4.7 XHigh Fast: [parecer](pareceres/implementacao-c/grok.md), [stdout JSON](pareceres/implementacao-c/grok.stdout.json); concluído em aproximadamente 8 minutos, sem P1/P2.
- [Avaliação do agente principal](pareceres/implementacao-c/principal.md) e [fontes, estado do freeze e hashes](pareceres/implementacao-c/fontes.json).
