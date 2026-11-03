# Plano — pixel art do lobby da fábrica

## Estado

02/11/2026. Fase 1: plano e especificação congelados para revisão do principal. Nenhuma arte, PNG ou integração deste incremento foi produzida. A produção começa somente após GO explícito do principal, conforme coordenação desta tarefa. Esta frente trata exclusivamente da identidade visual do lobby já implementado; não reabre nem altera os contratos de jogo registrados em `../2026-11-02-lobby-elevador/`.

## Objetivo visual

A ambientação atual do lobby usa blocos `draw_rect` amplos e chapados e não conversa suficientemente com a arte pixelada da fábrica. Substituir as grandes massas desenhadas por assets autorados em Aseprite, com recortes mais claros, silhueta arquitetônica reconhecível e detalhes industriais contidos. A hierarquia é: Player luminoso, cabine clara e legível, arquitetura de fundo escura e de baixo contraste.

## Direção travada para esta rodada

- Trabalhar em canvas nativo de 576×324 px, correspondente ao cenário lógico 1152×648 em escala inteira 2× e filtro nearest.
- Criar um backdrop com telhado escalonado, torre distante, chaminés/rooflines recortados, janelas em reentrâncias e poucos rebites, chapas e chips de desgaste planejados. Evitar textura ou ruído decorativo repetido.
- Compor à esquerda uma bancada pequena, visual e baixa (área de referência x≈150–320, piso em y=560 no espaço lógico), com morsa e ferramentas em silhuetas legíveis. Não criar formas que pareçam plataformas ou hitboxes.
- Fazer da cabine à direita o foco secundário: moldura industrial espessa, chapas facetadas, tubos de latão somente pelo exterior e faixa de segurança controlada. O vidro permanece completamente livre de tubos e detalhes cruzados. Preservar a passagem e o interior livre.
- Exportar os fundos com transparência em toda a faixa nativa abaixo de y=280; o piso atual continua exatamente no topo lógico y=560, usando o atlas/código existente. A arte decorativa não define colisão nem plataforma.
- Autorar folhas de porta esquerda/direita em canvas nativo 32×56, exportadas em 2× para 64×112 no mundo. Manter as coordenadas e animação atuais: y=448; esquerda x=848→912 e direita x=1040→976 conforme `door_closed_fraction`.
- Manter intactos a placa âmbar do usuário em Rect2(888,384,176,40), o texto bitmap `ElevatorSign` (posição 896,388), os três focos e seu comportamento dinâmico. O fundo deve deixar essas peças legíveis e não as cobrir. As luzes continuam mudando pelas mesmas chamadas e coordenadas.
- A paleta é travada antes de qualquer pixel: 17 cores de produção da fábrica (`0E0D0E`, `171719`, `1D1B1A`, `25292A`, `302D2A`, `353B3B`, `433E39`, `4A2D21`, `563829`, `5B5249`, `70432C`, `756957`, `925A36`, `90816A`, `8F7059`, `B78342`, `D2A75C`) mais no máximo os três acentos já existentes `E8D8B5`, `879198`, `52BAC7`. Teto de 20 cores; pixels somente alpha 0 ou 255. Metais quentes e ferrugem dão a leitura principal; ciano é acento raro.

## Saídas após GO

Criar `assets/environment/factory_v1/lobby_v1/` com `source/generate_lobby.lua`, fontes `.aseprite` editáveis, PNGs de export, `manifest.json`, `README.md` e previews. O manifesto registrará tamanhos nativos/lógicos, placements/âncoras, paleta, alpha permitido, comando reproduzível e relação de fontes e exports. Gerar previews estáticos em tamanho nativo e ampliados 2×/3×. Incluir o Player original apenas como estudo de composição: recortar o frame 0 pelo mesmo caminho documentado em `assets/ui/hud_caldeira_v1/source/generate_hud.lua` (`crop(pa,0,0,64,64)`), sem salvar ou modificar o atlas do Player; identificar os previews como estudos estáticos, não captura do jogo.

## Integração autorizada após GO

- Principalmente `scripts/world/lobby_visual.gd`: desenhar o backdrop e as portas PNG em nearest e remover apenas as massas ambientais chapadas substituídas.
- Preservar os exports/contratos públicos `visual_layer`, `door_closed_fraction`, `amber_lights_on`, `set_door_closed_fraction()` e `set_amber_lights_on()`.
- `scenes/lobby.tscn` fica congelada; só poderá ser tocada se a integração visual for inviável sem uma referência visual e após justificar isso ao principal. Não mover placa, letreiro, piso, câmera, Player, colisões, camadas ou nós.
- Nenhuma outra fonte de produto, atlas existente, fonte, tile, Player ou regra de jogo pode mudar.

## Critérios de aceite

1. Aseprite real gera fontes e exports a partir da Lua reproduzível; canvas, escala 2×, nearest, cores e alfa obedecem à especificação.
2. Na prévia estática de 1152×648, a silhueta de torre/chaminés fica legível sem competir com o Player; o fundo mantém contraste baixo e detalhes espaçados.
3. Bancada parece cenário de oficina e cabine é o destino focal; abertura e interior são legíveis, vidro sem tubo e faixa de entrada livre.
4. Nenhum asset decorativo invade a área do piso abaixo do topo y=560 no mundo nem sugere uma plataforma extra.
5. Placa, texto bitmap, coordenadas/luzes, dimensões e interpolação das portas e todos os campos/métodos atuais permanecem iguais.
6. A implementação limita-se aos caminhos permitidos e não toca gameplay, cena de run, GDD, jogador, HUD ou configuração global.

## Sequência

1. Principal revisa e ajusta este pacote congelado; somente com GO começa a produção Aseprite.
2. Conferir hashes/cópias baseline em `historico/baseline/`; inspecionar as referências já definidas; revalidar a paleta/grade antes da primeira arte.
3. Produzir um asset por vez no Aseprite, exportar PNGs e prévias e inspecionar as imagens. O pedido exclui Godot/import/parser/lint/testes, `quality_audit` e simulações.
4. Integrar apenas `lobby_visual.gd` (e, se estritamente necessário e aprovado pelo principal, a cena visual autorizada); preservar placa e campos/métodos de animação.
5. Congelar arquivos e hashes para revisão do principal. Não fazer commit, push, limpeza ou troca de branch.
