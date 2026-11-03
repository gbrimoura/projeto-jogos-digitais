# Especificação — kit pixel art do lobby

## Propósito e relação com o lobby existente

Reestilizar somente os desenhos ambientais do lobby desconexo para que pareçam parte da fábrica pixelada. Reutilizar sala, câmera, Player, piso, placa/letreiro e comportamentos implementados e aceitos no plano `2026-11-02-lobby-elevador`. Nenhuma proposta visual vira regra de jogo ou colisão.

## Grid, tamanho, filtro e palette lock

- Canvas mestre do backdrop: 576×324 nativo; cenário lógico: 1152×648 em escala inteira 2×.
- PNG do backdrop: 1152×648, nearest, com alpha 0 em todos os pixels correspondentes à faixa nativa y=280..323 (mundo y=560..647). O piso existente, incluindo seu topo exato em y=560, permanece desenhado pelo atlas atual.
- Canvas de cada folha de porta: 32×56 nativo; PNG final: 64×112 para as dimensões de porta atuais em coordenadas de mundo.
- Alpha binário, somente 0/255. Sem antialiasing, blur, gradientes fracionários ou pixels fora da paleta.
- Paleta bloqueada antes da geração: `#0E0D0E #171719 #1D1B1A #25292A #302D2A #353B3B #433E39 #4A2D21 #563829 #5B5249 #70432C #756957 #925A36 #90816A #8F7059 #B78342 #D2A75C`, mais no máximo `#E8D8B5 #879198 #52BAC7`. Até 20 cores. `#52BAC7` fica reservado a pequenos acentos; não construir um grande HUD/campo ciano.
- A paleta de 17 cores corresponde à declarada em `background_floor1.lua`; o limite de 3 extras autoriza somente os acentos existentes indicados acima, não cria uma nova paleta GDD.

## Composição lógica e regiões protegidas

| Peça | Região lógica aproximada | Requisito |
|---|---|---|
| Piso do pátio | y=560–648 | Exatamente o atlas/código atual; nenhuma arte nova abaixo de y=560. |
| Bancada | x=150–320, base em y=560 | Pequena, sem colisão; vise/morsa e 1–2 ferramentas reconhecíveis. |
| Torre/fábrica | Ao fundo, sobretudo à direita | Chaminés e telhados escalonados; janelas inset; rebites, chapas e lascas controlados, sem ruído e com baixo contraste. |
| Vidro da cabine | Rect2(912,448,128,112) de referência | Interior visível e caminho sem tubo, cano, viga, pilar ou ornamento atravessando o vão. |
| Moldura da cabine | Aproximadamente x=872–1080, topo y≈424, piso y=560 | Massa industrial espessa, placas biseladas, latão/tubos exteriores e faixa de segurança discreta; entrada aberta e identificável. |
| Placa + letreiro | Moldura Rect2(888,384,176,40); nó em (896,388) | Preservar o desenho âmbar e o texto bitmap existentes; manter área livre e contraste legível. |
| Luzes indicadoras | Centros x=928, 968, 1008 em y≈428 | Não incorporar estado nas texturas; continuar trocando âmbar por `amber_lights_on` via retângulos dinâmicos atuais. |
| Portas em primeiro plano | painel esquerdo e direito em y=448, 64×112 | Arte autoral, origem nativa 32×56; conservar posições e animação por `door_closed_fraction`. |

As coordenadas da composição são em espaço lógico do jogo quando não indicadas como nativas. Os valores são guia de arte; não movem colisões, Player ou nós da cena. A arte deve acomodar a placa criada antes deste incremento, sem a deslocar ou redesenhar.

## Comportamento visual preservado

`lobby_visual.gd` continua sendo o nó de desenho das duas camadas (`visual_layer` 0 fundo/1 portas). Preservar os campos e métodos públicos existentes:

- `visual_layer`
- `door_closed_fraction` e `set_door_closed_fraction(value)`
- `amber_lights_on` e `set_amber_lights_on(value)`

A layer 0 compõe PNG de fundo, placa/indicadores dinâmicos e atlas de piso/limites conforme o contrato existente. A layer 1 compõe as folhas PNG nas posições interpoladas existentes. Nearest e coordenadas inteiras mantêm contorno nítido. Não mudar `scenes/lobby.tscn` como parte do plano base; manter `ElevatorSign`, o letreiro/status, Player, câmera, colisões e z-order.

## Fontes e exports esperados

Diretório: `assets/environment/factory_v1/lobby_v1/`.

- `source/generate_lobby.lua`: gerador executável pelo Aseprite; parâmetros devem vir antes de `--script`, como no README de `background_floor1`.
- `source/*.aseprite`: composição editável do fundo e fontes editáveis de portas; layers nomeadas para estrutura distante, janelas/reentrâncias, detalhes conectados, bancada/cabine e placas quando aplicável.
- `export/lobby-backdrop-576x324.png`: fundo transparente na faixa do piso; palette/alpha conforme trava.
- `export/elevator-door-left-32x56.png`, `export/elevator-door-right-32x56.png`: painéis exportados da grade nativa 32×56. Uma fonte pode conter ambos como layers independentes.
- `manifest.json`: versões/dimensões, palette, convenção de transparência, escala, bounds/âncoras em nativo e mundo, listagem de outputs e versões/hash dos inputs.
- `README.md`: propósito, estrutura, produção reproduzível, placements e limites de integração.
- `preview/`: composição de estudo 576×324, ampliações nearest 2×/3× e estudo contextual com crop/frame0 original do Player. Todas identificadas como estáticas e não capturas runtime.

## Preservação e fronteiras

- Antes da produção, usar cópias e hashes congelados em `historico/baseline/`. O script atual, ainda untracked no repositório, inclui a placa âmbar que o usuário adicionou em `(888,384)`; a cópia é a autoridade byte a byte para preservar essa alteração local.
- Escopo máximo de integração após GO: `scripts/world/lobby_visual.gd`; `scenes/lobby.tscn` só com motivo necessário comunicado ao principal. Novos assets exclusivamente sob `assets/environment/factory_v1/lobby_v1/`.
- Não editar player, atlas de fábrica, tiles, fonte bitmap, cenas/scripts de gameplay, arquivo global de projeto ou GDD. Nada de loja, interação, colisão, plataforma, HUD novo ou mudança de câmera/zoom.
- Não executar Godot, imports, parser, lint, testes, simulações ou `quality_audit`. Produção/inspeção de arte ocorre no Aseprite real e pela visualização dos PNGs.

## Refinamento prospectivo do principal
Preferir PNGs de runtime em resolução NATIVA: export/lobby-backdrop-576x324.png e export/elevator-door-left-32x56.png / elevator-door-right-32x56.png. O Godot desenha esses arquivos em destino1152x648 e64x112 com nearest, exatamente2x, como os fundos atuais das salas. As dimensões export1152/64 listadas anteriormente nesta V1 ficam substituídas por esta decisão; ampliações pertencem às prévias. Manter piso totalmente transparente em y>=280 do asset nativo; o código antigo continua desenhando o chão físico/visual. O catálogo de outputs no manifest deve refletir os arquivos reais. Root inspeciona visualmente a primeira prévia antes da integração; aprovação visual é do principal dentro da autorização atual, sem pedir nova confirmação ao usuário.

