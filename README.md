# Dieselpunk Noir — movimento, mira, projétil e sala de combate

Esta pasta contém a fundação jogável do protótipo em Godot 4.x. A primeira
entrega implementa o movimento do robô em uma sandbox: deslocamento
horizontal, aceleração/desaceleração, pulo com corte, coyote time, jump buffer
e dash horizontal com recarga. A base de mira independente está disponível com
uma retícula visual procedural e um tiro com ricochete determinístico.

## Snapshot técnico do protótipo — 29/09/2026

O encontro começa automaticamente quando `scenes/main.tscn` termina de carregar.
O nó `CombatRoom` procura todos os nós do grupo `combat_enemy`, conta-os e
conecta o sinal `defeated` de cada um. O HUD mostra `INIMIGOS RESTANTES: N` e,
quando o último inimigo emite `defeated`, mostra `ÁREA LIMPA — SALA CONCLUÍDA` e
emite `room_cleared` uma única vez. Uma cena sem nós nesse grupo já inicia como
área limpa. O controlador usa o grupo e os caminhos dos labels como parâmetros,
por isso não depende de um nome único de alvo.

O `TrainingTarget` é a representação passiva provisória do Operário de
contenção: ele tem 3 pontos de vida e recebe 1 de dano quando a bola entra no
ramo de ricochete válido. O primeiro contato direto pode causar dano se a
colisão resultar em ricochete e ainda houver bounce disponível; contatos de
slide/raspão e colisões após o limite não são hits danosos. A bola pode estar
ativa uma por vez e tem no máximo três ricochetes globais. Um mesmo alvo é
deduplicado dentro do mesmo tick da física da bola. Ao chegar a zero, o alvo
emite `defeated` uma única vez e é removido da cena. Esses valores e regras
servem ao teste atual e ainda não são balanceamento final.

Implementado neste snapshot: fluxo automático de uma sala, contador e estado de
limpeza no HUD, contrato `defeated`/`room_cleared`, dano condicionado ao
ricochete válido e suporte a vários nós no grupo de inimigos. Provisório:
3 HP, 1 dano, limite de três ricochetes, um alvo passivo e a composição da
sandbox. Pendente: IA e ataques de inimigos, vida/dano do jogador, gatilhos ou
portas de sala, recompensas, transições, raquete e builds. A base do jogo ainda está em desenvolvimento, mas este snapshot já passou pelas verificações automatizadas descritas abaixo.

## Verificação automatizada — 29/09/2026

Passaram 35 verificações integradas executadas por um script temporário fora da árvore do projeto. Elas cobriram a disponibilidade dos nós visuais antes da execução da cena, dimensões e geometria (incluindo o piso nativo), isolamento de tamanho/cor entre plataformas, orientação do jogador nos dois sentidos, caminhada sob a plataforma C em ambos os sentidos, início do dash, ricochete na base, HP/barra/flash do alvo, emissão única de **room_cleared** e remoção do alvo.

Outras 12 verificações usaram uma instância em modo de edição. Elas confirmaram a prévia no editor, a sincronização de visual e colisor de Floor e das plataformas com size, o redimensionamento ao vivo de C e que o Player não se move durante essas mudanças. O script temporário de inspeção emitiu avisos ao encerrar; eles não ocorreram nos testes de runtime ou renderização.

O import e parse limpos também passaram no Godot 4.7.2 numa cópia temporária das mesmas cenas, scripts e recursos, sem addons nem caches antigos. A cena principal abriu no projeto original após preservar a DLL temporária preexistente do plugin Git; houve avisos ao gravar cache devido às permissões do ambiente de execução. Nenhuma ACL foi alterada. A DLL original e o manifesto do addon foram preservados.

Essas verificações automatizadas não avaliam sensação dos controles. O checklist manual abaixo continua pendente; não foi executado nesta rodada.

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
- `scripts/projectile/projectile_config.gd`: contrato de dados do projétil.
- `scripts/projectile/bounce_resolver.gd`: regra pura de reflexão pela normal
  da superfície.
- `scripts/projectile/ricochet_ball.gd`: bola cinética com contador de impactos,
  limite de ricochetes e ciclo de vida.
- `resources/projectile_config.tres`: parâmetros provisórios do tiro.
- `scenes/ricochet_ball.tscn`: cena física reutilizável da bola.
- `resources/player_movement_config.tres`: valores provisórios do protótipo.
- `scripts/world/training_target.gd`: alvo estático provisório com vida, dano, sinal `defeated` e sincronização de cor/barra com seus nós visuais nativos.
- `scenes/training_target.tscn`: alvo físico de treino da sandbox.
- `scripts/world/combat_room.gd`: controlador reutilizável do contador e da conclusão da sala.
- `scenes/main.tscn`: sandbox com fundo e piso nativos, paredes, jogador, plataformas e alvo de treino.
- `scenes/solid_platform.tscn`: plataforma reutilizável com visual e colisor no mesmo `StaticBody2D` e tamanho editável.
- `scripts/world/`: comportamento e sincronização da composição da sandbox, sem arte de mundo desenhada em `_draw`.

