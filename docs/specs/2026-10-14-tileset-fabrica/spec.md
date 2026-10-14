# Especificação prospectiva — tileset da fábrica v1

Estado: reprodução V3 aprovada visualmente pelo principal; atlas, fonte Aseprite, demos e TileSet independente preparados. O tamanho e a paleta registrados são escolhas desta rodada, não decisões globais do GDD.

## Direção derivada do GDD

O cenário pertence a um jogo 2D lateral de fábrica industrial decadente em dieselpunk noir dos anos 1930–40. A composição deve comunicar primeiro a área jogável: protagonista, bola e ameaças ficam acima das plataformas e paredes; máquinas distantes, cartazes e canos sem função ficam atrás; o fundo industrial tem menor contraste. Para este kit, o ponto de entrada é metal de piso/plataforma com sinais discretos de uso e manutenção.

O GDD recomenda silhuetas claras, metal pesado e luz recortada. No primeiro andar, vapor, manutenção, âmbar, ferrugem e cartazes de produtividade são referências contextuais. Essas descrições guiam a apresentação; a inclusão de cartazes, vapor, óleo, esteiras ou pistões depende da referência preservada e não cria mecânica. Nada nesta proposta define tamanho de tile ou resolução final do jogo.

## Recorte de arte desta versão

O tamanho de célula confirmado para este kit é 32×32 pixels; a organização 4×4 resulta num atlas nativo de 128×128 px, sem espaçamento entre células. Essa escolha vale apenas para esta tarefa. O atlas tem exatamente 16 regiões:

| Coordenada atlas (coluna, linha) | Nome estável | Uso pretendido |
|---|---|---|
| (0,0) | terrain_top_left | Canto superior esquerdo de um bloco de metal |
| (1,0) | terrain_top_mid | Trecho repetível do topo |
| (2,0) | terrain_top_right | Canto superior direito |
| (3,0) | steel_panel | Painel decorativo, fora da área de colisão do recurso |
| (0,1) | terrain_side_left | Borda lateral esquerda |
| (1,1) | terrain_fill | Preenchimento interno repetível |
| (2,1) | terrain_side_right | Borda lateral direita |
| (3,1) | pipe_horizontal | Cano horizontal decorativo |
| (0,2) | terrain_bottom_left | Canto inferior esquerdo |
| (1,2) | terrain_bottom_mid | Trecho repetível da base |
| (2,2) | terrain_bottom_right | Canto inferior direito |
| (3,2) | pipe_vertical | Cano vertical decorativo |
| (0,3) | platform_left | Ponta esquerda de plataforma fina |
| (1,3) | platform_mid | Centro repetível de plataforma fina |
| (2,3) | platform_right | Ponta direita de plataforma fina |
| (3,3) | pipe_corner | Canto decorativo de cano |

Os três trechos de meio devem conectar-se com suas pontas em mosaicos de referência. terrain_fill repete-se sem bordas perceptíveis quando montado em bloco; platform_mid repete-se horizontalmente. O topo mantém contraste para leitura como superfície visual plana; o recurso não define colisão nem comportamento físico. A referência visual preservada orienta desgaste e detalhes; o Lua deve corrigir somente emendas locais necessárias e registrar cada ajuste, preservando a composição de referência.

A paleta de trabalho é independente da paleta do protagonista e tem teto provisório de 20 cores para este kit. Priorizar carvão, cinzas quentes, marrons escuros e pequenas áreas de ferrugem/cobre. Creme, vermelho escuro e dourado podem aparecer em sinalização de propaganda quando a referência pedir. Amarelo claro/ciano indicam interação e vermelho/laranja ameaça; em placas e plataformas comuns, evitar faixas amarelas que pareçam hazard. Usar alpha estritamente binário: tiles de terreno opacos; elementos decorativos podem ter fundo transparente. A seleção hexadecimal da reprodução está registrada no manifesto/paleta do artefato; não representa paleta oficial do GDD.

## Fonte e arquivos de arte

