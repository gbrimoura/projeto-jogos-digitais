# Plano — animações e patrulha do Tranca-Lata

**Data:** 19/10/2026.  
**Estado:** revisão R2 congelada para revisão; arte Aseprite e runtime ainda não autorizados nesta fase.  
**Base:** cópias e SHA-256 dos seis arquivos runtime em historico/base/. A base inclui as alterações locais preexistentes em scripts/world/main.gd e scripts/world/training_target.gd.

## Objetivo

Dar ao inimigo atualmente identificado internamente como TrainingTarget uma identidade visível, locomoção curta sobre a própria plataforma e animações de ataque legíveis. O novo nome visível é **Tranca-Lata**. O movimento não persegue o jogador nem atravessa plataformas. O ataque preserva a área e os tempos já implementados.

## Contrato atual

A cena compartilhada usa um StaticBody2D na layer 8, máscara 0 e CollisionShape2D retangular de 72×96. O sprite é centralizado, 64×64, escala 2×, centro x=32 e base y=56. O estado atual é imóvel. O ataque usa raio 140 px, windup de 650 ms, janela ativa de 140 ms, recovery de 1.400 ms e dano 1; o centro é capturado ao iniciar o windup. A vida padrão é 3 e o flash de dano dura 120 ms. O registro anterior em ../2026-10-14-alvo-ataque-area/ continua sendo o histórico do comportamento estacionário e não deve ser reescrito.

## Decisões propostas

- Preservar class_name TrainingTarget, o caminho scenes/training_target.tscn e o node path TrainingTarget usado por Main e pelas salas. Trocar apenas a identidade apresentada: propriedade display_name e NameLabel na cena compartilhada com o texto Tranca-Lata.
- Converter o corpo para CharacterBody2D, mantendo layer 8 e configurando mask 3 para World e Player. Assim o movimento físico respeita paredes, plataformas e o jogador; a bola continua atingindo a layer Damageable 8 pelo seu mask 9. Não adicionar dano por contato.
- Andar apenas no eixo X sobre o suporte efetivamente escolhido. Valores locais provisórios: 48 px/s e pausa de 0,25 s nos limites. `spawn_pending` começa ativo; só liberar a patrulha depois de resolver a posição, validar o suporte e vinculá-lo. Guardar o `SolidPlatform` efetivo e conferir `is_instance_valid` antes de cada passo; se for inválido, zerar movimento, selecionar idle, desativar a patrulha e emitir aviso. Com `motion_mode = FLOATING`, manter mask 3 e adicionar exceção de colisão somente para o suporte vinculado; ao trocar suporte, remover a exceção anterior antes de adicionar a nova. Isso evita contato/depenetração com a própria plataforma sem remover colisões com outros World/Player. A exceção física não altera as consultas de LOS/AOE: o suporte continua bloqueando essas consultas.
- Limitar o deslocamento horizontal pretendido antes de `move_and_collide(Vector2(dx, 0))` usando o retângulo de colisão de 72×96 e a margem do modo de spawn. O Y permanece fixo na altura da plataforma: sem `move_and_slide`, gravidade, pulo, perseguição, mudança de suporte, correção vertical ou teleporte. Movimento efetivo abaixo de 0,01 px conta como zero. Qualquer bloqueio físico ou limite encerra o passo, deixa o visual em idle, inverte a direção e aplica pausa de 0,25 s. Se houve deslocamento parcial, permanecer no contato; nunca avançar além do bloqueio. Aquisição do ataque/LOS ocorre antes do passo da patrulha, e um bloqueio de patrulha nunca impede essa aquisição.
- No layout autoral, Main deve expor o suporte que realmente venceu a seleção entre o caminho primário e o fallback. Validar a varredura horizontal completa contra World, ignorando somente o suporte escolhido, antes de eleger o percurso. Tentar o fallback quando o primário não comportar um percurso livre. Se os dois percursos estiverem bloqueados, escolher posição estacionária segura sobre um suporte válido e avisar; manter a falha atual da sala se nem a posição parada for segura.
- No spawn aleatório, guardar a instância de SolidPlatform escolhida e derivar os limites dela, sem recalcular pelo caminho primário. O caminho atual permite plataformas de 104 px, que deixam percurso horizontal zero com margem 16; esse caso deve manter o alvo estável e emitir aviso. Não mover para fora do suporte. Se a referência do suporte deixar de ser válida, manter o corpo parado, desativar a patrulha e avisar.
- A atualização de IDLE deve testar primeiro a aquisição do ataque; ao iniciar WINDUP, zerar o movimento, capturar em seguida o centro e selecionar o clip de windup. Nenhum passo físico ocorre em WINDUP, ACTIVE ou RECOVERY. No cancelamento, ocultar o centro do ataque antes de voltar a IDLE. O seletor visual muda de clip apenas quando o nome/estado desejado muda; não reiniciar clips não-loopados porque `is_playing()` ficou falso no último cel. O flash continua usando apenas o shader existente e o parâmetro `flash_amount`.
- Usar flip_h apenas na animação do corpo para indicar a direção da patrulha. Não espelhar collider, HUD, área de ataque ou centro travado. O rosto mantém a orientação frontal existente em todos os cels.
- A trajetória do projétil já observa posições de combat_enemy CharacterBody2D em scripts/player/trajectory_preview.gd. A conversão fará o preview detectar o deslocamento; esse arquivo não precisa mudar.

