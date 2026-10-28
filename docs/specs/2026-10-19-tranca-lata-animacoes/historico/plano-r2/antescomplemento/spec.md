# Especificação — Tranca-Lata: patrulha e ataque

**Data:** 19/10/2026.  
**Estado:** revisão R2 congelada para revisão; sem integração runtime.  
**Referência de comportamento:** implementação estacionária registrada em ../2026-10-14-alvo-ataque-area/; este documento especifica sua extensão prospectiva.

## Identidade e contrato físico

O nome apresentado ao jogador é Tranca-Lata por display_name/NameLabel na cena compartilhada. Permanecem class_name TrainingTarget, scenes/training_target.tscn, node path TrainingTarget, grupos damageable/combat_enemy, sinal defeated e take_damage(amount, source) -> bool.

O corpo passa a CharacterBody2D com layer 8, mask 3 e CollisionShape2D retangular de 72×96 centrado na origem. Configurar `motion_mode = FLOATING`; o mask 3 continua consultando World e Player durante movimento. A física do jogador (mask 9), da bola (mask 9) e a chamada genérica a take_damage continuam reconhecendo a layer 8 e o grupo damageable. Não há dano por contato.

## Suporte e patrulha

A patrulha usa o SolidPlatform que de fato foi escolhido no spawn. `spawn_pending` bloqueia passos de movimento durante a preparação. Para o layout autoral, Main guarda a plataforma válida escolhida entre o caminho primário e o fallback e a disponibiliza à instância. Para o spawn aleatório, TrainingTarget guarda o candidato usado em `_place_on_platform`. Só liberar o gate depois da posição estar definida e do suporte efetivo estar validado e vinculado. Conferir `is_instance_valid(support)` antes de cada passo; se falhar, zerar o movimento, desativar patrulha, selecionar idle e emitir aviso, sem consultar ou mover em relação a uma referência liberada. Não inferir suporte apenas do caminho primário depois da seleção.

No bind do suporte, quando mudar, chamar `remove_collision_exception_with(previous_support)` antes de `add_collision_exception_with(support)`; adicionar a exceção somente se `support` for a instância efetiva e válida de `SolidPlatform`. A exceção evita contato/depenetração com a própria plataforma e não remove colisões com outros World ou Player. Manter mask 3 e `motion_mode = FLOATING`. Essa exceção vale para a simulação do corpo: consultas independentes de LOS e AOE mantêm os filtros atuais, e o suporte continua bloqueando linha de visão e área de efeito.

Calcular limites do centro do corpo a partir da borda da plataforma, do half-width real do collider e da margem vigente: 8 px no modo autoral (`AUTHORED_EDGE_MARGIN`) e 16 px no spawn aleatório (`edge_margin`). Limitar o deslocamento X pretendido antes de cada `move_and_collide(Vector2(dx, 0))`; o eixo Y permanece inalterado e nenhuma correção ou teleporte ocorre depois do movimento. Não usar `move_and_slide`, gravidade ou pulo. Valores locais provisórios: 48 px/s e 0,25 s de pausa nos limites. Movimento efetivo menor que 0,01 px conta como zero. Qualquer colisão World/Player ou limite termina o passo, deixa o visual em idle, inverte a direção e inicia a pausa de 0,25 s; em deslocamento parcial, parar exatamente no contato. Aquisição de ataque e LOS acontece primeiro no estado IDLE, de modo que um bloqueio da patrulha não bloqueia a aquisição. `flip_h` muda apenas o visual do corpo.

Na seleção autoral, construir a AABB que cobre o collider em todo o percurso e verificá-la contra World, excluindo apenas o suporte escolhido. Tentar suporte fallback se o primário não oferecer percurso livre. Os layouts atuais de três plataformas têm larguras geradas de 160–216 px; com collider 72 e margem 8, deixam 72–128 px de deslocamento do centro. No spawn aleatório, o mínimo elegível atual de 104 px deixa zero deslocamento com margem 16. Se ambos os percursos estiverem bloqueados, usar uma posição estacionária segura sobre suporte válido, desativar patrulha e emitir aviso; se não houver posição segura, manter o erro de layout existente.

Em cada atualização IDLE, executar aquisição do ataque/LOS antes de qualquer passo de patrulha. Se começar WINDUP, zerar o movimento primeiro, depois capturar o centro travado e selecionar o clip de windup; não executar passo físico nesse update. WINDUP, ACTIVE e RECOVERY não fazem passos de movimento. No cancelamento existente, ocultar o centro do ataque antes de retornar a IDLE. Um bloqueio de patrulha não afeta aquisição de LOS/AOE nem os filtros dessas consultas. Detecção, LOS, círculo, cápsula consultada, dano, deduplicação por jogador, HP, hit flash, sinal defeated e remoção permanecem com os contratos existentes.

## Arte e clips

