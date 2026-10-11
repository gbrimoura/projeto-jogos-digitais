# Parecer — Grok 4.7 XHigh Fast

- Data: 10/10/2026
- Rodada: plano/spec v0.1
- Modelo: `grok-4.7-xhigh-fast`
- Ferramenta: Cursor Agent; somente leitura
- Estado: concluído; avaliação do agente principal em `consolidado.md`
- Hash SHA-256 do plano: `AB4220380AEAEF630E6FA4C1DCB54C238DFC66626AE915259804701555ECCF63`
- Hash SHA-256 da spec: `4B753A6905461FBE6E6C9FF86880A7E9E7C69813F84934843C7090F57807AE07`
- Saída original: [grok-r1.stdout.json](grok-r1.stdout.json)

## Saída do revisor

A spec e o código em `e2855c2` divergem em cinco pontos que mudam estado de combate. O relatório abaixo é só leitura: nenhum arquivo foi alterado.

STATUS: done
SUMMARY: Revisão adversarial somente leitura da v0.1 contra o commit e2855c2. Há 5 P1: a spec cria um relógio de 2,2 s para a carga; a “cópia” de configuração não quebra o alias dos `.tres`; o callback de dano reentra no sweep e no parry do rebite; a oferta pode travar ou vazar o clique esquerdo; o snapshot é consumido cedo demais e depois do `configure` dos filhos. Nada foi implementado.
CHANGED_FILES: none
TESTS: leituras estáticas de `docs/README.md`, `AGENTS.md`, `agent.md`, `plano.md`, `spec.md`, `pareceres/README.md`, GDD `04-combate-e-builds.md` e scripts/cenas/resources em HEAD `e2855c2a7b076a112ad59c16b388da4259a8c909`. Godot, import, testes e simulação não foram executados.
RISKS: P1 relógio da carga; P1 mutação de `projectile_config.tres` / `player_movement_config.tres`; P1 callback síncrono de dano/parry; P1 pausa, input e morte/clear no mesmo flush; P1 commit do snapshot. P2 rearme pós-consumo, porta, gate da Sala 02, estático no R/F6, contagem e os dois cooldowns de 0,55 s.
NEXT_STEP: Corrigir só esses trechos da spec/plano e devolver ao revisor. Não implementar mecânica nesta frente.

## Escopo e o que já está decidido

Código lido no commit `e2855c2` (`Implementa patrulha, parry e transição para a segunda sala`). Plano e spec são a v0.1 no disco, ainda não commitada. Pareceres: nenhum arquivo além do README; ausência não é aprovação. Cronograma não foi reavaliado.

Confirmado para este recorte, e já separado de regra geral do jogo: teaser de ~60 s em 14/10/2026; uma escolha entre três após vitória válida; uma aquisição por run; números 1→2, dash 0,55→0,40 e carga +2 no próximo dano aceito são proposta de teste; a carga dura até esse consumo ou até o fim da mesma bola, sem prazo novo de 2,2 s e sem renovar o lifetime restante; parede não consome; rebite hostil não recebe a carga; Sala 02 sem oferta é recorte proposto. O GDD deixa slots, economia, multiball e o balanceamento final do lifetime como pendência (`04-combate-e-builds.md`, §§7.1, 7.4 e 11). O protótipo já preserva lifetime, `bounce_count` e velocidade no parry.

## P1 — Relógio de 2,2 s da carga

Arquivo: [spec.md](docs/specs/2026-10-10-upgrades-basicos/spec.md) §2 (tabela `carga_reativa`) e §4, último item. Contraste com [plano.md](docs/specs/2026-10-10-upgrades-basicos/plano.md), tabela Carga Reativa, e com o código.

A spec diz que o parry “concede uma carga de dano +2 por 2,2 s” e que “a duração de 2,2 s também a expira”. Também manda “manter o prazo atual”. Isso instala um segundo relógio. A regra deste recorte é outra: a carga acaba no primeiro dano aceito ou quando essa bola termina; o lifetime restante continua o que já era; um parry seguinte não inicia outro prazo de 2,2 s.

No código, 2,2 s é o lifetime da bola no lançamento, e o parry não mexe nele:

```7:8:resources/projectile_config.tres
speed = 760.0
lifetime = 2.2
```

```84:90:scripts/projectile/ricochet_ball.gd
				velocity = Vector2(parry_hit.get("direction", Vector2.ZERO)).normalized() * _config.speed
				if velocity.is_zero_approx():
					velocity = Vector2.RIGHT * _config.speed
				_last_parry_swing_id = int(parry_hit.get("swing_id", -1))
				_parry_release_pending = true
				_notify_parry_success(_last_parry_swing_id)
```

