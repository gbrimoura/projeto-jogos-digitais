# Dieselpunk Noir — movimento, mira, projétil e sala de combate

Esta pasta contém a fundação jogável do protótipo em Godot 4.x. A primeira
entrega implementa o movimento do robô em uma sandbox: deslocamento
horizontal, aceleração/desaceleração, pulo com corte, coyote time, jump buffer
e dash horizontal com recarga. A base de mira independente está disponível com
uma retícula visual procedural e um tiro com ricochete determinístico.

## Snapshot técnico do protótipo — 03/10/2026

A cena principal mantém o `TrainingTarget` estático para comparação e acrescenta um `RivetWorker` terrestre. `CombatRoom` inicia automaticamente, conta os dois nós do grupo `combat_enemy`, acompanha `defeated` e emite `room_cleared` uma vez quando ambos são removidos. O HUD mostra inimigos restantes, vida e estado do encontro. Rebites hostis ativos são cancelados ao limpar a sala.

O Operário tem 3 HP. Patrulha o piso dentro de uma área editável em Main, entre os Marker2D LeftLimit e RightLimit do WorkerPatrolArea, a 90 px/s e com pausa de 0,35 s nas pontas. A prévia Line2D é discreta e aparece somente no editor. Os limites usam as posições globais dos marcadores, são normalizados quando invertidos e devem cobrir piso contínuo; o Operário não salta buracos. Se a área não deixar espaço útil para o corpo, ele fica imóvel e emite um aviso. Sem área associada, a cena reutilizável usa uma largura total de 500 px centrada na posição global do spawn. Em aproximação e reposicionamento, move-se a até 150 px/s sem sair desses limites. Após a guarda de distância mínima e qualquer recuo prioritário, o cooldown faz a IA patrulhar antes das consultas de alcance e linha de tiro, inclusive fora da faixa de ataque; depois do cooldown, aproxima-se se ainda estiver fora de alcance. Com cooldown zerado, aproxima-se se estiver fora de alcance; sem linha de tiro, procura reposicionar e patrulha se não encontrar uma posição clara; sem jogador presente também patrulha, mas para quando o jogador está morto. Se o spawn estiver fora dos limites, retorna andando ao limite seguro antes de decidir ataque ou recuo; não teleporta. Se o jogador continuar perto após o único recuo de até 64 px por ciclo, espera imóvel até a distância ficar segura. O aviso de tiro permanece travado por 0,65 s, seguido por rebite reto a 400 px/s, 1 de dano e recuperação de 0,8 s; cooldown configurado de 2,6 s mantém intervalo efetivo mínimo de cerca de 3,25 s. Paredes e plataformas absorvem o rebite. O corpo do inimigo não causa dano.

O jogador agora tem 5 HP provisórios. Cada rebite causa 1 de dano; o acerto concede 0,8 s de invulnerabilidade visual. O dash não concede invulnerabilidade e não há knockback novo. Ao morrer, o jogador para, a bola ativa e os rebites são cancelados, o HUD mostra `DERROTA` e a tecla R recarrega a cena, restaurando sala, inimigos e vida. Nas camadas de física, `World` usa o índice 1 (bitmask 1), `Player` o índice 2 (bitmask 2), `Damageable` o índice 4 (bitmask 8) e `HostileProjectile` o índice 5 (bitmask 16). A máscara 3 do rebite seleciona `World` e `Player`; ele não ricocheteia.