A prancha ImageGen é ../../../../GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/referencia-tranca-lata-v1.png (SHA-256 63F1C18119C74BFF44910386F30BC640DE80555CBEB255293CB254C3A3E9E43E). Aseprite 1.3.18.6 foi confirmado pelo principal. A reprodução futura deve usar canvas64×64, centro x32, base y56, escala runtime2×, composição Cartoon V2, paleta de14 cores-base e swatch localizado #FE5B01 (até15 cores opacas), alpha binário e sem dithering. Atlas de15 cels: 960×64. Rosto, visor, tubo e torso mantêm identidade. Pistões e botas devem caber no collider existente; tornar clara a alternância de contato entre a primeira e a terceira pose walk.

A fonte e o atlas mantêm os cels atuais nos índices0–2 byte/pixel-exatos e anexam os cels3–14. Timings em milissegundos, indexação iniciando em zero:

| Índices | Clip | Frames e duração | Total |
| --- | --- | --- | --- |
| 3–6 | walk | 4 × 120 ms, loop | 480 ms |
| 7–9 | windup | 180, 220, 250 ms, uma vez | 650 ms |
| 10–11 | active | 70, 70 ms, uma vez | 140 ms |
| 12–14 | recovery | 120, 180, 1.100 ms, uma vez | 1.400 ms |

Idle usa o cel neutro14 para manter as pernas. Os cels antigos impact e disabled permanecem intactos e disponíveis. Attack clips não-loopados mantêm o último cel até a troca de estado. Um único seletor troca o clip somente quando o nome/estado visual desejado muda; não usar `is_playing() == false` como motivo para reiniciar um clip parado no último cel. `_begin_windup` atualiza o corpo imediatamente na ordem: zerar movimento, capturar centro, selecionar windup. O flash de dano usa somente o parâmetro existente `flash_amount` do shader e não toma o controle nem reinicia os clips de ataque.

## Limites e arquivos da etapa runtime

A integração posterior fica restrita a scripts/world/training_target.gd, scripts/world/main.gd, scenes/training_target.tscn, resources/enemy/training_target_sprite_frames.tres, assets/enemy/training_target/training_target.aseprite e assets/enemy/training_target/training_target-atlas.png. A produção de arte é fase anterior e escreve somente na pasta pitch-assets dedicada e nos dois assets indicados após aprovação.

scripts/player/trajectory_preview.gd já marca posições móveis de combat_enemy CharacterBody2D como mudança; manter o arquivo intocado. Preservar os caminhos e UID de recursos existentes; sidecars `.import` e arquivos UID são protegidos, e não executar importação nem abrir editor que os regenere. Não alterar cenas das salas, movimento do protagonista, worker, shader, visual do círculo, combate ou sistemas recentes protegidos. Referência ao GDD e à spec estacionária antiga serve de contexto histórico; nenhuma das duas é reescrita nesta entrega.

## Aceite

1. Animação e movimento mostram caminhada legível com corpo dentro de limites seguros no suporte efetivo, inclusive quando o suporte primário falha.
2. `spawn_pending` impede passos até posição e suporte válidos; suporte invalidado desliga patrulha e emite aviso. Só o suporte efetivo recebe exceção física, com remoção da anterior ao trocar bind.
3. A exceção não muda as consultas de LOS/AOE; o suporte segue bloqueando ambas. Bloqueio ou limite produz idle, inversão e pausa sem impedir a aquisição de ataque/LOS.
4. WINDUP zera movimento antes de capturar centro e selecionar clip; ACTIVE/RECOVERY ficam imóveis; cancelamento oculta o centro antes de voltar a IDLE.
5. Timings, dano, raio, HP e contratos de projétil permanecem iguais aos valores existentes.
6. A nova identidade visual e o nome aparecem na cena compartilhada, com face/tubo preservados e idle com pernas. Seletor só troca pelo nome/estado desejado e não reinicia clipe encerrado; hit flash usa `flash_amount`.
7. Base, hashes, sidecars `.import`, UID e caminhos protegidos são conferidos antes da integração; arte e runtime recebem revisões estáticas em estados congelados.

## Riscos conhecidos

Os cels de referência gerada precisam de reprodução manual; as poses walk1 e walk3 são parecidas e precisam de contatos distintos. O tamanho das botas pode exceder a largura nativa de 36 px do collider, então a arte deve caber no AABB atual. O spawn aleatório pode oferecer plataforma estreita sem percurso: não ampliar limites e usar o fallback imóvel com aviso. A exceção física precisa ser vinculada apenas ao suporte validado e removida se o bind mudar; as consultas de LOS/AOE devem continuar considerando o suporte. O movimento altera a invalidação do preview e a colisão dinâmica, por isso ambas precisam ser revistas estaticamente após integração. Os parâmetros de patrulha são locais provisórios, não valores finais do GDD.
