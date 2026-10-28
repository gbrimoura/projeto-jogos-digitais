# Plano — animações e patrulha do Tranca-Lata

**Data:** 19/10/2026.  
**Estado:** proposta congelada para revisão; arte Aseprite e runtime ainda não autorizados nesta fase.  
**Base:** cópias e SHA-256 dos seis arquivos runtime em historico/base/. A base inclui as alterações locais preexistentes em scripts/world/main.gd e scripts/world/training_target.gd.

## Objetivo

Dar ao inimigo atualmente identificado internamente como TrainingTarget uma identidade visível, locomoção curta sobre a própria plataforma e animações de ataque legíveis. O novo nome visível é **Tranca-Lata**. O movimento não persegue o jogador nem atravessa plataformas. O ataque preserva a área e os tempos já implementados.

## Contrato atual

A cena compartilhada usa um StaticBody2D na layer 8, máscara 0 e CollisionShape2D retangular de 72×96. O sprite é centralizado, 64×64, escala 2×, centro x=32 e base y=56. O estado atual é imóvel. O ataque usa raio 140 px, windup de 650 ms, janela ativa de 140 ms, recovery de 1.400 ms e dano 1; o centro é capturado ao iniciar o windup. A vida padrão é 3 e o flash de dano dura 120 ms. O registro anterior em ../2026-10-14-alvo-ataque-area/ continua sendo o histórico do comportamento estacionário e não deve ser reescrito.

## Decisões propostas

- Preservar class_name TrainingTarget, o caminho scenes/training_target.tscn e o node path TrainingTarget usado por Main e pelas salas. Trocar apenas a identidade apresentada: propriedade display_name e NameLabel na cena compartilhada com o texto Tranca-Lata.
- Converter o corpo para CharacterBody2D, mantendo layer 8 e configurando mask 3 para World e Player. Assim o movimento físico respeita paredes, plataformas e o jogador; a bola continua atingindo a layer Damageable 8 pelo seu mask 9. Não adicionar dano por contato.
- Andar apenas no eixo X sobre a plataforma já escolhida para o spawn. Valores locais provisórios: 48 px/s e pausa de 0,25 s nas pontas. Limitar o deslocamento horizontal pretendido antes da chamada a move_and_collide(Vector2(dx, 0)) ao retângulo de colisão de 72×96 acrescido da margem daquele modo de spawn. O Y fica fixo na altura da mesma plataforma, sem move_and_slide, gravidade, pulo, perseguição ou salto entre suportes; não corrigir Y depois do movimento nem teleportar. Usar o deslocamento realmente percorrido para decidir walk: em bloqueio sem movimento efetivo, parar em idle, inverter o sentido e aplicar pausa de 0,25 s quando apropriado. Em colisão parcial, parar na posição de contato e inverter o sentido; na ponta da plataforma, inverter e pausar 0,25 s.
- Parar a patrulha em WINDUP, ACTIVE e RECOVERY; manter fixo o centro do ataque já capturado no início do windup. Se o ataque for cancelado pelas condições existentes, retomar a patrulha quando voltar a IDLE.
- No layout autoral, Main deve expor o suporte que realmente venceu a seleção entre o caminho primário e o fallback. Validar a varredura horizontal completa contra World, ignorando somente o suporte escolhido, antes de eleger o percurso. Tentar o fallback quando o primário não comportar um percurso livre. Se não houver percurso útil, escolher uma posição segura e manter o alvo estacionário com aviso; manter a falha atual da sala se nem a posição estacionária for segura.
- No spawn aleatório, guardar a instância de SolidPlatform escolhida e derivar os limites dela, sem recalcular pelo caminho primário. O caminho atual permite plataformas de 104 px, que deixam percurso horizontal zero com margem 16; esse caso deve manter o alvo estável e emitir aviso. Não mover para fora do suporte.
- Usar flip_h apenas na animação do corpo para indicar a direção da patrulha. Não espelhar collider, HUD, área de ataque ou centro travado. O rosto mantém a orientação frontal existente em todos os cels.
- A trajetória do projétil já observa posições de combat_enemy CharacterBody2D em scripts/player/trajectory_preview.gd. A conversão fará o preview detectar o deslocamento; esse arquivo não precisa mudar.

## Arte e temporização