`_lifetime_remaining` e `_bounce_count` ficam como estão. O GDD §11 registra o mesmo comportamento do protótipo e deixa o balanceamento final pendente. Um timer de 2,2 s contado a partir do parry quase nunca dispara antes do fim da bola, porque o restante já é ≤ 2,2 s. A leitura que muda o jogo é tratar esse número como lifetime novo.

O plano diz “não renova 2,2 s” e “remover ao terminar a bola”, sem uma expiração independente. A spec §7 ainda exige teste de “expiração”, o que cristaliza o relógio extra.

Correção mínima: na spec §2 e §4, e na célula da Carga Reativa do plano, escrever que não há timer próprio; a carga é um flag da instância; acaba no primeiro `take_damage` aceito ou em `_finish`/destruição; parry repetido não soma +2, não rearma e não altera `_lifetime_remaining`. O 2,2 s permanece só o lifetime-base já exportado.

## P1 — Mutação dos resources compartilhados

Arquivos: [spec.md](docs/specs/2026-10-10-upgrades-basicos/spec.md) §1–2; [plano.md](docs/specs/2026-10-10-upgrades-basicos/plano.md), desenho técnico itens 1–2; [scripts/player/ball_launcher.gd](scripts/player/ball_launcher.gd); [scripts/player/movement_controller.gd](scripts/player/movement_controller.gd); [scenes/player.tscn](scenes/player.tscn).

A spec manda derivar da base, não escrever de volta e “copiar” a configuração no lançamento. O lançamento atual entrega o mesmo objeto do `.tres`:

```45:50:scripts/player/ball_launcher.gd
	ball.collision_mask = projectile_config.collision_mask
	_projectile_parent.add_child(ball)
	_active_ball = ball
	ball.finished.connect(_on_ball_finished.bind(ball))
	ball.global_position = spawn_position
	ball.launch(direction, projectile_config)
```

`player.tscn` aponta `movement_config` e `projectile_config` para `res://resources/player_movement_config.tres` e `res://resources/projectile_config.tres`. Não há `resource_local_to_scene` nem `duplicate()` desses resources. Sala 01, Sala 02 e qualquer reload compartilham o cache.

O dash lê o resource no fim do dash, não uma cópia local:

```178:183:scripts/player/movement_controller.gd
func _finish_dash() -> void:
	_dash_timer = 0.0
	_dash_direction = Vector2.ZERO
	_body.velocity.x = 0.0
	_dash_cooldown_timer = _config.dash_cooldown
	_dash_state = DashState.COOLDOWN if _dash_cooldown_timer > 0.0 else DashState.READY
```

O dano da bola lê `_config.damage` em todo impacto. Se a carga ou o Impacto Reforçado fizerem `_config.damage = 2` ou `+= 2`, o `.tres` em memória muda para o resto da sessão. R (`reload_current_scene`) e F6 recriam a cena e continuam vendo o resource já alterado. A build da run pode estar vazia e o dash seguir em 0,40 s, ou a bola seguir com dano 3. Isso quebra o aceite “configurações-base não são alteradas” e “R limpa a build”.

Há um segundo 0,55 s que não é o dash: `RacketController.cooldown_duration` em [scripts/player/racket_controller.gd](scripts/player/racket_controller.gd) linha 8. O dash é `MovementConfig.dash_cooldown` no `.tres` (0,55). Os dois números coincidem.

Correção mínima: a spec deve nomear os arquivos e proibir atribuição em `damage`, `lifetime`, `speed`, `collision_radius` e `dash_cooldown` desses `.tres`. Dano-base e o bônus +2 ficam em campos da `RicochetBall`, preenchidos no lançamento e no parry. A recarga do dash fica num float do `MovementController`, recalculado da base 0,55 para 0,40 quando o id `motor_acelerado` está na build, e de volta a 0,55 quando a build está vazia. `UpgradeDefinitionResource` só guarda constantes. Se precisarem de um Resource local, `duplicate(true)` e nunca reatribuir o export que aponta para o `.tres`.

## P1 — Callback de dano, sweep e parry no mesmo ciclo

Arquivos: [spec.md](docs/specs/2026-10-10-upgrades-basicos/spec.md) §4 e plano, item 5 de desenho técnico; [scripts/projectile/ricochet_ball.gd](scripts/projectile/ricochet_ball.gd); [scripts/enemy/rivet_worker.gd](scripts/enemy/rivet_worker.gd); [scripts/world/training_target.gd](scripts/world/training_target.gd); [scripts/projectile/hostile_rivet.gd](scripts/projectile/hostile_rivet.gd); [scripts/world/combat_room.gd](scripts/world/combat_room.gd).