## Arte e temporização

A prancha ImageGen preparada pelo principal fica em ../../../../GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/referencia-tranca-lata-v1.png, SHA-256 63F1C18119C74BFF44910386F30BC640DE80555CBEB255293CB254C3A3E9E43E. Ela é referência visual para reprodução no Aseprite, não atlas pronto. A pasta pitch-assets/tranca-lata-animacoes-v1 receberá a fonte Aseprite, script Lua, metadata e previews somente na fase de arte autorizada.

Manter canvas 64×64, escala runtime 2×, centro x=32, edge de base y=56 e os três cels atuais pixel-exatos. Acrescentar 12 cels, totalizando 15 cels e atlas de 960×64: walk nos índices 3–6, windup 7–9, active 10–11 e recovery 12–14, em índices começando por zero. Reproduzir a paleta Cartoon V2 (14 cores-base e o swatch localizado #FE5B01), contorno azul-preto, alpha binário e arestas em pixels nítidas. Preservar rosto, visor, tubo e torso. A perna curta de pistão e as botas devem caber na silhueta do collider atual; reforçar a alternância de contato entre a primeira e a terceira pose walk da referência. Manter os caminhos de atlas/importação e referências UID existentes; sidecars `.import` e arquivos UID ficam protegidos e não devem ser regenerados nesta fase.

| Clip | Cels | Duração por cel | Total e playback |
| --- | --- | --- | --- |
| walk | 3–6 | 120 ms cada | 480 ms, loop enquanto move |
| windup | 7–9 | 180 / 220 / 250 ms | 650 ms, uma vez; manter a última pose até a fase seguinte |
| active | 10–11 | 70 ms cada | 140 ms, uma vez; manter a última pose até recovery |
| recovery | 12–14 | 120 / 180 / 1.100 ms | 1.400 ms, uma vez; manter a última pose até IDLE |

O clip idle usa o novo cel neutro 14, que conserva as pernas. Os clips antigos impact e disabled permanecem acessíveis e seus cels originais permanecem inalterados. O flash de dano de 120 ms usa somente o parâmetro existente `flash_amount` do shader, sem interromper nem reiniciar os clips de ataque. Atualizações visuais só trocam o clip quando o nome/estado desejado muda; um clip não-loopado parado no último cel não deve reiniciar por `is_playing()` falso. `_begin_windup` atualiza o corpo imediatamente: zera movimento, captura o centro e seleciona o clip nessa ordem. O ritmo do corpo acompanha os timers autoritativos; não muda o relógio da física.

## Escopo da implementação posterior

Após revisão do plano e autorização de cada fase, a arte poderá escrever em ../../../../GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/ e substituir somente assets/enemy/training_target/training_target.aseprite e training_target-atlas.png. A integração poderá alterar scripts/world/training_target.gd, scripts/world/main.gd, scenes/training_target.tscn e resources/enemy/training_target_sprite_frames.tres. O estado original desses seis arquivos já está congelado em historico/base/.

Player, RivetWorker, shader de flash, containment_attack_visual.gd, ricochet_ball.gd, trajectory_preview.gd, cenas das salas, gerador de salas, recursos de projétil, sidecars `.import`, arquivos UID e demais arquivos recentes ficam protegidos. Preservar caminho/UID de recursos existentes; não executar importação nem deixar o editor regenerar sidecars. Não alterar vida, dano, raio, timers de combate, colisões de ataque, invulnerabilidade, spawn de projéteis ou cadência. Não fazer commit, push ou mudança de branch.

## Critérios de aceite

- Tranca-Lata aparece com o nome visível na cena compartilhada e mantém identificadores técnicos atuais.
- O gate de spawn só libera movimento com posição e suporte efetivo validados; suporte inválido desativa patrulha e avisa. A exceção física é somente do suporte atual, e LOS/AOE continuam considerando-o.
- Em IDLE, desloca-se somente dentro dos limites seguros do suporte efetivamente escolhido; nunca cai, atravessa World/Player ou tenta perseguir o jogador. Colisões e limites param, invertem direção e pausam; deslocamento abaixo de 0,01 px seleciona idle.
- A varredura planejada cabe na plataforma e não cruza obstáculos de World; a seleção tenta o fallback antes de aceitar patrulha reduzida. Um percurso inexistente deixa o alvo parado em posição segura e gera aviso.
- Aquisição de ataque/LOS antecede a patrulha em IDLE. WINDUP zera movimento antes de capturar centro e trocar clip; ACTIVE/RECOVERY não fazem passos; cancelamento oculta o centro antes de voltar a IDLE.
- Walk loopa apenas durante movimento; windup/active/recovery respeitam exatamente os tempos existentes. Seletor não reinicia clipe não-loopado parado no último cel. Idle mostra as novas pernas, hit flash usa `flash_amount` existente, e os três cels anteriores não mudam pixel a pixel.
- Projéteis e preview continuam reconhecendo o alvo Damageable; o preview se atualiza quando ele anda.

## Revisão e validação

A proposta passa por revisão somente leitura antes da produção da arte. Depois da autorização, produzir e inspecionar a reprodução Aseprite como frente isolada; integrar o runtime somente após congelar a arte aprovada. Revisões estáticas obrigatórias são conduzidas pelo principal sobre cada estado congelado. Nenhuma execução Godot, importação, teste ou QA foi autorizada nesta fase.
