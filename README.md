# Dieselpunk Noir — movimento, mira e projétil

Esta pasta contém a fundação jogável do protótipo em Godot 4.x. A primeira
entrega implementa somente o movimento do robô em uma sandbox: deslocamento
horizontal, aceleração/desaceleração, pulo com corte, coyote time, jump buffer
e dash horizontal com recarga. A base de mira independente está disponível com
uma retícula visual procedural e um primeiro tiro direto, ainda sem ricochete.

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
- `scripts/player/player_visual.gd`: visual procedural isolado da colisão.
- `scripts/projectile/projectile_config.gd`: contrato de dados do projétil.
- `scripts/projectile/ricochet_ball.gd`: bola cinética que voa em linha reta e
  expira nesta primeira fatia.
- `resources/projectile_config.tres`: parâmetros provisórios do tiro.
- `scenes/ricochet_ball.tscn`: cena física reutilizável da bola.
- `resources/player_movement_config.tres`: valores provisórios do protótipo.
- `scenes/main.tscn`: sandbox com chão, plataformas e paredes.
- `scripts/world/`: composição da sandbox e visual desenhado sem assets.

## Controles

- A/D ou setas: mover.
- W, seta para cima ou Espaço: pular.
- Clique esquerdo: lançar uma bola direta.
- Shift: dash (temporariamente desativado).

O movimento recebe apenas um eixo horizontal. O `AimController` e o `ShotOrigin`
usam o centro do personagem como referência. O `AimController` atualiza
`aim_direction` e `aim_target_position` em um canal separado, sem escrever em
`velocity`, no estado do dash ou na orientação usada pela locomoção. A retícula
visual e o lançamento direto da bola são canais separados. O lançamento usa a
direção atual do `AimController`, cria a bola em `BallContainer` e permite
apenas uma bola ativa por vez. A bola desaparece ao colidir com o mundo ou ao
atingir o tempo de vida; a reflexão será adicionada no próximo slice.

## Decisões provisórias

Os valores de velocidade, aceleração, gravidade, pulo, tolerâncias e dash são
apenas pontos de partida para teste. Eles ficam no Resource para que o ajuste
de sensação não exija editar a lógica do componente. O protótipo permite uma
carga de dash aéreo por contato com o chão; essa política ainda deve ser
validada. Invulnerabilidade, interações do dash, combate, mira e builds ainda
não fazem parte desta etapa.

## Validação manual inicial

1. Abrir a pasta no Godot 4.7 e executar a cena principal.
2. Confirmar movimento nos dois sentidos e desaceleração ao soltar a tecla.
3. Confirmar pulo no chão, pulo ao tocar uma plataforma e tolerância curta ao
   sair da borda.
4. Pressionar W, seta para cima ou Espaço pouco antes de tocar o chão e
   confirmar o jump buffer.
5. Pressionar Shift e confirmar que o dash permanece desativado.
6. Sair da área inferior e confirmar o retorno ao ponto inicial.
7. Mover o mouse ao redor do jogador e confirmar que a retícula acompanha o
   cursor em 360 graus.
8. Clicar com o botão esquerdo e confirmar que uma bola percorre uma linha
   reta, desaparece ao tocar o cenário e não é afetada pelo movimento do robô.