Hoje o inimigo não devolve `bool`. `RivetWorker.take_damage` e `TrainingTarget.take_damage` retornam cedo, sem sinal, quando `amount <= 0`, já derrotado ou HP 0. No golpe letal emitem `defeated` e só então `queue_free()`. `Player.take_damage` já devolve `bool`, com outro sentido: recusa morto, invulnerável ou amount ≤ 0. `call("take_damage")` sobre função `void` devolve `null`, que é falso. Enquanto a API não mudar, qualquer `if take_damage(): consumir` nunca consome carga nesses inimigos.

O consumo está dentro do sweep, e o golpe letal abre a sala antes de `take_damage` retornar:

```119:136:scripts/projectile/ricochet_ball.gd
		var next_bounce_index := _bounce_count + 1
		if next_bounce_index > _config.max_bounces:
			_finish("bounce_limit")
			return

		_bounce_count = next_bounce_index
		velocity = BounceResolver.reflect_velocity(velocity, surface_normal, _config.speed)
		var impact_position := collision.get_position()
		global_position += surface_normal * _config.collision_skin
		_apply_impact_damage(collision.get_collider())
		bounced.emit(_bounce_count, impact_position, surface_normal)
		# ... o while continua; não há checagem de _has_finished
```

```63:79:scripts/world/combat_room.gd
func _on_enemy_defeated(enemy: Node) -> void:
	if _player_was_defeated or _room_was_cleared or not _remaining_enemies.has(enemy):
		return
	_remaining_enemies.erase(enemy)
	_update_hud()
	if _remaining_enemies.is_empty():
		_clear_room()
```

`_apply_impact_damage` marca o alvo e chama `take_damage` em seguida. O `while` não consulta `_has_finished` depois do callback. `queue_free` não interrompe a função atual. `get_tree().paused = true` dentro do callback também não interrompe essa função; só tende a pular nós que ainda não rodaram neste flush.

Reprodução no layout atual: Sala 01 tem `TrainingTarget` e `RivetWorker`, os dois em `combat_enemy`. `max_collisions_per_tick` é 2; no tick em que o lifetime acaba o limite sobe para `max_bounces + 4` (7). A bola pode acertar os dois no mesmo `_physics_process`. O segundo aceite emite `room_cleared` no meio do `while`. O restante do sweep ainda pode ricochetear, parryar e aplicar outro dano. A bola é filha de `BallContainer`; um rebite disparado depois entra como irmão posterior e roda no mesmo flush, salvo se a pausa já tiver sido ligada. Ordem inversa também existe: rebite já na árvore acerta o jogador primeiro, `Player._on_died` chama `ball_launcher.reset()` → `cancel()` → `_finish`, e `CombatRoom` liga `_player_was_defeated` antes de um `defeated` posterior. Esse segundo caminho já é ignorado por `_on_enemy_defeated`. O primeiro caminho não está coberto pela spec além de “verificar”.

O parry dos dois projéteis termina no mesmo método da raquete. `HostileRivet._apply_parry` também chama `register_parry_success`. Armar a carga ali aplica o efeito ao rebite. O rebite amigável também chama `take_damage` em quem está em `damageable`. Se o inimigo, ao aceitar dano, procurar “a carga ativa”, o rebite a consome.

Parede e plataforma não estão em `damageable` e não chamam `take_damage` (`SolidPlatform` é só geometria). Isso já combina com “parede não consome”, desde que o consumo ocorra só depois de `true`.

Correção mínima na spec:

- `RivetWorker` e `TrainingTarget`: `take_damage` devolve `true` só se o HP desceu nesta chamada; `false` em amount ≤ 0, já derrotado ou HP já 0. Não copiar a invulnerabilidade do jogador.
- Só `RicochetBall._apply_impact_damage` lê esse `bool` e baixa o próprio flag. `HostileRivet` ignora o retorno para carga.
- A carga arma em `RicochetBall`, no ramo em que o parry precede a colisão, antes do `continue`, para o mesmo sweep poder usar o bônus. Não armar em `RacketController.register_parry_success`.
- Bônus só no primeiro `true` daquele sweep; os impactos seguintes usam o dano-base da instância.
- Depois do callback, se `_has_finished` ou a sala limpou/o jogador morreu, o `while` para.
- `room_cleared` nesse ponto só registra a vitória. Oferta e pausa ficam para depois do flush de física, quando `_player_was_defeated` já é definitivo.

