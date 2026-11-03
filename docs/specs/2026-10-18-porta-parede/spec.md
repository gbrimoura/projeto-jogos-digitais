# Especificação — Porta horizontal embutida na parede

**Estado:** arte e integração visual implementadas e congeladas em 18/10/2026; runtime não verificado.  
**Referências lidas:** `docs/README.md`, `docs/specs/2026-10-18-geracao-salas/plano.md`, `spec.md`, `pareceres/README.md`, e `../GDD_Dieselpunk_Noir/04-combate-e-builds.md` §§3.4 e 9.

## Contrato do asset

- A porta é um asset pixel art horizontal, mais largo que alto, integrado em painel de parede ao fundo junto à extremidade lateral. O usuário confirmou: “Desenho deitado, mais largo que alto” e “tem que ser na parede”. Isso determina a orientação do desenho; não significa apenas movimento horizontal da folha.
- Um módulo por estado mede 160×80 px nativos e reproduz a placa/parede fabril, com uma porta integrada de 128×64 px em `(16,8)`. Sheet contém Closed à esquerda e Open à direita em PNG de 320×80 px (`hframes=2`). Escala runtime 2×; cada módulo é 320×160 px de mundo.
- O estado Open mantém o mesmo caixilho, espessura e registro e move a folha horizontalmente, deixando vão escuro de altura útil mínima 48 px nativos (96 px em jogo) para o protagonista de 88 px. Fechado e aberto têm a mesma silhueta externa e a mesma placa de parede; nenhum texto está embutido.
- Paleta limitada às 20 cores em `../GDD_Dieselpunk_Noir/pitch-assets/tileset-fabrica-v1/palette-fabrica-v1.json`: #0E0D0E, #1D1B1A, #302D2A, #433E39, #5B5249, #756957, #90816A, #BAAA8B, #D3C3A7, #E7CFAD, #4A2D21, #563829, #70432C, #925A36, #B37949, #C68D58, #8F7059, #A68266, #B78342, #D2A75C. Transparência apenas alpha 0/255; o painel final deve ser opaco para conectar à textura da parede. `Sprite2D.texture_filter=1` (nearest); `.import` preexistentes não são editados.
- A arte final é reproduzida manualmente no Aseprite real por Lua editável. ImageGen é referência a simplificar para a grade nativa, nunca PNG runtime. A folha Open recolhe em lâminas telescópicas num bolso lateral integrado ao batente; a abertura de 48 px fica livre, sem estacionar uma folha na margem externa de 16 px. O painel usa emendas e placas coerentes com o atlas, sem borda exterior espessa de caixa colada.

## Posicionamento

- Saída: Area2D permanece em `(1040,522)`. `Sprite2D` central fica no offset local `(-80,-26)`, centro global `(960,496)`, escala `(2,2)`, `z_index=-2`. Bounds do módulo: x=800..1120, y=416..576. Porta integrada no módulo: x=832..1088, y=432..560.
- Entrada: Area2D permanece em `(112,522)`, `Sprite2D` central em `(+80,-26)`, centro global `(192,496)`, mesma escala/z. Bounds do módulo: x=32..352, y=416..576. Porta integrada: x=64..320, y=432..560.
- Desenho integra a parede de fundo junto à parede lateral e fica atrás do jogador. A faixa lateral existente cobre apenas borda do painel: na esquerda, x=32..64; na direita, x=1088..1120. O vão interno da porta termina exatamente na face interna x=64 ou x=1088 e não é cortado. Piso em y=560 cobre a base do painel; a soleira do vão termina em y=560.
- Ordem de desenho efetiva nas cenas: `SandboxVisual=-10`; raiz da porta `0` com `Sprite2D=-2`; paredes visuais `-1` (x=0..64 e x=1088..1152); piso `0`; atores `1`. O rebaixo é um elemento de parede de fundo e pode ficar parcialmente coberto nos limites, preservando toda a abertura da porta. A parede física continua íntegra.

## Contrato de integração

- `ExitDoor` mantém a interação E, sinais, guards, unlock, estado terminal, alcance e transição já existentes. Somente a apresentação escolhe Closed/Open: entrada sempre Closed; saída fechada enquanto bloqueada/ocupada e aberta depois de liberada; saída terminal Open após conclusão.
- Sensor da saída permanece 96×108 e em x=992..1088 relativo ao mundo da sala; entrada continua sem sensor ativo. O indicador âmbar e o texto `[E] ENTRAR` ficam localizados junto ao sensor e não prometem interação em toda a largura do asset.
- Nenhuma passagem física nova é criada. Parede, colliders, piso, triggers, spawns, plataformas, câmera, controles e fluxos de HP/build/recompensas permanecem iguais.
- `DoorLabel` continua separado do asset, compacto e inteiramente na região jogável próxima da porta. Polígonos e linhas vetoriais antigos deixam de representar a porta. Na entrada, `flip_h=true` vira o bolso assimétrico para a parede lateral; o fluxo de entrada continua fechado.

## Critérios de aceite estático

1. Folha de 320×80 px, dois frames iguais em dimensões/encaixe de 160×80, arte da porta interna de 128×64 por frame.
2. Estado aberto mantém um vão de ao menos 48 px nativos de altura e permanece reconhecível como porta aberta na escala 2×.
3. Paleta exata de 20 cores; pixels transparentes usam alpha 0, opacos alpha 255.
4. Preview 4× e montagem estática usam atlas real por coordenadas, mostram estados fechado/aberto nas duas extremidades, painel na parede, piso e personagem atual em primeiro plano; a entrada aberta é somente comparação de arte, pois o fluxo de jogo continua fechado. Sem screenshot do Godot.
5. Cena/script reutilizável removem os polígonos e linhas antigos e atualizam somente o frame visual. Cenas Main/SecondRoom mudam apenas offsets/flip/z/estados visuais do sprite e label.
6. Sensores, posição das raízes das portas, parede física, floor, spawns e demais objetos de gameplay mantêm o estado baseline.

## Validação autorizada

Inspeção simples dos PNGs e montagem estática, mais leitura textual de cenas/scripts. Não executar Godot, import, testes, quality audit ou QA automatizado. Revisão final pelo principal após freeze; leitura e progressão reais em runtime permanecem pendentes.
