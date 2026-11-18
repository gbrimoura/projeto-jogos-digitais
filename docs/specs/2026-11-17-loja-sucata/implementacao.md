# Loja de sucata — implementação

Data: 17/11/2026  
Branch: redesenho-lobby  
Estado: integrado localmente; sem commit ou push.

## Comportamento

- A rota inclui duas lojas por andar: após a 3ª e a 7ª salas de combate. O padrão pode ser ajustado em `shop_after_combat_rooms`; cada andar conserva dez combates e um chefe.
- O vendedor abre a oferta com E. O jogo pausa enquanto as cartas estão abertas; E ou Esc fecha. Repetições da tecla são ignoradas.
- Cada visita oferece até duas melhorias do catálogo existente e um item com raridade e perk exclusivo. Comprar consome sucata temporária, atualiza o RunBuild e aplica o efeito ao jogador da sala.
- A loja não conta como combate, não recebe recompensa de combate e não gera inimigos ou objetos destrutíveis. A sala limpa libera a porta de saída.
- O minimapa distingue loja e chefe; o contador de combate continua mostrando as dez salas.
- Custos iniciais (20 sucatas + 5 por nível já adquirido) e posição da loja na rota são configuráveis e provisórios: o GDD ainda não fixa a economia.

## Arte

Vendedor robótico de silhueta compacta, balcão, placa, mercadorias e animação idle de quatro quadros em pixel art. As fontes Aseprite, exports PNG e prévia estão em assets/shop/vendor_v1/. A imagem de prévia foi inspecionada estaticamente; o encaixe em runtime não foi executado.

## Revisão e validação

- Muse Spark 1.3 Contributor, OpenCode opencode-go/muse-spark-1.3-contributor, xhigh, agente plan, saída 0. A configuração de permissões negou as ferramentas e debug agent plan --pure confirmou todas desativadas. O campo de metadados não confirma modelo/variante efetivos.
- R4 (6B0C6B5EEF2859AB55DD21628B124B2F7FD72AC76BA0B111E37E044D25DC91AF) encontrou remoção de inimigos dependente de nomes fixos e fechamento por repetição de E; ambos foram corrigidos.
- R5 (EE4D049EF711F40F66827E384AF456049FC0F66BA63C8F265E3BA00787014AE4) não encontrou achados estáticos acionáveis. Incertezas de renderização em runtime e integração futura com spawners continuam pendentes.
- Gemini 4 Hydrogen (High) não recebeu o diff: não foi possível verificar isolamento contra leitura/escrita fora do snapshot. A revisão permanece pendente pela política de agentes.
- git diff --check passou nos scripts modificados, com avisos de normalização CRLF. Não foram executados testes nem Godot, conforme AGENTS.md.

Saídas brutas do Muse: R4 em pareceres/muse-r4.stdout.jsonl e R5 em pareceres/muse-r5.stdout.jsonl.
## Retrato de fala do vendedor — 17/11/2026

Retrato busto 64×64 integrado ao cabeçalho da oferta. O PNG é mostrado em tamanho nativo com filtro nearest; a coluna de texto fica à direita. A fala curta “ESCOLHA UMA MELHORIA E SIGA SUBINDO” aparece junto ao retrato. As três cartas mantêm 160×240 e permanecem inteiras; os preços ficam sob elas.

Arte criada com GPT-6.1 Sol Medium e exportada pelo Aseprite 1.3.18.6. O .aseprite tem seis camadas; PNG de 64×64, 16 cores exatas da paleta Factory v2, alfa apenas 0/255 e roundtrip pixel a pixel idêntico. A conferência visual em escala 2× e nos tamanhos de interface 40/48 px foi legível.
- PNG SHA-256: D188EAB59515A0785222F6EADC1B17E5F232A2F1C03937F5E57D114274A40813.
- Aseprite SHA-256: 211503B3E2DE8EAD825DAA6493E2E221DC53997EF91DE377FE867F1970DF1394.
- Fonte bitmap auditada: todos os caracteres dos textos de loja estão no atlas. A fala ocupa 210 px dos 492 px disponíveis.

