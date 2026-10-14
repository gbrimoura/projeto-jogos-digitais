# Especificação — aplicação do tileset às fases

Estado: implementação autorizada; a revisão estática ocorre após congelar a alteração.

## Fonte visual

Reutilizar resources/environment/factory_tileset_v1.tres, fonte atlas 0 e textura 128×128 px, dividida em 16 regiões de 32×32 px. A apresentação é 2× (64 unidades de mundo por célula) com filtro nearest. Não editar, regenerar ou importar a arte.

As colunas 0–2 contêm as pontas e meios de topo, laterais e preenchimento, base do bloco, além de ponta e meio de plataforma na linha 3. A coluna 3 contém painel, segmentos de cano horizontal e vertical e canto de cano. As pontas maiores de plataforma são a forma aprovada da arte; seu suporte pode ser recortado em altura, nunca redimensionado.

## Desenho de superfícies

SolidPlatform mantém tamanho e retângulo de colisão originais. Um filho @tool desenha o estilo de plataforma por regiões da linha 3, prendendo as pontas aos limites esquerdo e direito e repetindo o meio. O estilo de bloco usa a fileira de topo, fileiras centrais de lateral e preenchimento quando houver altura suficiente e a fileira de base; partes finais são cortadas na origem para terminar dentro do tamanho existente. A escala de cada texel continua em 2 unidades de mundo.

Os retângulos legados Fill, TopEdge e FloorDetail ficam ocultos apenas com a skin ativa e reaparecem pelo toggle de fallback. Setters toleram chamadas antes de a árvore de nós estar pronta e atualizam o desenho no editor sem alterar a sincronização física existente.

## Salas

Os pisos das duas salas usam estilo de bloco; as plataformas usam vigas com pontas. A grade de protótipo fica invisível. Painéis e um trecho conectado de cano são Sprite2D de escala 2× no plano de fundo, com nearest e modulação discreta. Eles não recebem física nem mudam a leitura da área de combate.

## Limites

Não mudar geometrias, posições, colisores, paredes, teto, spawns, movimento, regras, atores, HUD, arte ou arquivos fora do escopo. Não executar testes, Godot, importação ou runtime sem pedido explícito. A entrega desta frente terá revisão apenas estática e inspeção de diff.
