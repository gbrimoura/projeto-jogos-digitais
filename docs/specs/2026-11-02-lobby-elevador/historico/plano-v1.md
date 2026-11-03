# Plano prospectivo — lobby e elevador de início da run

## Estado e autorização

02/11/2026. O usuário autorizou o recorte descrito abaixo. Esta primeira fase somente leu fontes e escreveu os documentos desta pasta; ainda não alterou produto. A implementação depende de GO explícito do agente principal após o freeze e a revisão do plano.

O GDD externo em C:\Users\danie\Documents\ChatGPT\TEC - Jogos\GDD_Dieselpunk_Noir\04-combate-e-builds.md, seção 8, estabelece que a build é temporária e reinicia na morte e que a oficina trata de melhorias permanentes. Economia e valores da oficina continuam pendentes. A bancada aqui é somente cenário, sem loja, moeda, NPC ou interação.

## Recorte acordado

- Abrir o jogo no pátio/lobby industrial, com uma torre alta ao fundo. Uma bancada de manutenção pequena serve de ambientação; o elevador focal mostra ELEVADOR / ANDAR 01.
- A mesma cena de lobby permite caminhar, pular, dash, mirar, lançar bola e usar a raquete. Não há inimigos. O piso é contínuo, os limites são sólidos e o jogador não pode cair para fora do enquadramento.
- Caminhar inteiramente para dentro da cabine, enquanto está vivo e no chão, inicia a viagem sem tecla de interação. A colisão inteira do jogador deve caber no retângulo interno da cabine, não apenas tocar um Area2D. O teste usa a instância Player da cena, nunca a bola, e um latch é armado antes de qualquer await para impedir viagens duplicadas.
- A viagem fecha portas, pisca luzes, aplica vibração visual curta, exibe ANDAR 01 e faz fade curto. A chamada de troca carrega a cena de run existente. Erro de carregamento permanece visível, reabre/rearma o elevador e permite tentar outra vez.
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

Para a entrada do elevador, usar consulta contínua do Player no retângulo interno, ou contrato equivalente que prove a contenção de toda a cápsula e o contato com o chão. Não ativar pelo body_entered genérico de uma área onde a bola também entra. Durante a sequência, desativar temporariamente o processamento do Player e do BallContainer, chamar reset existente do BallLauncher e manter o controlador do lobby ativo para fade/luzes. Isso congela movimento, ações da raquete e novos/projéteis em voo sem pausar globalmente a árvore. Se a troca falhar, restaurar os modos anteriores e permitir nova tentativa. Ao voltar de um resumo (árvore pausada pelo RunController), a nova cena lobby despausa sua própria árvore no _ready. Não modificar scripts do Player para isso.

## Arquivos de produto propostos após GO

| Arquivo | Mudança |
|---|---|
| project.godot | Alterar somente application/run/main_scene para scenes/lobby.tscn. |
| scenes/lobby.tscn | Criar cena jogável com Player atual, câmera fixa, mundo/colisões e cabine. |
| scripts/world/lobby.gd | Controlar ambientação visual procedural, checagem de contenção, sequência do elevador, limpeza de snapshot, troca de cena e erro recuperável visível. |
| scripts/world/run_controller.gd | Trocar a ação de término real para resumo e retorno ao lobby; mapear R ao retorno durante término. Preservar retry/restart técnico e transições existentes. |

Nenhum arquivo auxiliar de arte é proposto. Se o implementador concluir que um quinto arquivo é indispensável, ele deve justificar no handoff e aguardar autorização antes de ampliar a lista. Não editar run_root.tscn, scenes/main.tscn, scripts/world/main.gd, RoomTransition, scripts de Player/Health/Movement/Ball/Racket, HUD, gerador, balanceamento, recursos de upgrades ou GDD.

## Contratos de retorno e erro

A troca de cena de fim só é válida quando _run_ended representa vitória final ou died real. Proteger chamada contra double-click/input repetido. Limpar RoomTransition antes da troca. Em retorno bem-sucedido, a cena da run e seus atores/projéteis saem da árvore e a árvore volta a despausar ao carregar o lobby. Em falha síncrona, manter a tela de resumo e pausa atuais, remover o fade, exibir falha e permitir nova tentativa; não reiniciar a run automaticamente.

Na entrada do elevador, limpar RoomTransition antes de carregar RunRoot. A árvore do lobby não é pausada; Player e BallContainer são reativados somente se a troca falhar. Se falhar, exibir o erro na cena lobby, abrir a porta e limpar o latch. O Controller recém-carregado limpa o snapshot novamente na inicialização. Não criar seed antes de carregar RunRoot.

## Fora do escopo

Sem loja/economia, NPC, evento, inimigo, alteração de balanceamento, novos upgrades, modificações no HUD anterior, progressão permanente, save, novo autoload, múltiplos andares, mudanças no GDD, nova arte bitmap ou reforma dos controles. Não modificar Player, movimento, vida, launcher, raquete, main.gd, RoomTransition ou run_root. Não executar Godot, import, parser, lint, testes, auditoria de qualidade ou simulação. Sem commit, push, troca de branch ou limpeza de alterações existentes.

## Procedimento depois do GO

Implementação em escritor único com o escopo acima. Antes de editar produto, conferir os hashes e a presença/ausência dos arquivos no baseline em historico/base-sha256.txt. Preservar as alterações locais alheias. Congelar o conjunto completo antes de revisores somente leitura; registrar hashes/diff e conclusões originais. Fazer somente verificações estáticas autorizadas; validação de runtime permanece pendente se não for solicitada.