| Estado | Conteúdo deste snapshot |
|---|---|
| **Implementado** | Sala 01: `CombatRoom` conta os dois inimigos e libera a porta E após `room_cleared`; E só solicita entrada para jogador vivo no sensor e `Main` revalida sala/jogador. A porta não gera salas: `Main` usa o destino configurado, preserva HP atual/máximo sem cura, limpa estados temporários e posiciona pelo `PlayerSpawnMarker`. Sala 02 manual reutiliza HUD, controles e inimigos existentes, sem saída seguinte; R após derrota reinicia a sala atual. Patrulha, ataque, parry e projéteis existentes preservados. |
| **Provisório** | Operário e alvo com 3 HP; patrulha a 90 px/s com pausa de 0,35 s e fallback de 500 px; movimento de combate a 150 px/s; rebite com 400 px/s e 1 dano; jogador com 5 HP e 0,8 s de invulnerabilidade; faixa de ataque 220–360 px; aviso sonoro/visual de 0,65 s; recuperação 0,8 s; cooldown 2,6 s (intervalo efetivo mínimo ~3,25 s); recuo máximo de 64 px; composição e posições da sandbox. |
| **Pendente** | Ajuste de sensação, balanceamento e legibilidade em runtime; validação no Godot; inimigos e padrões adicionais; controles e remapeamento definitivos; builds, recompensas, economia e regras finais de morte/progressão da run; integração procedural futura das salas. |

A patrulha foi validada pelo usuário e passou por três revisões estáticas do Claude Opus 5.5 High; dois P2 foram corrigidos e a revisão final não encontrou P1/P2 remanescentes. O parry e a porta também passaram por revisões estáticas finais sem P1/P2 remanescentes. Nenhuma execução no Godot foi feita pelo agente nesta alteração.

Este snapshot foi atualizado em 03/10/2026. O agente não executou import, parse, runtime ou testes no Godot nesta alteração; a integração visual e o comportamento jogável não foram validados pelo agente.

## Organização

- `scenes/player.tscn`: cena reutilizável do protagonista.
- `scripts/player/player.gd`: traduz o InputMap em comandos de movimento e
  coordena os componentes do jogador.
- `scripts/player/movement_controller.gd`: física e estados do movimento.
- `scripts/player/movement_config.gd`: contrato de parâmetros configuráveis.
- `scripts/player/aim_controller.gd`: direção do mouse em 360 graus, separada
  da locomoção.
- `scripts/player/reticle_visual.gd`: retícula procedural que acompanha o alvo
  da mira sem participar da física.
- `scripts/player/ball_launcher.gd`: dispara uma bola por vez usando um snapshot
  da mira.
- `scripts/player/trajectory_preview.gd`: prevê o caminho circular da bola com
  ricochetes antes do disparo.
- `scripts/player/player_visual.gd`: orientação e efeito de dash aplicados aos nós visuais nativos do jogador.
- `scripts/player/player_health.gd`: vida do jogador, invulnerabilidade temporária e sinal de derrota.
- `scripts/projectile/projectile_config.gd`: contrato de dados do projétil.
- `scripts/projectile/bounce_resolver.gd`: regra pura de reflexão pela normal
  da superfície.
- `scripts/projectile/ricochet_ball.gd`: bola cinética com contador de impactos,
  limite de ricochetes e ciclo de vida.
- `scripts/projectile/hostile_rivet.gd`: rebite hostil reto, com colisão contínua,
  tempo de vida, deduplicação de alvo e cancelamento seguro.
- `resources/projectile_config.tres`: parâmetros provisórios do tiro.
- `scenes/ricochet_ball.tscn`: cena física reutilizável da bola.
- `resources/player_movement_config.tres`: valores provisórios do protótipo.
- `scripts/world/training_target.gd`: alvo estático provisório com vida, dano, sinal `defeated` e sincronização de cor/barra com seus nós visuais nativos.
- `scenes/training_target.tscn`: alvo físico de treino da sandbox.
- `scripts/enemy/rivet_worker.gd` e `scenes/rivet_worker.tscn`: Operário terrestre com patrulha e limites configuráveis, aviso de mira travada, consultas locais de piso/linha de visão e ciclo de disparo editável no Inspector.
- `scenes/hostile_rivet.tscn`: rebite hostil visualizado com formas nativas editáveis.
- `scripts/world/combat_room.gd`: controlador reutilizável do contador e da conclusão da sala.
- `scripts/world/exit_door.gd` e `scenes/exit_door.tscn`: porta reutilizável editável que controla bloqueio/alcance e emite o pedido de entrada.
- `scripts/world/room_transition.gd`: payload de uso único para transferir HP atual/máximo entre cenas fixas.
- `scenes/second_room.tscn`: fixture fixa editável da Sala 02, com seu marcador de spawn, HUD e combate compatíveis.
- `scenes/main.tscn`: sandbox com fundo e piso nativos, paredes, jogador, plataformas, alvo de treino, área de patrulha editável e Operário lançador.
- `scenes/solid_platform.tscn`: plataforma reutilizável com visual e colisor no mesmo `StaticBody2D` e tamanho editável.
- `scripts/world/enemy_patrol_area.gd`: área reutilizável de patrulha com prévia visual exclusiva do editor.