A fonte Aseprite permanece editável; o Lua reproduz as regiões, paleta e exportações a partir da referência preservada. O atlas PNG nativo tem a mesma grade e dimensão da fonte. Contact ampliado usa apenas nearest-neighbor inteiro, sem interpolação. O mapa-demo PNG mostra piso e plataformas com uma cópia pixel-exata do idle atual em 23×50 px; não altera o sprite original nem simula física. As plataformas ocupam largura exata de 32 px e alturas proporcionais de 16, 10 e 17 px; os tubos têm 13 px de altura horizontal opaca e 12 px de largura vertical opaca. Estes valores descrevem apenas a reprodução da referência.

O manifest associa cada nome estável à coordenada, dimensão lógica, uso e arquivo de origem. A documentação do artefato registra a referência usada, paleta efetiva, método de exportação e SHA-256 dos arquivos entregues. A referência ImageGen é mantida intacta como entrada, não copiada como textura de runtime.

## Recurso Godot previsto

O recurso resources/environment/factory_tileset_v1.tres foi preparado como TileSet Godot 4 editável, com tile_size 32×32 e TileSetAtlasSource de texture_region_size 32×32. A textura aponta à cópia pixel-exata em assets/environment/factory_v1/. Definir nearest no CanvasItem/TileMapLayer (não em TileSet); a cena de demo usa Sprite2D com nearest e escala 2. Não configurar colisão, terreno automático, physics layer ou metadados de interação neste recurso; a leitura gráfica de superfície não define física do mundo.

Não alterar main.tscn, solid_platform.tscn, scripts, colisores, entradas, movimento, personagem, inimigos ou atlas preexistentes. Uma cena de amostra pode ser adicionada dentro da nova pasta se o principal julgar útil, sem ser usada pela cena principal.

## Critérios de aceite do recorte

- Grade 4×4 e 16 regiões nomeadas no manifest; coordenadas do manifest e da fonte coincidem.
- Referência preservada intacta e reprodução mantidas separadamente; principal aprovou visualmente o contact V3.
- Pixels nativos alinhados à grade; alpha 0/255; cores apenas da paleta documentada, até o teto provisório de 20.
- Topo de plataforma, bordas e preenchimento continuam legíveis em nearest, em mosaicos de 2×2 e na montagem comparativa com o idle.
- Junções dos segmentos não deixam frestas nem criam linhas de grade involuntárias; decoração não mascara a borda jogável.
- PNG runtime é cópia pixel-exata do PNG de atlas aprovado.
- Recurso TileSet permanece sem colisão, sem alterar cena ou comportamento preexistente.

## Fontes

- [Notion — Arquivo Central](https://app.notion.com/p/3cf695c14e278028a60af8e6bd1a5710)
- [Notion — Direção Visual](https://app.notion.com/p/3cf695c14e2781619978cd3ba62c5f94)
- [Notion — Primeiro Andar](https://app.notion.com/p/3cf695c14e2780668784f80479cd0f9d)
- [Documento local parcial — 04-combate-e-builds.md](../../../../GDD_Dieselpunk_Noir/04-combate-e-builds.md)




## Encerramento do incremento visual

Arte V3 e recurso TileSet preparados. Gemini R1 e Muse R2 concluíram a revisão estática; Grok timeout3min e Opus quota. Os textos documentais foram corrigidos pelo mesmo GPT-6 Luna xhigh via OpenCode após quota na interface original. [Saídas, decisões e hashes](pareceres/README.md). Sem execução de Godot, testes ou importação; uso nas salas e colisões permanecem para etapa própria.


## Importação solicitada pelo usuário — 14/10/2026

Godot4.7.2 importou atlas/demo sem erros (exit0). TileSet carregado com16 células32×32 e textura128×128; prévia carregada. Nenhuma mudança nos8 arquivos de arte/recursos acompanhados por hash. [Logs, status e hashes](pareceres/importacao-2026-10-14/README.md). Sem execução de gameplay; colisões e montagem na sala permanecem para etapa própria.