## P1 — Oferta, pausa, input e morte no mesmo frame

Arquivos: [spec.md](docs/specs/2026-10-10-upgrades-basicos/spec.md) §3 e §7; [plano.md](docs/specs/2026-10-10-upgrades-basicos/plano.md), recorte e item 6; [scripts/player/player.gd](scripts/player/player.gd); [project.godot](project.godot); [scripts/world/main.gd](scripts/world/main.gd); [scripts/world/exit_door.gd](scripts/world/exit_door.gd).

Estados escritos: `inativa` → `oferta_aberta` → `selecionada` → `saída_liberada`. Não há estado para “vitória registrada, commit da UI adiado” nem para “morte no mesmo flush”.

`launch_ball` é o botão esquerdo (`button_index` 1). `parry` é o direito. O jogador e a raquete leem `Input.is_action_just_pressed` no `_physics_process`:

```56:73:scripts/player/player.gd
	var move_axis := Input.get_axis("move_left", "move_right")
	var jump_pressed := Input.is_action_just_pressed("jump")
	var jump_released := Input.is_action_just_released("jump")
	var dash_pressed := Input.is_action_just_pressed("dash")
	var dash_released := Input.is_action_just_released("dash")
	var launch_pressed := Input.is_action_just_pressed("launch_ball")
	# ...
	ball_launcher.try_launch(launch_pressed)
```

O clique do cartão ocorre na fase de input, antes da física desse frame. `set_input_as_handled()` não zera a ação. Se a UI fechar e desligar a pausa dentro do sinal do botão, o `_physics_process` seguinte ainda vê `launch_ball`. Duplo clique manda o segundo `just_pressed` no frame seguinte, já com a sala reaberta, e vira arremesso. A frase “não reabre o gameplay por um frame” descreve o sintoma e não o latch.

Pausa global com `process_mode` padrão também trava a própria UI: `CanvasLayer` herda pausável. A oferta fica em `oferta_aberta` e o clique não chega. R só é lido em `CombatRoom._unhandled_input` com `_player_was_defeated`; com a árvore pausada esse input não corre. Morte durante a oferta, se a pausa não for desligada antes, impede o R.

`Main._on_room_cleared` hoje destrava a porta na hora (`set_room_cleared(true)`), no mesmo sinal síncrono do último dano. A spec diz que a porta só recebe liberação em `saída_liberada`. O callback atual faz o contrário. `ExitDoor` lê E em `_unhandled_input`; no frame da limpeza o E já passou, então o furo é o frame seguinte se a porta já estiver aberta e a simulação não estiver pausada.

Correção mínima:

- UI da oferta em `PROCESS_MODE_WHEN_PAUSED`; simulação em pausável. A pausa vale para bola, rebite, inimigo, jogador e porta.
- Commit da oferta só no idle depois do flush em que a sala limpou, e só se o jogador segue vivo e o estado ainda é “vitória da Sala 01 sem oferta”.
- Morte nesse meio fecha a UI, desliga a pausa e não aplica id. O handler de seleção recusa qualquer coisa fora de `oferta_aberta` com jogador vivo, e grava `selecionada` antes de mexer na build.
- No frame em que a oferta fecha, ignorar `just_pressed` de launch, parry, jump, dash e interact. Despausar nesse mesmo handler de clique deixa o botão esquerdo virar arremesso.
- `set_room_cleared(true)` sai de `_on_room_cleared` e fica só na entrada de `saída_liberada`.

## P1 — Snapshot: consumo antecipado e configure dos filhos

Arquivos: [spec.md](docs/specs/2026-10-10-upgrades-basicos/spec.md) §5; [plano.md](docs/specs/2026-10-10-upgrades-basicos/plano.md), itens 3–4; [scripts/world/room_transition.gd](scripts/world/room_transition.gd); [scripts/world/main.gd](scripts/world/main.gd); [scripts/player/player.gd](scripts/player/player.gd).

O helper zera o payload antes de conferir o path e antes de `restore_health_for_room_transition`:

```23:28:scripts/world/room_transition.gd
	if _pending_health_transfer.is_empty():
		return false
	var payload := _pending_health_transfer.duplicate()
	_pending_health_transfer.clear()
	if str(payload.get("destination_scene_path", "")) != destination_scene_path:
		return false
```

`duplicate()` sem deep copia o dicionário e compartilha o objeto aninhado. Um `RunBuild` vivo posto nesse static é o mesmo objeto da sala de origem. A spec §5 pede consumir só quando “a carga de destino puder ser aplicada”. No resto do documento, “carga” é a carga do parry. Dá para implementar a condição errada: segurar o payload até existir uma bola energizada, ou limpar HP e build juntos num path que não bate.

