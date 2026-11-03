# Geração coordenada de salas

**Data:** 18/10/2026  
**Estado:** implementação autorizada; validação em runtime não autorizada nesta etapa.  
**Branch:** `corrigir-sprites-salas-plataformas`; preservar a branch e o trabalho local existente.

## Objetivo

Substituir a tabela fixa da proposta de 16/10 por uma geração aleatória coordenada das plataformas das fixtures atuais, sem definir a quantidade final de plataformas. Manter uma faixa contínua de chão para caminhar, incluir teto visível e conservar portas distintas de entrada e saída nas salas.

O usuário confirmou em 18/10 que os sprites voltaram a funcionar. Esta tarefa não reabre a investigação nem a importação dos sprites de inimigos. A leitura de `GDD_Dieselpunk_Noir/04-combate-e-builds.md` confirma que a geração futura pertence ao controlador da sala e que a porta controla alcance/estado; o algoritmo de layout e as regras finais de geração continuam pendentes. Os números desta spec são limites deste incremento, não regras gerais do jogo.

## Direção de implementação

Um helper local, sem `class_name`, cria um único `RandomNumberGenerator` por layout. Seed `0` randomiza uma vez por instância; seed diferente de zero reproduz a mesma composição. A sala prepara posições, larguras e formas físicas antes de os filhos entrarem em `_ready`, valida o resultado e usa um fallback fixo declarado depois de tentativas limitadas. O preparo é idempotente para não gerar novamente quando uma sala managed entra na árvore.

Preservar o viewport de 1152×648, paredes sólidas em x=0..64 e x=1088..1152 e piso 1152×88 com topo y=560. A plataforma inicial tem topo y=440 e espessura 24; as seguintes formam ao menos uma rota crescente sem exigir dash, com vãos horizontais de 56–96 e subidas de até 80. Todas terminam até y=464, deixando pelo menos 96 px até o piso. As outras alturas podem chegar ao topo y=376, abaixo do teto e com o alvo de 96 px de altura. O número de plataformas permanece derivado das instâncias presentes nas fixtures; três é apenas o recorte atual.

Validar shapes reais após a aplicação, margens contra paredes/teto/saída, ausência de sobreposição positiva entre plataformas, corredor sob elas, spawns, patrulha e um suporte primário/fallback válidos para `TrainingTarget`. Não usar sorteio individual de `SolidPlatform` nem o posicionamento aleatório deferido do alvo.

## Portas e teto

Manter uma entrada visual bloqueada e sem sensor/interação em (112,522), separada do spawn do jogador. Main e SecondRoom têm saída interativa em (1040,522), sem abertura na parede; entrada e saída não compartilham sinais. Managed mantém a saída visível e só emite `run_progression_ready` após interação E, recompensa resolvida, sala limpa, guarda de input encerrada, jogador vivo e ainda em alcance. Uma requisição é consumida uma vez. Main standalone preserva o snapshot de HP/build ao ir para SecondRoom; SecondRoom standalone finaliza com estado visível de conclusão e sem destino fictício ou loop.

Desenhar com o atlas existente e filtro nearest uma faixa de teto de x=0..1152, y=0..64, com o acabamento voltado para baixo; acrescentar uma forma física que cubra exatamente essa faixa e conecte com o colisor existente y=-32..0. As paredes laterais e o piso mantêm suas junções atuais.

## Escopo e validação

Runtime permitido: `scripts/world/main.gd`, `scripts/world/run_controller.gd`, `scripts/world/training_target.gd`, `scripts/world/exit_door.gd`, `scenes/main.tscn`, `scenes/second_room.tscn`, `scenes/exit_door.tscn` e helpers locais novos para geração e teto. Não tocar em movimento, Player, bola, combate, inimigos, sprites/atlas/imports, `run_root.tscn`, GDD ou histórico anterior.

Antes de runtime, registrar nesta pasta plano/spec e cópias com SHA-256 dos arquivos que serão alterados no estado local presente. Nenhum Godot, import, teste ou QA será executado neste incremento; saltos e sensação de caminhada continuam pendentes de avaliação no jogo.