Revisão Muse Spark 1.3 Contributor, OpenCode 1.17.13, modelo solicitado opencode-go/muse-spark-1.3-contributor / xhigh / plan; configuração de negação efetiva confirmou ferramentas desativadas. Modelo/variante efetivos não foram expostos por modelUsage.
- R1 snapshot SHA-256 A0A580BF96C6BC2BCD84AB2BB92B81E8C06371F33CE39E43724C65970413F1F5: apontou recurso e glifos/centralização para conferência. O caminho existe; a fala sem pontuação inválida e o alinhamento foram ajustados.
- R2 snapshot SHA-256 F813D07B29CFEC1E11B7CBD428068101CF64D51DA5145D2A3E174AF1B286717B: pediu auditoria de glifos para todos os estados da loja; conferida em font.json.
- R3 snapshot SHA-256 997ACEA02FCEC0BB0D5A8A21F6A0115D358871D8E2C934C2DC534F417707F1E2: sem achados acionáveis. Importação e leitura visual na engine seguem pendentes; nenhum Godot/teste foi executado.
Saídas originais: muse-retrato-r1.stdout.jsonl, muse-retrato-r2.stdout.jsonl e muse-retrato-r3.stdout.jsonl.


## Expressões faciais do vendedor — 17/11/2026

Folha apenas do rosto, com cinco quadros de 64×64: neutro/ouvindo, falando, satisfeito, surpreso e preocupado. Mantém capacete, antena de cobre, placas laterais e lente âmbar; pálpebra/apertura mecânica e grade do alto-falante formam as expressões. Não inclui tronco nem altera a integração da loja.

Arte criada com o modelo solicitado, GPT-6.1 Sol, esforço medium selecionado na chamada; metadados efetivos do modelo não foram expostos. Fonte Aseprite editável com cinco quadros, cinco camadas e cinco tags. Exportação e reabertura no Aseprite 1.3.18.6 produziram RGBA pixel a pixel idêntico ao PNG. Auditoria: 15 cores da paleta Factory v2, alfa apenas 0/255, sem pixels semitransparentes ou isolados; prévia 4× em nearest exata.

- Atlas 320×64 SHA-256: 647915BB349A148F3878326AFA6D6C8FDE631EDA8E4BCB229B3BA50600905F0F.
- Aseprite SHA-256: AEBC9A71D246C7C309E7E62B07A2173903E79064262179ED8BEEDB1DD9B3052F.
- Prévia 4× 1280×256 SHA-256: FAADB554E3D6FC151491017AE12E3FF2C2FCCC8E95CC775E589A91F2CB80708A.
- Muse Spark 1.3 Contributor, OpenCode 1.17.13, opencode-go/muse-spark-1.3-contributor / xhigh / plan: sem achados acionáveis no snapshot R1 SHA-256 981F3A24D186FC9348A90FDD20B8B7D07E48DBA9841C88E874D998E5540275D2. Configuração de negação confirmou ferramentas desativadas; metadados efetivos de modelo não expostos.

Prévia inspecionada em 1× e 4×; revisão visual considerou os cinco estados distinguíveis. Sem importação, execução de Godot ou testes; nenhum script/cena foi alterado. Saída original do revisor: pareceres/muse-expressoes-r1.stdout.jsonl.


## Expressões amigáveis — referência Stardew Valley — 17/11/2026

Após a solicitação de um rosto mais amigável, consultei a galeria oficial e a nota de desenvolvimento de Stardew Valley. O desenvolvedor comenta que retratos menores ainda carregam personalidade suficiente; apliquei essa leitura com uma lente mais legível, brilho de captura, formas de pálpebra simples e grade do alto-falante como sorriso, preservando a identidade mecânica do vendedor.

Arte final em assets/shop/vendor_v1/: atlas vendor-face-expressions-friendly.png (320×64, cinco quadros de 64×64: neutro/ouvindo, fala, satisfeito, surpresa curiosa, preocupação empática), fonte vendor-face-expressions-friendly.aseprite, prévias nearest de 4×, 48 px por quadro e 32 px por quadro, e o prompt integral em vendor-face-expressions-friendly-prompt.txt. A fonte tem cinco quadros, uma camada editável e cinco tags de expressão.

