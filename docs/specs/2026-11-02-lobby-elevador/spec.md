# Especificação — lobby e início/encerramento da run

## Entrada do jogo

- A cena principal do projeto passa de RunRoot para a nova cena de lobby. A cena ajusta a câmera ao viewport real sem alterar resolução/stretch global.
- O lobby contém exatamente um Player da cena existente, com os mesmos controles, vida inicial e componentes de bola/raquete. Não cria Build ou seed. Não contém inimigos.
- A câmera fixa adapta o zoom ao viewport para manter pátio, spawn e elevador no enquadramento de referência 1152×648.
- O pátio tem piso físico contínuo e limites que impedem queda/saída do enquadramento. O ponto inicial do Player tem chão livre e distância segura da cabine.
- A oficina/bancada é cenário, não tem hitbox interativa, loja, moeda, botão de compra, NPC ou economia.
- O letreiro ambiental usa a fonte bitmap atual. A torre é uma silhueta industrial alta ao fundo à direita, com janelas quentes e vidro livre de tubos/colisões decorativas.

## Elevação e viagem

A cabine tem área interna retangular claramente legível e piso alinhado ao pátio. A viagem começa apenas quando Player vivo, apoiado no chão, e toda a cápsula 28×76 está contida na área interna. A bola, projéteis e outros corpos não podem ativar. Guardar viagem em andamento antes de await; uma única entrada dispara uma única sequência.

Sequência visual curta: portas da cabine fecham; luz âmbar pisca; câmera recebe vibração discreta em pixels inteiros; letreiro muda para ANDAR 01; fade curto; carregar RunRoot. Durante a sequência, desativar processamento do Player e BallContainer e limpar a bola ativa pelo reset existente do BallLauncher. Manter controlador/fade do lobby ativo. Não pausar globalmente a árvore; não há confirmação por tecla E.

Antes da troca, limpar RoomTransition. RunRoot inicia normalmente com seu Controller próprio: uma seed resolvida, Build vazio, multipliers 1 e HP inicial. A configuração atual do run_root.tscn permanece 1 andar, 10 salas comuns e chefe existente. Trocas internas de sala preservam HP/Build como hoje; não visitar lobby ao subir de andar.

Se carregar RunRoot falhar, apresentar erro legível; reabrir cabine e restaurar os modos anteriores do Player/BallContainer. Nova tentativa exige sair da área interna e entrar novamente. Não encerrar/consumir tentativa nem preparar seed/estado de run no lobby.

## Fim de run

- Vitória final e morte real levam a painéis pixelados curtos com resultado, posição alcançada, HP/build atuais e botão VOLTAR AO LOBBY.
- R durante qualquer painel de término real aciona o mesmo retorno.
- A troca limpa RoomTransition e descarta a árvore antiga, incluindo instância Player e projéteis. RunController libera somente a pausa que sua tela de resultado possui antes da troca; Lobby._ready não despausa uma pausa global arbitrária.
- Erro de cena no retorno mantém o resumo acessível, mostra a falha e permite tentar novamente; não converte em nova derrota, vitória ou retry de gameplay.
- O retorno só fica habilitado após fim verdadeiro da run; a tela técnica não usa esse botão.
- O caminho atual de died é mantido. O helper fail_managed_room_transition não tem chamadas no código/cenas atuais e fica intocado.
- _restart_run permanece no caminho de recuperação técnica e continua podendo recarregar RunRoot. R não troca esse retry: no painel técnico R continua sem acionar retorno; os controles técnicos existentes permanecem próprios.

## Fora de escopo e preservação

Não alterar cenas/mecânicas da run, layout/procedural, HP/dano, build/recompensas, upgrades, HUD de combate, InputMap, jogador, morte, sinalização das portas internas, RoomTransition schema, Main standalone ou recursos. Sem economia, saves, oficina ativa ou regras GDD novas. Os assets existentes são reutilizados sem reexportar/regerar PNG.
## Refinamento prospectivo do principal antes da revisão
- Autoriza-se quinto arquivo novo scripts/world/lobby_visual.gd, limitado a desenho/ambientação do pátio, torre e cabine, se separar a lógica de viagem melhorar a manutenção. Não possui estado de run, seed ou economia. O controlador continua em lobby.gd; não há autorização para outros arquivos fora dos cinco.
- No retorno normal, RunController deve liberar a pausa de sua tela de resultado antes de trocar a cena; se a troca síncrona falhar, restaurar exatamente o estado anterior e manter o resumo acessível. Lobby não deve remover uma pausa global arbitrária em _ready. Não alterar o ownership do retry técnico existente.
- Se o carregamento do elevador falhar, não iniciar tentativas em loop enquanto o Player permanecer na cabine: o rearmamento exige sair da área de entrada e entrar novamente. Restaurar processamento, porta e mensagem de erro visível; sem gerar seed ou resetar progressão nessa falha.
- Câmera/enquadramento devem levar em conta o viewport real fullscreen, mantendo colisões, porta e spawn dentro do enquadramento e desenho em pixels inteiros/nearest. Não mudar a configuração global de resolução/stretch. A referência1152x648 descreve o cenário, não prova enquadramento de qualquer janela.
- Antes de alterar produto, preservar cópias byte a byte de project.godot e run_controller.gd além dos hashes; registrar ausência dos novos arquivos. Congelar produtos antes das revisões. O helper técnico sem callers fica intacto.

## Contratos finais do principal após pareceres de plano
Gemini/Muse reforçaram contratos já previstos. A autorização do usuário é o pedido atual “certo, faça isso”; a recomendação externa de pedir outro GO do usuário não cria nova exigência de aprovação.

- A ordem de retorno é: latch antes de await; bloquear gameplay da sala (salvando process_mode da sala) e input do resultado; limpar RoomTransition; liberar somente a pausa do resultado; change_scene_to_file(lobby). A troca aceita descarta a run. Se Error síncrono, restaurar process_mode, pausa anterior, botão e mensagem do mesmo resumo. Sem alterar retry técnico.
- Diferenciar término legítimo com estado explícito habilitado pelos dois construtores de resultado (vitória/morte). R só executa retorno quando esse estado está ativo e não há painel técnico/retorno em andamento; repeat/echo ignorado. As telas técnicas mantêm _restart_run.
- Cabine: moldura visual aproximada x896..1056, piso y560. Área interna sugerida Rect2(912,448,128,112); o implementador confirma coerência com a colisão real do Player28x76 e pode ajustar esses números preservando o piso e a passagem livre. Pilares decorativos não podem bloquear a entrada lateral. Desenhar portas fechadas à frente do personagem e cenário da cabine atrás dele.
- Entrada usa AABB da cápsula física no espaço do mundo + alive + is_on_floor, exclusivamente o Player próprio. Latch e modos salvos antes de await. Rearmamento após erro exige AABB sem interseção com área interna; apenas perder contenção completa não basta. Erro fica visível até nova tentativa válida.
- Label bitmap de status/erro é nó conhecido do Lobby (ex.: ElevatorStatus); usar mensagem curta e legível em vez de logs na gameplay. O resultado possui controle/Label de erro conhecido guardado pelo Controller. Construção dinâmica, PROCESS_MODE_ALWAYS para controles de resultado enquanto pausado.
- As novas cenas não persistem seed/build; RunController resolve seed conforme sua configuração existente, inclusive seed fixa de depuração quando configurada. Não forçar randomização nem alterar o algoritmo procedural.
