# Especificação — lobby e início/encerramento da run

## Entrada do jogo

- A cena principal do projeto passa de RunRoot para a nova cena de lobby.
- O lobby contém exatamente um Player da cena existente, com os mesmos controles, vida inicial e componentes de bola/raquete. Não cria Build ou seed. Não contém inimigos.
- Uma câmera fixa mantém pátio e elevador dentro de um enquadramento lógico de 1152×648.
- O pátio tem piso físico contínuo e limites que impedem queda/saída do enquadramento. O ponto inicial do Player tem chão livre e distância segura da cabine.
- A oficina/bancada é cenário, não tem hitbox interativa, loja, moeda, botão de compra, NPC ou economia.
- O letreiro ambiental usa a fonte bitmap atual. A torre é uma silhueta industrial alta ao fundo à direita, com janelas quentes e vidro livre de tubos/colisões decorativas.

## Elevação e viagem

A cabine tem área interna retangular claramente legível e piso alinhado ao pátio. A viagem começa apenas quando Player vivo, apoiado no chão, e toda a cápsula 28×76 está contida na área interna. A bola, projéteis e outros corpos não podem ativar. Guardar viagem em andamento antes de await; uma única entrada dispara uma única sequência.

Sequência visual curta: portas da cabine fecham; luz âmbar pisca; câmera recebe vibração discreta em pixels inteiros; letreiro muda para ANDAR 01; fade curto; carregar RunRoot. Durante a sequência, desativar processamento do Player e BallContainer e limpar a bola ativa pelo reset existente do BallLauncher. Manter controlador/fade do lobby ativo. Não pausar globalmente a árvore; não há confirmação por tecla E.

Antes da troca, limpar RoomTransition. RunRoot inicia normalmente com seu Controller próprio: uma seed resolvida, Build vazio, multipliers 1 e HP inicial. A configuração atual do run_root.tscn permanece 1 andar, 10 salas comuns e chefe existente. Trocas internas de sala preservam HP/Build como hoje; não visitar lobby ao subir de andar.

Se carregar RunRoot falhar, apresentar erro legível; reabrir cabine, limpar guard e restaurar os modos de processamento anteriores do Player/BallContainer para permitir outra tentativa. Não encerrar/consumir tentativa e não preparar seed nem estado de run no lobby.

## Fim de run

- Vitória final e morte real levam a painéis de resumo curtos com resultado e botão VOLTAR AO LOBBY.
- R durante qualquer painel de término real aciona o mesmo retorno.
- A troca limpa RoomTransition e descarta a árvore antiga, incluindo instância Player e projéteis. O lobby novo usa um Player novo e despausa a árvore herdada do painel de término.
- Erro de cena no retorno mantém o resumo acessível, mostra a falha e permite tentar novamente; não converte em nova derrota, vitória ou retry de gameplay.
- O retorno só fica habilitado após fim verdadeiro da run; a tela técnica não usa esse botão.
- O caminho atual de died é mantido. O helper fail_managed_room_transition não tem chamadas no código/cenas atuais e fica intocado.
- _restart_run permanece no caminho de recuperação técnica e continua podendo recarregar RunRoot. R não troca esse retry: no painel técnico R continua sem acionar retorno; os controles técnicos existentes permanecem próprios.

## Fora de escopo e preservação

Não alterar cenas/mecânicas da run, layout/procedural, HP/dano, build/recompensas, upgrades, HUD de combate, InputMap, jogador, morte, sinalização das portas internas, RoomTransition schema, Main standalone ou recursos. Sem economia, saves, oficina ativa ou regras GDD novas. Os assets existentes são reutilizados sem reexportar/regerar PNG.