O editor de imagem integrado gerou o conceito a partir do atlas existente e de um retrato oficial usado como referência visual. O seletor do editor não expõe GPT-6.1 Sol Medium; usei o editor integrado e finalizei os ajustes discretos em Aseprite 1.3.18.6. O arquivo Aseprite exporta para RGBA idêntico ao atlas.

Auditoria de pixel art: quality_audit.py passou no atlas e nas três prévias; 15 cores da paleta Factory v2, alfa somente 0/255, nenhum pixel semitransparente ou isolado. A revisão visual aprovou a distinção e simpatia em 48/64 px; em 32 px de stress visual, alguns sinais ficam mais próximos, portanto essa redução não é o tamanho alvo.

Muse Spark 1.3 Contributor via OpenCode 1.17.13, opencode-go/muse-spark-1.3-contributor / xhigh / plan. Configuração de negação confirmou ferramentas desativadas; modelUsage não expôs metadados efetivos do modelo.
- R2 snapshot SHA-256 4F2504F453C8F26E011200C2981DE40EF26DDF8D0839BF8583370CDF893449DA: pediu separar neutro/surpresa, fala/preocupação e clarificar o olho satisfeito; corrigidos.
- R3 snapshot SHA-256 F80A762C49D86BFF756C66DE24DB90271E8C37BFB92E7DE15E56F9286C2E0C72: apontou fragilidade a 32 px; aumentei pupila, brilho e inclinação e levantei as pontas do arco satisfeito.
- R4 snapshot SHA-256 E85E7E674305A667296A8BC5C347C837569F0BEACB7CBC673A39612BF17E01EB: aprovado em 48/64 px, com observações apenas para 32 px de stress.

Saídas brutas: pareceres/muse-expressoes-stardew-r2.stdout.jsonl, muse-expressoes-stardew-r3.stdout.jsonl e muse-expressoes-stardew-r4.stdout.jsonl. Sem importação, execução de Godot ou testes; nenhuma cena ou script foi alterado.

## Itens e raridades na loja — 17/11/2026

A rota configurável tem duas lojas por andar, após os combates 3 e 7 por padrão; lojas não contam como combate. A geração permanece determinística por seed e posição da loja.

Catálogo provisório, com um item no máximo por visita (quando há item elegível); ele ocupa um dos três espaços de carta junto aos upgrades atuais:

- COMUM: Bolsa Magnética, +1 sucata por coleta, máximo 3 níveis.
- INCOMUM: Mola de Salto, +1 dash aéreo, máximo 1 nível.
- RARO: Punho de Guarda, +8 graus no arco por nível, máximo 2 níveis.
- ÉPICO: Kit de Remendo, cura 1 HP por nível ao avançar de combate limpo, máximo 3 níveis.
- LENDÁRIO: Fusível Aegis, bloqueia um impacto por sala, máximo 1 nível.

Liberação por andar: comum/incomum no 1, raro no 2, épico no 3 e lendário no 4. Pesos de raridade provisórios: andar 1 (75/25 para comum/incomum), andar 2 (60/30/10), andar 3 (45/30/20/5) e andar 4+ (30/27/22/15/6), na ordem comum, incomum, raro, épico, lendário.

Preço provisório: base 20 sucatas; upgrades mantêm sobretaxa de 5 por nível adquirido. Itens somam sobretaxa por raridade (comum 0, incomum 5, raro 10, épico 20, lendário 30). Base e sobretaxas são ajustáveis no RunController; pesos, raridades e efeitos iniciais ficam no catálogo de itens para tuning, sem definir a economia final do GDD.

RunBuild guarda níveis de itens e valida IDs/ranks sem clamping. Snapshots aceitam item_ids/item_levels_by_id e continuam aceitando snapshots legados sem esses campos. Aegis concede a carga ao ser comprado e renova na entrada de cada sala; o bloqueio inicia a janela normal de invulnerabilidade. Kit de Remendo cura apenas ao avançar após sala limpa de combate, nunca ao sair da loja.