## Editar o layout no Godot

Abra **scenes/main.tscn** no Godot e use a aba **2D** para ver a composição completa sem iniciar o jogo. Selecione **Floor**, **PlatformA**, **PlatformB** ou **PlatformC** na árvore e mova o nó raiz para deslocar juntos o **CollisionShape2D** e o visual. Para redimensionar, altere **size** no Inspector; essa propriedade controla o retângulo de colisão, o preenchimento e a borda superior. A propriedade **fill_color** troca a cor do preenchimento. O piso usa o centro (576, 604), tamanho (1152, 88) e permanece em um único nó com arte e colisão.

O vão livre entre a parte inferior de **PlatformC** (y=464) e o piso (y=560) é de 96 px. A cápsula do jogador tem 76 px de altura; mantenha o vão acima de 76 px para preservar a passagem sob a plataforma. A posição inicial no layout é (160, 560), mas o retorno do jogador após cair ainda usa essa mesma coordenada fixa em **scripts/world/main.gd**.

## Controles

- A/D ou setas: mover.
- W, seta para cima ou Espaço: pular.
- Clique esquerdo: lançar uma bola cinética.
- Shift: dash horizontal.

O movimento recebe apenas um eixo horizontal. O `AimController` e o `ShotOrigin`
usam o centro do personagem como referência. O `AimController` atualiza
`aim_direction` e `aim_target_position` em um canal separado, sem escrever em
`velocity`, no estado do dash ou na orientação usada pela locomoção. A retícula
visual e o lançamento da bola são canais separados. O lançamento usa a
direção atual do `AimController`, cria a bola em `BallContainer` e permite
apenas uma bola ativa por vez. A bola preserva sua velocidade, reflete pela
normal da superfície até três vezes e desaparece ao atingir o limite ou o
tempo de vida. O dano do alvo só é aplicado no ramo de ricochete válido; o
primeiro contato direto pode ser danoso, enquanto contatos de slide/raspão e
colisões após o limite de bounce não são. O mesmo alvo não recebe dois eventos
da mesma bola no mesmo tick. Enquanto o
lançador está livre, o preview usa consultas de forma com o mesmo raio e
máscara de colisão da bola para desenhar o caminho provável; ele desaparece
durante o voo.

## Decisões provisórias

Os valores de velocidade, aceleração, gravidade, pulo, tolerâncias e dash são
pontos de partida para teste no Resource. O dash horizontal está ativo, com
uma carga aérea que se recupera ao tocar o chão, bloqueia ao encontrar uma
parede e tem recarga após o uso. A sensação e o tempo de recarga ainda devem
ser validados. Invulnerabilidade e interações contextuais do dash ainda devem ser validadas. O alvo de treino já cobre o primeiro contato de combate; o combate amplo e os sistemas de builds continuam pendentes. Ele usa 3 pontos de vida e recebe 1 dano por impacto como valores provisórios configuráveis; como a bola tem limite de três ricochetes, os três acertos podem exigir disparos separados.

## Checklist de validação manual

1. Abrir a pasta no Godot 4.7 e executar a cena principal.
2. Confirmar movimento nos dois sentidos e desaceleração ao soltar a tecla.
3. Confirmar pulo no chão, pulo ao tocar uma plataforma e tolerância curta ao
   sair da borda.
4. Pressionar W, seta para cima ou Espaço pouco antes de tocar o chão e
   confirmar o jump buffer.
5. Pressionar Shift no chão e no ar; confirmar o dash horizontal, a interrupção
   ao atingir uma parede, a recarga e a recuperação da carga aérea ao tocar o chão.
6. Sair da área inferior e confirmar o retorno ao ponto inicial.
7. Mover o mouse ao redor do jogador e confirmar que a retícula acompanha o
   cursor em 360 graus.
8. Clicar com o botão esquerdo contra o chão, teto, paredes e plataformas e
   confirmar que a bola reflete até três vezes sem ser afetada pelo movimento
   do robô.
9. Antes de disparar, comparar a linha prevista com o trajeto real nas paredes,
   no piso e nos cantos; mover o jogador e a mira para confirmar que o preview
   acompanha ambos.
10. Confirmar que o preview some durante o voo e reaparece quando a bola termina.
11. Atingir o alvo de treino; conferir o flash, a redução da barra de vida e
    o contador do HUD até a remoção após três impactos válidos. Separar os
    disparos se a bola atingir o limite de ricochetes antes dos três acertos.
