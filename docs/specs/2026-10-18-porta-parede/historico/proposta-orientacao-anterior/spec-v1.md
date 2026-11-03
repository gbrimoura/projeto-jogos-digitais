# Especificação — Porta embutida na parede

**Estado:** integração visual autorizada em 18/10/2026; revisão do principal após freeze; runtime não verificado.  
**Referências lidas:** `docs/README.md`, `docs/specs/2026-10-18-geracao-salas/plano.md`, `spec.md`, `pareceres/README.md`, e `../GDD_Dieselpunk_Noir/04-combate-e-builds.md` §§3.4 e 9.

## Contrato visual do asset

- Pasta nova: `assets/environment/factory_v1/door/`.
- Um sheet vertical editável de dois frames, na ordem `Closed` (y=0) e `Open` (y=64), cada um de 32×64 px nativos; sheet final de 32×128 px.
- Escala do jogo: 2×, usando `Sprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST`. A textura cobre um patch de 64×128 px da parede; o desenho é uma peça de parede com porta encastrada, não um prop autônomo colocado no chão.
- Paleta: somente as 20 entradas já declaradas em `../GDD_Dieselpunk_Noir/pitch-assets/tileset-fabrica-v1/palette-fabrica-v1.json`: #0E0D0E, #1D1B1A, #302D2A, #433E39, #5B5249, #756957, #90816A, #BAAA8B, #D3C3A7, #E7CFAD, #4A2D21, #563829, #70432C, #925A36, #B37949, #C68D58, #8F7059, #A68266, #B78342, #D2A75C. Transparência, se usada, é binária (alpha 0 ou 255); o módulo pode ser integralmente opaco para cobrir a parede existente.
- `Closed` e `Open` usam o mesmo caixilho, espessura, registro e soleira. O estado fechado cobre o vão; o estado aberto recolhe a veneziana para dentro do lintel, preservando moldura/silhueta e mostrando vão escuro com pelo menos 44 px nativos livres em altura. Não há rótulos, setas, efeitos de bloom ou personagem dentro da arte.
- Entregáveis editáveis: `.aseprite`, `.lua` de geração, `.png` de runtime, PNG de prévia 4× e montagem estática integrada na parede usando coordenadas do atlas atual. A referência ImageGen original é preservada como referência, junto do prompt guardado por `/root` em `imagegen-prompt.txt`.

## Estados e runtime visual

- O visual acompanha apenas o estado já existente: `Entrance` sempre Closed; `Exit` Closed enquanto bloqueada ou ocupada; `Exit` Open quando liberada; a porta terminal também mostra Open após `set_terminal_complete`.
- Mantêm-se a classe/cena reutilizável e a interação E. `ExitDoor` continua emitindo o pedido de transição segundo as guards existentes; o script não passa a decidir o destino.
- A arte aberta sinaliza o estado de saída/transição, mas a parede permanece sólida e visualmente contínua em física. Nada atravessa por uma abertura introduzida nesta entrega.
- Sprite da direita: centro global (1120,496), frame centralizado, escala (2,2), offset local (80,-26), espelhado horizontalmente para posicionar o indicador âmbar no lado jogável. Sprite da esquerda: centro global (32,496), offset local (-80,-26), mesmo frame/escala, sem flip. Os dois cobrem seus patches exatos de parede e terminam na soleira global y=560.
- Sensor de saída permanece centrado em (1040,522), 96×108, bounds globais x=992..1088; entrada em (112,522) permanece sem sensor ativo. Paredes e colisões permanecem sem alteração.
- O label separado fica dentro da arena, acima/lado jogável da porta, compacto, sem integrar texto no PNG.

## Critérios de aceite estático

1. Ambos os estados têm 32×64 px e o mesmo encaixe; folha `.png` tem exatamente 32×128 px.
2. Todas as cores RGB pertencem à paleta autorizada e toda transparência, se houver, é alpha 0/255.
3. O estado aberto expõe abertura legível com altura útil de ao menos 44 px nativos; não bloqueia o eixo vertical todo como o obturador original de referência.
4. Prévia 4× e montagem mostram a porta encaixada na amostra da parede atlas, sem aspecto de objeto solto no chão e sem screenshot do Godot.
5. `exit_door.tscn` deixa de conter `Polygon2D`/`Line2D` decorativos antigos; `exit_door.gd` atualiza o frame e preserva estado/labels e toda lógica de input/transição; cenas das salas contêm apenas overrides visuais de portas.
6. Não há mudanças nos colliders de parede ou sensor, na área de alcance, no jogo, na física nem em scripts de gameplay fora da apresentação da porta.

## Validação permitida e pendências

A validação desta etapa é documental e visual estática (inspeção dos PNGs e da montagem). Não executar Godot, import, testes, quality audit ou QA automatizado. A leitura do sprite e a progressão real em runtime permanecem pendentes da avaliação manual do usuário.