### Cinco itens adicionais — 17/11/2026

Os cinco itens existentes e seus IDs permanecem validos. O catalogo agora inclui cinco opcoes provisórias adicionais, mantendo as faixas e os pesos de raridade atuais:

- COMUM `catraca_sucata` (maximo 1): a primeira bola que retorna concede +1 sucata por instância/sala; a Bolsa Magnetica nao amplia esse premio.
- INCOMUM `rolamento_livre` (maximo 2): a velocidade de retorno aumenta 25% por nivel.
- RARO `turbina_centrifuga` (maximo 2): cada rebote ambiental concede +8% de velocidade por nivel, limitado a +40% sobre a velocidade inicial do disparo. Parry e rebotes seguintes preservam o multiplicador acumulado.
- EPICO `bobina_ritmo` (maximo 1): a primeira rebatida bem-sucedida no ar restitui 1 dash aereo, limitado ao maximo atual, uma vez por sala.
- LENDARIO `fusivel_emergencia` (maximo 1): o primeiro dano aceito por sala reduz em 0,5 s o cooldown restante do dash. O Aegis bloqueia dano antes do sinal de dano aceito e nao consome este efeito.

Os itens raros, epicos e lendarios usam os andares minimos ja definidos para suas faixas; os pesos permanecem provisórios. Como cada sala instancia um jogador novo, os efeitos limitados por sala ficam no launcher, controlador de rebatida e jogador dessa instância. `RunBuild` passa a validar e serializar os novos IDs pelo catalogo; snapshots antigos sem campos de item continuam usando os defaults legados.

`ShopItemCard` carrega os PNGs em `assets/shop/items/<id>.png` para esses cinco IDs; os cinco ícones procedurais existentes permanecem. A integração de código foi revisada estaticamente, sem execução de Godot ou testes.

A revisão Muse R1 do pacote de raridades encontrou quatro pontos acionáveis (ordenação única das ofertas, quantidade configurável de lojas, estado sem estoque e descrição desatualizada). Os quatro foram corrigidos antes da revisão R2; resposta original em `pareceres/raridades-r1-muse.jsonl`. A resposta da R2 registra a revisão do estado corrigido. A configuração negou as ferramentas; modelUsage não expôs metadados efetivos de modelo/variante. Gemini 4 Hydrogen (High) permanece pendente porque não foi possível verificar isolamento do revisor. Nenhum teste ou comando Godot foi executado nesta etapa.


#### Arte dos itens

Cada novo item tem um ícone independente 32×32 em `assets/shop/items/`, conceito original em `source/`, ampliação nearest 8× em `preview/` e o prompt usado ao lado do PNG final. Os arquivos finais foram reduzidos à paleta local de 19 cores, com alfa somente 0/255; `quality_audit.py` passou nos cinco ícones sem pixels semitransparentes ou isolados. Aseprite não estava disponível neste ambiente, então não há fontes `.aseprite` para estes ícones.

A inspiração foi a leitura de relíquias com efeitos de build distintos em *Rogue Legacy 2* e de efeitos/afixos associados ao equipamento em *Dead Cells*. Usei esses referenciais para separar as funções por silhueta e efeito, sem reproduzir seus assets: [notas oficiais de atualização de Rogue Legacy 2](https://www.cellardoorgames.com/roguelegacy2-patch/v020), [outra atualização oficial sobre raridade e impacto dos relics](https://www.cellardoorgames.com/roguelegacy2-patch/v070), [referência de afixos de Dead Cells](https://deadcells.wiki.gg/wiki/Affixes).

Os conceitos foram gerados pelo modo integrado `image_gen`; essa ferramenta não disponibiliza seleção nem metadados que confirmem GPT-6.1 Sol Medium. Portanto, o modelo solicitado não pôde ser verificado. A composição foi redimensionada com vizinho mais próximo e remapeada à paleta HUD Caldeira local.