A prancha ImageGen preparada pelo principal fica em ../../../../GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/referencia-tranca-lata-v1.png, SHA-256 63F1C18119C74BFF44910386F30BC640DE80555CBEB255293CB254C3A3E9E43E. Ela é referência visual para reprodução no Aseprite, não atlas pronto. A pasta pitch-assets/tranca-lata-animacoes-v1 receberá a fonte Aseprite, script Lua, metadata e previews somente na fase de arte autorizada.

Manter canvas 64×64, escala runtime 2×, centro x=32, edge de base y=56 e os três cels atuais pixel-exatos. Acrescentar 12 cels, totalizando 15 cels e atlas de 960×64: walk nos índices 3–6, windup 7–9, active 10–11 e recovery 12–14, em índices começando por zero. Reproduzir a paleta Cartoon V2 (14 cores-base e o swatch localizado #FE5B01), contorno azul-preto, alpha binário e arestas em pixels nítidas. Preservar rosto, visor, tubo e torso. A perna curta de pistão e as botas devem caber na silhueta do collider atual; reforçar a alternância de contato entre a primeira e a terceira pose walk da referência.

| Clip | Cels | Duração por cel | Total e playback |
| --- | --- | --- | --- |
| walk | 3–6 | 120 ms cada | 480 ms, loop enquanto move |
| windup | 7–9 | 180 / 220 / 250 ms | 650 ms, uma vez; manter a última pose até a fase seguinte |
| active | 10–11 | 70 ms cada | 140 ms, uma vez; manter a última pose até recovery |
| recovery | 12–14 | 120 / 180 / 1.100 ms | 1.400 ms, uma vez; manter a última pose até IDLE |

O clip idle usa o novo cel neutro 14, que conserva as pernas. Os clips antigos impact e disabled permanecem acessíveis e seus cels originais permanecem inalterados. O flash de dano de 120 ms usa o shader existente, sem interromper nem reiniciar os clips de ataque. Atualizações visuais não podem reiniciar um clip não-loopado por ele estar parado no último cel. O ritmo do corpo acompanha os timers autoritativos; não muda o relógio da física.

## Escopo da implementação posterior

Após revisão do plano e autorização de cada fase, a arte poderá escrever em ../../../../GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/ e substituir somente assets/enemy/training_target/training_target.aseprite e training_target-atlas.png. A integração poderá alterar scripts/world/training_target.gd, scripts/world/main.gd, scenes/training_target.tscn e resources/enemy/training_target_sprite_frames.tres. O estado original desses seis arquivos já está congelado em historico/base/.

Player, RivetWorker, shader de flash, containment_attack_visual.gd, ricochet_ball.gd, trajectory_preview.gd, cenas das salas, gerador de salas, recursos de projétil e demais arquivos recentes ficam protegidos. Não alterar vida, dano, raio, timers de combate, colisões de ataque, invulnerabilidade, spawn de projéteis ou cadência. Não fazer commit, push ou mudança de branch.

## Critérios de aceite

- Tranca-Lata aparece com o nome visível na cena compartilhada e mantém identificadores técnicos atuais.
- Em IDLE, desloca-se somente dentro dos limites seguros do suporte efetivamente escolhido; nunca cai, atravessa World/Player ou tenta perseguir o jogador.
- A varredura planejada cabe na plataforma e não cruza obstáculos de World; a seleção tenta o fallback antes de aceitar patrulha reduzida. Um percurso inexistente deixa o alvo parado em posição segura e gera aviso.
- WINDUP, ACTIVE e RECOVERY param o corpo e mantêm o centro do círculo travado. O ataque continua causando no máximo o comportamento/dano existente e não causa dano por toque.
- Walk loopa apenas durante movimento; windup/active/recovery respeitam exatamente os tempos existentes. Idle mostra as novas pernas, hit flash continua usando somente o shader, e os três cels anteriores não mudam pixel a pixel.
- Projéteis e preview continuam reconhecendo o alvo Damageable; o preview se atualiza quando ele anda.

## Revisão e validação

A proposta passa por revisão somente leitura antes da produção da arte. Depois da autorização, produzir e inspecionar a reprodução Aseprite como frente isolada; integrar o runtime somente após congelar a arte aprovada. Revisões estáticas obrigatórias são conduzidas pelo principal sobre cada estado congelado. Nenhuma execução Godot, importação, teste ou QA foi autorizada nesta fase.
