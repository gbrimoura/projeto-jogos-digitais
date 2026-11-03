# Plano prospectivo — lobby e elevador de início da run

## Estado e autorização

02/11/2026. O usuário autorizou o recorte descrito abaixo. A primeira fase documentou e congelou o plano/spec; depois o principal concedeu GO explícito e a implementação foi feita no escopo de cinco arquivos de produto. Revisão final de implementação fica a cargo do principal.

O GDD externo em C:\Users\danie\Documents\ChatGPT\TEC - Jogos\GDD_Dieselpunk_Noir\04-combate-e-builds.md, seção 8, estabelece que a build é temporária e reinicia na morte e que a oficina trata de melhorias permanentes. Economia e valores da oficina continuam pendentes. A bancada aqui é somente cenário, sem loja, moeda, NPC ou interação.

## Recorte acordado

- Abrir o jogo no pátio/lobby industrial, com uma torre alta ao fundo. Uma bancada de manutenção pequena serve de ambientação; o elevador focal mostra ELEVADOR / ANDAR 01.
- A mesma cena de lobby permite caminhar, pular, dash, mirar, lançar bola e usar a raquete. Não há inimigos. O piso é contínuo, os limites são sólidos e o jogador não pode cair para fora do enquadramento.
- Caminhar inteiramente para dentro da cabine, enquanto está vivo e no chão, inicia a viagem sem tecla de interação. A colisão inteira do jogador deve caber no retângulo interno da cabine, não apenas tocar um Area2D. O teste usa a instância Player da cena, nunca a bola, e um latch é armado antes de qualquer await para impedir viagens duplicadas.
- A viagem fecha portas, pisca luzes, aplica vibração visual curta, exibe ANDAR 01 e faz fade curto. A chamada de troca carrega a cena de run existente. Em erro, a mensagem permanece visível, portas reabrem e os modos anteriores são restaurados; para tentar de novo, o jogador precisa sair da área interna e entrar novamente.
- Ao vencer o chefe final ou morrer, RunController mostra resumo curto e um botão VOLTAR AO LOBBY. R durante esse estado faz a mesma ação. O retorno descarta a cena da run. Uma nova entrada no elevador cria uma instância nova de RunController e uma run nova.
- Manter retry técnico separado. Erros de geração/carregamento continuam no painel técnico recuperável com mesma seed/retry existente; _restart_run continua disponível a esse painel. Erro técnico não passa pelo resumo de derrota. A rotina fail_managed_room_transition foi localizada sem caller em scripts/scenes atuais; não redirecioná-la nem alterar o caminho real de morte sem evidência concreta.
- Avanços entre salas e o chefe continuam dentro do fluxo atual: 10 salas comuns e o chefe, um andar configurado; sem lobby/elevador intermediário. A Main standalone e sua porta/snapshot permanecem intactas.
- Uma run nova começa no contrato existente de RunController: novo RunBuild vazio, multiplicadores em 1, vida inicial do Player e seed resolvida pelo Controller. O lobby não mantém ou cria Build, snapshot, seed ou persistência. RunController._ready já limpa o snapshot de RoomTransition.

## Composição visual e movimento

Usar a moldura lógica existente de 1152×648, câmera fixa centrada em (576, 324) e sem follow do Player. O personagem reaproveitado tem corpo de colisão 28×76 px, origem nos pés e velocidade/gravidade já configuradas. Layout inicial a confirmar na cena:

- piso contínuo com topo em y=560, limites laterais sólidos próximos das bordas;
- spawn seguro à esquerda, em (240, 560);
- bancada baixa e puramente visual à esquerda, aproximadamente x=150–320;
- cabine à direita, aproximadamente x=896–1056, com piso no mesmo nível do pátio e interior suficiente para conter a cápsula inteira;
- torre/fachada alta no fundo à direita, com janelas âmbar. Não sobrepor tubos aleatórios ao vidro nem bloquear o vão da cabine.

