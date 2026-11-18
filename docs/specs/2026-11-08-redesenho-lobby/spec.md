# Especificação — integração do fundo do lobby

## Fonte e montagem

- Fonte aprovada: imagem gerada do lobby, RGB 1672×941; manter bytes/pixels e guardar uma única cópia runtime em assets/environment/factory_v1/lobby_v2/.
- Desenhar a imagem completa desde (0,0), com dimensão horizontal lógica 1152 e escala vertical 560/808 para alinhar a linha de piso estimada da fonte ao topo da colisão y=560. Isso deixa aproximadamente quatro pixels do limite inferior além do viewport 1152×648, sob o piso. A identidade do arquivo não muda.
- O desenho deve cobrir por inteiro o fundo anterior, incluindo o piso embutido e o topo da torre. Não sobrepor atlas antigo de piso nem peças antigas de laterais.
- Aplicar filtragem linear somente ao CanvasItem do fundo. A textura de fundo é maior que o cenário lógico e será vista a 1920×1080; a filtragem reduz serrilhado nessa ampliação ligeira. Manter nearest nas folhas V1 e no letreiro bitmap.

## Vão, portas e gatilho

- Compartilhar Rect2(908,454,102,106) entre desenho visual, posições/recorte das folhas e área de embarque. Esse retângulo representa o vão da imagem transformada e termina no topo da colisão do piso.
- Reutilizar as duas folhas V1 opacas, sem alterar os respectivos arquivos. Em posição fechada, desenhar uma folha 51×106 à esquerda e outra 51×106 à direita, com encontro no centro. Em posição aberta, recolher as folhas para fora dos limites do vão.
- Intersectar o destino de cada folha com o vão e ajustar o retângulo-fonte na mesma proporção antes do desenho. A animação inteira fica recortada ao interior visível, portanto nenhuma folha cobre moldura ou arte lateral.
- A condição de entrada continua exigindo o AABB da forma de colisão do Player, vivo e no chão. Só sua região interna passa a derivar da constante visual. Preservar latch, bloqueio, cue de luz, fade, carga de cena e recuperação de erro.

## Letreiro e sinais

Preservar letreiro bitmap e estado/temporização do evento âmbar. A placa compacta fica centralizada imediatamente acima do vão; três indicadores ficam em uma linha acima da placa, fora do vão, para continuarem visíveis durante o fechamento das folhas e durante o cue. O nó de texto e o apoio âmbar podem mudar de posição/tamanho sem retrabalhar a textura. A textura não recebe letreiro, sinais de estado ou elementos do jogo. O jogador e todas as colisões/câmera permanecem onde estão.

## Arquivos permitidos e não objetivos

Somente scripts/world/lobby_visual.gd, scripts/world/lobby.gd, scenes/lobby.tscn (apenas nó do letreiro se necessário), assets/environment/factory_v1/lobby_v2/**, esta pasta de especificação e docs/README.md. Manter todos os demais arquivos e mudanças locais alheias.

Não introduzir mecânicas, lojas, NPCs, alterações de combate ou novas texturas derivadas do fundo. Não executar Godot/editor/import/testes/lint. Não gerar ou editar outra versão da arte. A prévia é estudo estático temporário e não é runtime nem validação de gameplay.

## Verificação estática

Registrar SHA-256 da fonte externa e da cópia runtime; medir o PNG sem reescrevê-lo; conferir a mesma constante usada nos dois scripts; inspecionar por leitura/diff que a física, a câmera e a viagem mantiveram contratos. Se existir prévia Aseprite, registrá-la fora de res://. Validação Godot/runtime segue pendente.

## Adendo — placa e paleta do protagonista

A placa estática de 94×30 ocupa o retângulo x=912, y=424 até y=454, acima do vão. Ela usa letras gravadas em dois níveis, a paleta de metal do elevador e filtro nearest. As três lâmpadas e o aviso bitmap de viagem mantêm seu papel. A arte é reproduzível pelo Lua no diretório sign, com fonte Aseprite de três camadas e PNG com alpha binário. A prévia estática usa o idle real em 2× no spawn.

A cena do lobby aplica um material apenas ao AnimatedSprite2D da sua instância do Player. No modo Compatibility, o shader trabalha com o RGB da textura em sRGB. Os tons de branco, azul, amarelo e contorno recebem ajustes moderados para marfim, aço, latão e sombra quente. O visor ciano e a modulação de cor e alpha são preservados. A geometria das portas, a física, a lógica de viagem, o fundo e os arquivos do personagem compartilhado não fazem parte desta alteração.

## Adendo — animação ambiente do fundo

O movimento é aplicado a um `Sprite2D` separado, filho de `EnvironmentVisual` e renderizado atrás dele, usando a mesma PNG, escala e filtro linear do desenho estático anterior. Uma máscara com feather limita o deslocamento horizontal senoidal de ±28 px da fonte às nuvens em x=58..1020 e y<275; o loop de 36 s é periódico inclusive no rollover de `TIME` (3600 s). Regiões de luz existentes recebem pulsos espaçados, assíncronos e moderados, limitados a pixels quentes nas lanternas da oficina/elevador e nas pontas das antenas; seus ciclos são múltiplos inteiros da fase de 36 s. A chamada de animação fica somente no nó de fundo. Geometria e elementos de jogo não são alterados, e `_play_travel_cue` mantém os três LEDs dinâmicos existentes.

## Adendo — placa de luxo SELENITE TOWER

A placa Sprite2D 128×22 fica na fachada central, abaixo do farol, em `(893,111)`, alinhada ao eixo `x=957` e integrada ao volume da torre. A arte Aseprite em três camadas usa frisos simétricos de latão polido, esmalte petróleo e letras ouro claro com o texto exato `SELENITE TOWER`; o filtro é nearest e o `z_index` é -9. A prévia 1152×648 é um estudo estático criado sobre a prévia harmonizada anterior e recebe um nome novo em Temp. O fundo e as demais partes de jogo são preservados. A placa PNG foi importada no Godot 4.7.2; a partida não foi executada.