## Editar o layout no Godot

Abra **scenes/main.tscn** no Godot e use a aba **2D** para ver a composição completa sem iniciar o jogo. Selecione **Floor**, **PlatformA**, **PlatformB** ou **PlatformC** na árvore e mova o nó raiz para deslocar juntos o **CollisionShape2D** e o visual. Para redimensionar, altere **size** no Inspector; essa propriedade controla o retângulo de colisão, o preenchimento e a borda superior. A propriedade **fill_color** troca a cor do preenchimento. O piso usa o centro (576, 604), tamanho (1152, 88) e permanece em um único nó com arte e colisão. Selecione **WorkerPatrolArea** e mova **LeftLimit** ou **RightLimit** na aba 2D para ajustar o percurso do Operário. A linha discreta é uma prévia exclusiva do editor; a área usa as posições globais dos marcadores, enquanto o inimigo mantém seus próprios limites durante o movimento.

Checklist de regressão da patrulha (já validada pelo usuário; não executada pelo agente nesta alteração):

- Mover `LeftLimit` e `RightLimit` na aba 2D e confirmar que o percurso muda e que a prévia acompanha os marcadores.
- Observar a pausa de 0,35 s nas duas extremidades, inclusive com os marcadores invertidos.
- Conferir que o corpo permanece entre os limites e que um spawn externo retorna caminhando sem teleporte.
- Confirmar que `PreviewLine` só aparece no editor e que uma área sem faixa útil deixa o Operário imóvel com aviso.
- Com cooldown ativo e jogador em PlatformB, verificar que alternâncias de linha de tiro não mudam a patrulha para reposicionamento a cada quadro.

## Atualização 03/10/2026 — porta e segunda sala

A porta nativa exibe bloqueio até `room_cleared`; E solicita a transição apenas para um jogador vivo dentro do sensor. `Main` valida novamente sala/jogador e carrega o destino configurado por `next_room_scene_path`. Se o recurso falhar, a porta retorna aberta para nova tentativa.

A transição mantém HP atual e máximo, sem cura. A sala nova cria jogador/estado de combate novos e posiciona pela `PlayerSpawnMarker`; o payload é de uso único e vinculado ao path de destino. R após derrota reinicia a sala atual, restaurando jogador e inimigos.

`scenes/second_room.tscn` é uma fixture manual sem porta seguinte: pode iniciar com F6 e usa os inimigos, HUD e controles existentes. A integração procedural futura configura o destino no controlador; a porta somente emite o pedido e não gera salas. Recompensas e fim da run continuam fora do escopo. Na Main, a saída fica à direita e os HUDs identificam Sala 01/02. R após derrota reinicia a sala atual; F6 inicia a Sala 02 com 5/5 HP; queda abaixo de y=760 reposiciona no marcador sem alterar o HP.

A revisão estática final do código e das cenas não encontrou achados P1/P2. A revisão inicial identificou uma divergência entre um destino salvo como UID `uid://` e o `res://` reportado pela cena carregada; `Main` agora usa `PackedScene.resource_path` canônico para o payload e a troca, e descarta payload de caminho divergente. Os ajustes de posição e legibilidade da porta, brilho e consistência do HUD também foram aplicados.

Sem execução ou validação no Godot; nenhum teste foi executado. A revisão documental estática final do Claude Opus 5.5 High confirmou as divergências corrigidas e não encontrou P1/P2 remanescentes.