Reutilizar o atlas de fábrica atual de 128×128 com células 32×32: a fileira 0 contém bordas superiores de piso e a fileira 3 bordas inferiores. Reutilizar também os módulos/recursos de fábrica existentes conforme as regiões e âncoras já registradas. Combiná-los com formas nativas em coordenadas inteiras e nearest-neighbor. Reutilizar a fonte bitmap HUD existente para o letreiro. Nenhum PNG novo é necessário. Paleta local da caldeira/fábrica é apenas a paleta de produção disponível, não uma decisão final do GDD.

Para a entrada do elevador, usar consulta contínua do Player no retângulo interno, ou contrato equivalente que prove a contenção de toda a cápsula e o contato com o chão. Não ativar pelo body_entered genérico de uma área onde a bola também entra. Durante a sequência, desativar temporariamente o processamento do Player e do BallContainer, chamar reset existente do BallLauncher e manter o controlador do lobby ativo para fade/luzes. Isso congela movimento, ações da raquete e projéteis em voo sem pausar globalmente a árvore. Se a troca falhar, restaurar os modos anteriores e exigir saída e reentrada na cabine. No retorno após resumo, RunController libera apenas a pausa de resultado que possui antes da troca; Lobby._ready não altera pausa global arbitrária. Não modificar scripts do Player para isso.

## Arquivos de produto autorizados e implementados

| Arquivo | Mudança |
|---|---|
| project.godot | Alterada somente a cena principal para res://scenes/lobby.tscn. |
| scenes/lobby.tscn | Nova cena com Player atual, enquadramento do pátio, colisões e cabine. |
| scripts/world/lobby.gd | Contenção física do Player, cue/viagem, bloqueio temporário, limpeza do snapshot e recuperação visível. |
| scripts/world/lobby_visual.gd | Novo desenho ambiental do pátio, torre, bancada, cabine e portas com atlas/paleta existentes. |
| scripts/world/run_controller.gd | Resumo de vitória/morte e retorno ao lobby; retry técnico existente preservado. |

Nenhum outro arquivo de produto foi alterado. Permanecem intocados run_root.tscn, Main standalone, RoomTransition, Player/Health/Movement/Ball/Racket, HUD de combate, gerador, balanceamento, recursos de upgrades e GDD.

## Contratos de retorno e erro

A troca de cena de fim só é válida quando _run_ended representa vitória final ou died real. Proteger chamada contra double-click/input repetido. Limpar RoomTransition antes da troca. Em retorno bem-sucedido, a cena da run e seus atores/projéteis saem da árvore. RunController libera a pausa que a própria tela de resultado adquiriu antes de trocar a cena; Lobby._ready não modifica pausa global herdada. Em falha síncrona, manter a tela de resumo e pausa atuais, remover o fade, exibir falha e permitir nova tentativa; não reiniciar a run automaticamente.

Na entrada do elevador, limpar RoomTransition antes de carregar RunRoot. A árvore do lobby não é pausada; Player e BallContainer são reativados somente se a troca falhar. Se falhar, exibir o erro na cena lobby, abrir a porta e exigir que o Player saia da área interna antes de uma nova entrada; não repetir a troca continuamente enquanto permanece na cabine. O Controller recém-carregado limpa o snapshot novamente na inicialização. Não criar seed antes de carregar RunRoot.

## Fora do escopo

Sem loja/economia, NPC, evento, inimigo, alteração de balanceamento, novos upgrades, modificações no HUD anterior, progressão permanente, save, novo autoload, múltiplos andares, mudanças no GDD, nova arte bitmap ou reforma dos controles. Não modificar Player, movimento, vida, launcher, raquete, main.gd, RoomTransition ou run_root. Não executar Godot, import, parser, lint, testes, auditoria de qualidade ou simulação. Sem commit, push, troca de branch ou limpeza de alterações existentes.

## Procedimento depois do GO

Implementação em escritor único com o escopo acima. Antes de editar produto, conferir os hashes e a presença/ausência dos arquivos no baseline em historico/base-sha256.txt. Preservar as alterações locais alheias. Congelar o conjunto completo antes de revisores somente leitura; registrar hashes/diff e conclusões originais. Fazer somente verificações estáticas autorizadas; validação de runtime permanece pendente se não for solicitada.
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