A ordem pedida (“restaurar a build antes de configurar movimento/projéteis”) não cabe no `_ready` atual. Filhos ficam prontos antes do pai. `Player._ready` já chama `movement_controller.configure(self, movement_config)` com o `.tres`. `Main._ready` só então trata sala já limpa, chama `reset_to_spawn` e aplica o HP. O controlador guarda `_config` na referência antiga. Reconstruir a build no fim do `_ready` sem um segundo `configure` não muda o dash. Tratar sala já limpa antes do snapshot, como o `_ready` faz hoje nas linhas 25–26 e 32–35, abre oferta ou porta com build ainda vazia.

`static var` dessa classe sobrevive a `reload_current_scene` e a um play direto da fixture. R está em `CombatRoom._unhandled_input` e não descarta o static. Se um payload cujo path é a cena atual sobrar (apply falhou e a spec mandar conservá-lo), o `_ready` seguinte reaplica HP e build em cima do reinício que deveria voltar a 5 HP e build vazia. F6 não aparece em script nenhum; no GDD é o play da fixture. O static também sobrevive a esse play no editor.

Correção mínima:

- Payload é cópia profunda de HP atual, HP máximo e lista de ids. Não guarda o `RunBuild` vivo nem o resource.
- Ordem na origem: sala e jogador válidos; gravar a cópia; `change_scene` só depois. Falha antes da troca: descartar o payload; o jogador da origem segue com o estado vivo. Retry grava outro payload a partir desse estado.
- Ordem no destino: se o path não for o desta cópia, não aplicar e não apagar uma cópia de outra cena. Aplicar HP e substituir a build. Só então apagar o payload. Só então `configure` de novo no movimento e no lançador, a partir da base mais os ids. Sala já limpa e oferta vêm depois disso.
- R chama descarte sem aplicação e só então `reload_current_scene`. F6 / play direto não aplica static residual.
- “Carga de destino” na §5 troca para “snapshot de HP e ids”, para não misturar com a carga do parry.

## P2

1. Spec §4 só fala do parry “durante a carga”. Um parry depois do consumo, com a bola ainda viva, pode armar outro +2. O plano diz “uma carga por bola”. Fechar o estado: no máximo um arme por instância; depois de consumida, outro parry não rearma.
2. [scenes/main.tscn](scenes/main.tscn) e [scenes/second_room.tscn](scenes/second_room.tscn) usam o mesmo `main.gd`. As duas emitem `room_cleared`. A spec §3 passo 1 cita a Sala 01, mas o gate tem de ser o path canônico da Sala 01. Sala 02 não tem `ExitDoor` e `next_room_scene_path` está vazio; “terminal” aqui é essa fixture, não um nó de terminal.
3. Reconstruir a build substitui o conjunto de ids. “Contagem por ID” com incremento, se `_ready` e o sinal aplicarem os dois, passa de 1. Na v1 a contagem fica 0 ou 1.
4. Seleção com a build aplicada antes de gravar `selecionada` reentra se o sinal do botão disparar de novo no mesmo handler.
5. Queda com `y > 760` chama `reset_to_spawn`, que cancela a bola. HP e build permanecem; a carga morre com a bola. Convém uma linha na spec para ninguém “preservar a carga” no teleporte.

## P3

O `TrainingTarget` está em `damageable` e em `combat_enemy`. Acerto nele aceita dano e, pela regra escrita, consome a carga. Não é parede. Paredes/plataformas continuam fora de `take_damage`.

O resultado 4 (base 2 + carga 2) está marcado como combinação futura. A spec já diz que a v1 não entrega os dois upgrades. Não entra no estado desta versão.

## O que a v0.1 já segura

Uma aquisição, ids estáveis, definições sem estado da run, porta sem aplicar upgrade, rejeição de id estranho, segunda conclusão sem segunda oferta, morte descartando a build da run, queda preservando HP/build, e o recorte da Sala 02 como exceção de demonstração. Isso combina com o GDD: slots e economia seguem pendentes; os números do teaser não fecham balanceamento.

Sugestão operacional, fora dos achados: o texto mínimo é uma subseção curta “Contrato de frame” na spec, com as cinco correções P1 em sequência (flag da carga, campos fora do `.tres`, `bool` só na bola, commit da oferta no idle seguinte, snapshot profundo com `configure` depois). Sem isso, a fase A/C implementa o helper atual e o `register_parry_success` compartilhado.

